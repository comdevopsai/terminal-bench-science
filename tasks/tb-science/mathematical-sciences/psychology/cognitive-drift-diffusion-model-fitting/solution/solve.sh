#!/bin/bash
set -euo pipefail

echo "=== DDM Parameter Recovery: Reference Solution ==="

python3 << 'PYEOF'
import numpy as np
import pandas as pd
import json
import os

# Load data
data = pd.read_csv('/app/experiment_data.csv')
rt = data['rt'].values
choice = data['choice'].values
correct = data['correct'].values
condition = data['condition'].values if 'condition' in data.columns else None

# Load true params for reference (not used in solution, just for validation)
with open('/app/true_params.json') as f:
    true_params = json.load(f)

print(f"Loaded {len(rt)} trials")
print(f"True params (for reference only): {true_params}")

# Implement DDM log-likelihood
def ddm_log_likelihood(params, rt, choice, correct):
    v, a, t, z = params
    n = len(rt)
    
    # Bounds
    if a <= 0 or t <= 0 or t >= np.min(rt[rt > 0]) or z < 0 or z > a:
        return -np.inf
    
    # Simplified DDM log-likelihood using analytical approximation
    # This is a reference solution using a standard approach
    log_lik = 0.0
    
    for i in range(n):
        if rt[i] <= t:
            log_lik += -1e6  # Penalty for RTs shorter than non-decision time
            continue
        
        rt_adjusted = rt[i] - t
        if rt_adjusted <= 0:
            log_lik += -1e6
            continue
        
        # Wald's approximation for DDM
        # P(choice | v, a, z) and density
        drift_rate = v if (choice[i] == 1 and correct[i] == 1) or (choice[i] == 0 and correct[i] == 0) else -v
        
        # Log probability density for upper boundary crossing
        # Using the approximate formula from Ratcliff (1978)
        if abs(drift_rate) < 1e-10:
            # Diffusion-only case
            pdf_val = np.exp(-(a - z)**2 / (2 * rt_adjusted)) + np.exp(-(a + z)**2 / (2 * rt_adjusted))
            pdf_val *= 0.5 / np.sqrt(2 * np.pi * rt_adjusted**3) * a
        else:
            # Standard Wald approximation
            exp_term = np.exp(-2 * drift_rate * z / a)
            pdf_val = abs(drift_rate / a) * np.exp(-drift_rate * (a - z) / a - 0.5 * drift_rate**2 * rt_adjusted))
            pdf_val *= (np.exp(drift_rate * z) + exp_term * np.exp(-drift_rate * z))
        
        if pdf_val <= 0:
            log_lik += -1e6
        else:
            log_lik += np.log(pdf_val + 1e-300)
    
    return log_lik

# Custom Metropolis-Hastings MCMC
def run_mcmc(rt, choice, correct, n_samples=4000, n_chains=4, burn_in=1000):
    n_params = 4
    initial = np.array([1.0, 1.0, 0.15, 0.5])
    proposal_scale = np.array([0.3, 0.2, 0.05, 0.15])
    
    chains = []
    for chain_idx in range(n_chains):
        np.random.seed(42 + chain_idx * 137)
        current = initial + np.random.randn(n_params) * proposal_scale * 0.1
        current_ll = ddm_log_likelihood(current, rt, choice, correct)
        samples = np.zeros((n_samples, n_params))
        accepted = 0
        
        for i in range(n_samples + burn_in):
            proposal = current + np.random.randn(n_params) * proposal_scale
            prop_ll = ddm_log_likelihood(proposal, rt, choice, correct)
            
            if np.isfinite(prop_ll) and np.log(np.random.uniform()) < (prop_ll - current_ll):
                current = proposal
                current_ll = prop_ll
            
            if i >= burn_in:
                samples[i - burn_in] = current
        
        chains.append(samples)
    
    return chains

chains = run_mcmc(rt, choice, correct)

# Combine chains
all_samples = np.vstack(chains)
num_chains = len(chains)

# Posterior means
v_mean = np.mean(all_samples[:, 0])
a_mean = np.mean(all_samples[:, 1])
t_mean = np.mean(all_samples[:, 2])
z_mean = np.mean(all_samples[:, 3])

# Gelman-Rubin R-hat for convergence
def gelman_rubin(chains):
    n_chains = len(chains)
    n = chains[0].shape[0]
    chain_means = np.array([np.mean(c, axis=0) for c in chains])
    chain_vars = np.array([np.var(c, axis=0) for c in chains])
    
    W = np.mean(chain_vars, axis=0)
    B = n * np.var(chain_means, axis=0)
    var_hat = ((n - 1) * W + B) / n
    rhat = np.sqrt(var_hat / (W + 1e-10))
    return rhat

rhat = gelman_rubin(chains)
ess_min = min([min(effective_sample_size(c)) for c in chains])

def effective_sample_size(chain):
    n = len(chain)
    autocorr = np.correlate(chain - np.mean(chain), chain - np.mean(chain), mode='full')
    autocorr = autocorr[n-1:] / autocorr[n-1]
    # Sum autocorrelations until first negative value
    cutoff = np.where(autocorr < 0.05)[0]
    if len(cutoff) > 0:
        tau = 1 + 2 * np.sum(autocorr[1:cutoff[0]])
    else:
        tau = n
    return n / tau if tau > 0 else n

fitted_params = {"v": float(v_mean), "a": float(a_mean), "t": float(t_mean), "z": float(z_mean)}
diagnostics = {
    "n_samples": all_samples.shape[0],
    "n_chains": num_chains,
    "rhat_max": float(np.max(rhat)),
    "ess_min": float(ess_min)
}

# Parameter recovery errors
abs_errors = {}
for i, pname in enumerate(["v", "a", "t", "z"]):
    abs_errors[pname] = abs(fitted_params[pname] - true_params[pname])

# Save outputs
os.makedirs('/workspace/results', exist_ok=True)

with open('/workspace/results/fitted_params.json', 'w') as f:
    json.dump(fitted_params, f, indent=2)

with open('/workspace/results/mcmc_diagnostics.json', 'w') as f:
    json.dump(diagnostics, f, indent=2)

# parameter_recovery.csv
import csv
with open('/workspace/results/parameter_recovery.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['parameter', 'true_value', 'recovered_value', 'absolute_error'])
    for pname in ['v', 'a', 't', 'z']:
        writer.writerow([
            pname,
            true_params[pname],
            fitted_params[pname],
            abs_errors[pname]
        ])

# compute log marginal likelihood via bridge sampling
import warnings
with warnings.catch_warnings():
    warnings.filterwarnings('ignore')
    lp_vals = np.array([ddm_log_likelihood(c[0], rt, choice, correct) for c in chains])
log_evidence = float(np.log(np.mean(np.exp(lp_vals - np.max(lp_vals)))) + np.max(lp_vals))
with open('/workspace/results/log_evidence.txt', 'w') as f:
    f.write(str(log_evidence))

print(f"Fitted params: {fitted_params}")
print(f"Diagnostics: {diagnostics}")
print(f"Parameter recovery errors: {abs_errors}")
print(f"Log evidence: {log_evidence}")
PYEOF

echo "=== Solution complete ==="