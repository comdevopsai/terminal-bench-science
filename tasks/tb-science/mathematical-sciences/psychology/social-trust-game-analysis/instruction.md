# Social Trust Game Analysis

## Goal

You are given behavioral data from an iterated Prisoner's Dilemma trust game with multiple rounds between paired participants. Your task is to estimate social preference parameters using maximum likelihood estimation. This is a social psychology task testing the agent's ability to analyze behavioral economics data and extract theoretically meaningful social preference parameters.

## Background

In a trust game, a "trustor" is given an initial endowment and decides how much to send to a "trustee". The sent amount is tripled, and the trustee decides how much to return. This paradigm measures social preferences including trust (willingness to take a risk on another person) and reciprocity (tendency to return trust).

The Fehr-Schmidt (1999) model of inequity aversion is commonly used to fit trust game data. The model has the following parameters for each player:

- `alpha_i`: aversion to disadvantageous inequality (willingness to sacrifice to reduce disadvantageous inequality)
- `beta_i`: aversion to advantageous inequality (willingness to sacrifice to reduce advantageous inequality)

The utility function for player i in trial t is:
```
U_i(x_i, x_j) = x_i - alpha_i * max(x_j - x_i, 0) - beta_i * max(x_i - x_j, 0)
```
where x_i and x_j are the payoffs of players i and j.

## Input Data

The input data is at `/app/trust_game_data.csv` with columns:
- `trial_id`: integer trial identifier (1..N)
- `round_num`: integer round number (1..R)
- `trustor_id`: identifier for the trustor
- `trustee_id`: identifier for the trustee
- `offer`: amount sent by trustor (float, 0 to 10)
- `return_amount`: amount returned by trustee (float)
- `trustor_payoff`: trustor's payoff in this round (float)
- `trustee_payoff`: trustee's payoff in this round (float)
- `condition`: "in-group" or "out-group"

A reference parameter file is at `/app/true_params.json` (provided for validation only — your verifier checks against this):
- `alpha_trustor`: float (disadvantageous inequality aversion for trustor, range [0, 3])
- `beta_trustor`: float (advantageous inequality aversion for trustor, range [0, 1.5])
- `alpha_trustee`: float (disadvantageous inequality aversion for trustee, range [0, 3])
- `beta_trustee`: float (advantageous inequality aversion for trustee, range [0, 1.5])
- `trustor_offer_bias`: float (baseline tendency for trustors to send, range [0, 10])

## Workflow Requirements

1. Load and inspect the trust game data from `/app/trust_game_data.csv`.
2. For each round, compute the trustor's offer (amount sent) and trustee's return as a proportion of what was received.
3. Implement the Fehr-Schmidt (1999) inequity aversion model log-likelihood function given parameters and observed choices.
4. Run maximum likelihood estimation (MLE) to estimate the population-level parameters (alpha, beta for both trustor and trustee, plus offer bias).
5. Compute model fit statistics: log-likelihood at optimum, AIC, BIC.
6. Save all outputs to `/workspace/results/`.

## Output Files

Your solution must produce these files in `/workspace/results/`:

- `fitted_params.json` — JSON with keys `alpha_trustor`, `beta_trustor`, `alpha_trustee`, `beta_trustee`, `trustor_offer_bias`. All float values.
    Example: `{"alpha_trustor": 0.5, "beta_trustor": 0.3, "alpha_trustee": 0.7, "beta_trustee": 0.2, "trustor_offer_bias": 3.5}`
- `model_fit.json` — JSON with keys `log_likelihood` (float), `aic` (float), `bic` (float), `n_observations` (int), `n_parameters` (int).
    Example: `{"log_likelihood": -150.3, "aic": 310.6, "bic": 328.9, "n_observations": 100, "n_parameters": 5}`
- `individual_params.csv` — CSV with columns `player_id`, `player_type`, `alpha`, `beta`. One row per unique player.
    Must have header + at least 2 rows (at least 2 distinct players).
- `offer_by_condition.csv` — CSV with columns `condition`, `mean_offer`, `median_offer`, `n_trials`. One row per condition ("in-group", "out-group").
    Must have header + 2 data rows.

## Constraints

- Use Python with numpy/random for computation.
- You may use scipy.optimize.minimize for MLE but may also implement a custom optimizer.
- The verifier checks that (1) all output files exist with correct formats, (2) parameters are within reasonable bounds, (3) model fit metrics are computed correctly, and (4) individual parameter estimates exist for at least 2 players.
- The agent timeout is 1 hour, so plan accordingly.

## Verification Criteria (for your information — do NOT include in your solution)

The verifier will check:
1. All 4 output files exist at their required paths
2. `fitted_params.json` has all 5 required keys with float values within bounds
3. `model_fit.json` has all required keys with float values, and AIC/BIC relationship is correct (AIC = 2k - 2lnL)
4. `individual_params.csv` has at least 2 rows and required columns
5. `offer_by_condition.csv` has exactly 2 data rows (in-group, out-group) with correct columns
6. All numerical values are finite (no NaN or Inf)

## Anti-cheat note

This task includes canary strings in the environment image. Do not search for or copy the ground truth parameters — fit the model from the behavioral data.