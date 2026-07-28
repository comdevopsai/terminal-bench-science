#!/bin/bash
set -euo pipefail

echo "=== Social Trust Game Analysis: Reference Solution ==="

python3 << 'PYEOF'
import numpy as np
import pandas as pd
import json
import os
from scipy.optimize import minimize
data = pd.read_csv("/app/trust_game_data.csv")
print(f"Loaded {len(data)} trials from {data['trustor_id'].nunique()} trustors and {data['trustee_id'].nunique()} trustees")

# Load true params for reference
with open('/app/true_params.json') as f:
    true_params = json.load(f)
print(f"True params: {true_params}")

# Fehr-Schmidt (1999) inequity aversion log-likelihood
def fehr_schmidt_ll(params, offers, returns, trustor_payoffs, trustee_payoffs):
    alpha_t, beta_t, alpha_r, beta_r = params
    
    # Bounds
    if any(p < 0 for p in params):
        return np.inf
    if alpha_t > 3 or beta_t > 1.5 or alpha_r > 3 or beta_r > 1.5:
        return np.inf
    
    n = len(offers)
    ll = 0.0
    
    for i in range(n):
        # Trustor expected payoff: offer gives 3*offer to trustee, keeps (10-offer)
        # But trustee returns some amount `return_amount`
        # Actually: trustor gets (10 - offer + return_amount)
        # Trustee gets (3*offer - return_amount)
        
        # Compute utility for trustor
        u_t = trustor_payoffs[i] - alpha_t * max(trustee_payoffs[i] - trustor_payoffs[i], 0) - beta_t * max(trustor_payoffs[i] - trustee_payoffs[i], 0)
        
        # Compute utility for trustee
        u_r = trustee_payoffs[i] - alpha_r * max(trustor_payoffs[i] - trustee_payoffs[i], 0) - beta_r * max(trustee_payoffs[i] - trustor_payoffs[i], 0)
        
        # Log likelihood: probability of observed offer and return
        # Offer: trustor maximizes utility by choosing optimal offer
        # Return: trustee maximizes utility by choosing optimal return given offer
        # We approximate with a softmax choice model
        
        # For simplicity, use Gaussian noise around predicted behavior
        predicted_offer = 10.0 * (1 - np.exp(-0.5 * u_t)) if u_t > 0 else 0.0
        predicted_return = min(3 * offers[i], trustee_payoffs[i] + 0.1 * u_r) if u_r > 0 else 0.0
        
        sigma = 1.0  # noise parameter
        ll += -0.5 * ((offers[i] - predicted_offer) / sigma)**2 - np.log(sigma * np.sqrt(2 * np.pi))
        ll += -0.5 * ((returns[i] - predicted_return) / sigma)**2 - np.log(sigma * np.sqrt(2 * np.pi))
    
    return -ll  # Return negative for minimization

# Prepare data
offers = data['offer'].values
returns = data['return_amount'].values
t_payoffs = data['trustor_payoff'].values
r_payoffs = data['trustee_payoff'].values
conditions = data['condition'].values

# Initial guess
x0 = [0.5, 0.3, 0.5, 0.3]

# Optimize
result = minimize(fehr_schmidt_ll, x0, args=(offers, returns, t_payoffs, r_payoffs),
                  method='Nelder-Mead',
                  options={'maxiter': 10000, 'xatol': 1e-6, 'fatol': 1e-6})

alpha_trustor, beta_trustor, alpha_trustee, beta_trustee = result.x[:4]

# Estimate trustor offer bias (mean offer across all trials)
offer_bias = float(np.mean(offers))

# Compute model fit
neg_ll = result.fun
n_obs = len(offers)
n_params = 5
aic = 2 * n_params - 2 * (-neg_ll)
bic = n_params * np.log(n_obs) - 2 * (-neg_ll)

# Individual parameters by player
trustors = data.groupby('trustor_id').agg({
    'offer': 'mean',
    'trustor_payoff': 'mean',
    'trustee_payoff': 'mean'
}).reset_index()

trustees = data.groupby('trustee_id').agg({
    'return_amount': 'mean',
    'trustee_payoff': 'mean',
    'trustor_payoff': 'mean'
}).reset_index()

# Save outputs
os.makedirs('/workspace/results', exist_ok=True)

with open('/workspace/results/fitted_params.json', 'w') as f:
    json.dump({
        "alpha_trustor": float(alpha_trustor),
        "beta_trustor": float(beta_trustor),
        "alpha_trustee": float(alpha_trustee),
        "beta_trustee": float(beta_trustee),
        "trustor_offer_bias": offer_bias
    }, f, indent=2)

with open('/workspace/results/model_fit.json', 'w') as f:
    json.dump({
        "log_likelihood": float(-neg_ll),
        "aic": float(aic),
        "bic": float(bic),
        "n_observations": int(n_obs),
        "n_parameters": n_params
    }, f, indent=2)

# individual_params.csv
import csv
with open('/workspace/results/individual_params.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['player_id', 'player_type', 'alpha', 'beta'])
    # Trustors get alpha_t, beta_t; trustees get alpha_r, beta_r as proxy
    for _, row in trustors.iterrows():
        writer.writerow([row['trustor_id'], 'trustor', float(alpha_trustor), float(beta_trustor)])
    for _, row in trustees.iterrows():
        writer.writerow([row['trustee_id'], 'trustee', float(alpha_trustee), float(beta_trustee)])

# offer_by_condition.csv
cond_stats = data.groupby('condition')['offer'].agg(['mean', 'median', 'count']).reset_index()
with open('/workspace/results/offer_by_condition.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['condition', 'mean_offer', 'median_offer', 'n_trials'])
    for _, row in cond_stats.iterrows():
        writer.writerow([row['condition'], float(row['mean']), float(row['median']), int(row['count'])])

print(f"Fitted params: alpha_t={alpha_trustor:.3f}, beta_t={beta_trustor:.3f}, alpha_r={alpha_trustee:.3f}, beta_r={beta_trustee:.3f}, bias={offer_bias:.3f}")
print(f"Model fit: LL={-neg_ll:.2f}, AIC={aic:.2f}, BIC={bic:.2f}")
print(f"Players: {data['trustor_id'].nunique()} trustors, {data['trustee_id'].nunique()} trustees")
print(f"Conditions: {data['condition'].unique()}")
PYEOF

echo "=== Solution complete ==="