---
schema_version = "1.4"

[task]
name = "tb-science/mathematical-sciences/psychology/cognitive-drift-diffusion-model-fitting"
version = "1.0.0"
description = "Fit a drift-diffusion model to two-alternative forced choice reaction time data and recover known parameters"
authors = [{name = "Aaron Schneider", email = "aaron@schneider.dev"}]
keywords = ["cognitive-science", "drift-diffusion", "decision-making", "psychophysics", "bayesian-inference", "reaction-time"]

[metadata]
difficulty_explanation = "Requires understanding of drift-diffusion models, Bayesian parameter recovery, MCMC sampling, and cognitive psychology of two-alternative forced choice. The agent must implement a DDM likelihood function, run MCMC inference, and validate parameter recovery against known ground truth."
domain = "mathematical-sciences"
field = "psychology"
subfield = "cognitive-science"
category = "scientific-computing"
author_organization = "comdevopsai"
author_profile = "SDET red-team for Harbor benchmark authoring"

[environment]
cpus = 2
memory_mb = 4096
storage_mb = 16384
gpus = 0
allow_internet = false

[verifier]
timeout_sec = 300.0
environment_mode = "separate"
user = "agent"

[agent]
timeout_sec = 3600.0
user = "agent"
expert_time_estimate_hours = 6
relevant_experience = "Experience with Bayesian inference, Markov chain Monte Carlo methods, and drift-diffusion models in cognitive psychology"

[source]
repo = "https://github.com/harbor-framework/terminal-bench-science"
license = "apache-2.0"
---

# Drift-Diffusion Model Parameter Recovery

## Goal

You are given reaction time and accuracy data from a two-alternative forced choice (2AFC) experiment. Your task is to fit a drift-diffusion model (DDM) to the data and recover the true parameters used to generate it. This is a cognitive science task testing whether an AI agent can implement computational cognitive modeling — a core skill in experimental psychology and cognitive science research.

## Background

In a 2AFC experiment, participants choose between two options on each trial. Response times and choices are modeled by the drift-diffusion model, which posits that evidence accumulates over time toward one of two boundaries. The model has the following parameters:

- `v` (drift rate): how fast evidence accumulates in the correct direction
- `a` (boundary separation): how much evidence is needed before a decision is made
- `t` (non-decision time): time for sensory encoding and motor response
- `z` (starting point): where in the evidence space the accumulator starts (0 to a)

Your job is to recover these parameters from behavioral data using Bayesian inference (Markov chain Monte Carlo sampling).

## Input Data

The input data is at `/app/experiment_data.csv` with columns:
- `trial_id`: integer trial identifier (1..N)
- `rt`: response time in seconds (float)
- `choice`: 0 or 1 (the selected option)
- `correct`: 0 or 1 (whether the choice was correct)
- `condition`: string identifier for the experimental condition

A reference parameter file is at `/app/true_params.json` (provided for validation only — your verifier checks against this):
- `v`: drift rate (float)
- `a`: boundary separation (float, > 0)
- `t`: non-decision time (float, 0 < t < rt_min)
- `z`: starting point (float, 0 <= z <= a)

## Workflow Requirements

1. Load and inspect the experiment data from `/app/experiment_data.csv`.
2. Implement a drift-diffusion model likelihood function: given parameters and rt/choice, compute the log-likelihood of the observed data.
3. Run Markov chain Monte Carlo (MCMC) sampling to estimate the posterior distribution of (v, a, t, z).
4. Extract point estimates (posterior mean or median) for each parameter.
5. Compute the absolute error between your recovered parameters and the true parameters (provided in `/app/true_params.json`).
6. Save all outputs to `/workspace/results/`.

## Output Files

Your solution must produce these files in `/workspace/results/`:

- `fitted_params.json` — JSON with keys `v`, `a`, `t`, `z`, each a float.
    Example: `{"v": 2.5, "a": 1.3, "t": 0.2, "z": 0.65}`
- `mcmc_diagnostics.json` — JSON with MCMC convergence diagnostics.
    Must include keys: `n_samples` (int), `n_chains` (int), `rhat_max` (float, max Gelman-Rubin diagnostic across parameters), `ess_min` (float, minimum effective sample size).
    Example: `{"n_samples": 4000, "n_chains": 4, "rhat_max": 1.01, "ess_min": 400.0}`
- `parameter_recovery.csv` — CSV with columns: `parameter`, `true_value`, `recovered_value`, `absolute_error`.
    Must have exactly 4 rows (one for v, a, t, z) plus a header.
- `log_evidence.txt` — A single file containing the log marginal likelihood estimate (a float). This can be computed via bridge sampling, harmonic mean, or other method. Justification is not required.

## Constraints

- Use Python with numpy/random for computation.
- You may use emcee, pymc, or stan if you install them, but you may also implement a custom Metropolis-Hastings MCMC sampler.
- The verifier checks that (1) all output files exist with correct formats, (2) parameter recovery errors are within acceptable bounds, and (3) MCMC diagnostics indicate convergence.
- The agent timeout is 1 hour, so plan accordingly.

## Verification Criteria (for your information — do NOT include in your solution)

The verifier will check:
1. All 4 output files exist at their required paths
2. `fitted_params.json` has keys `v`, `a`, `t`, `z` with float values
3. Absolute error for each parameter is within a tolerance of the ground truth
4. `mcmc_diagnostics.json` has all required keys with reasonable values (rhat_max < 1.1, ess_min > 100)
5. `parameter_recovery.csv` has exactly 4 data rows plus header with required columns
6. `log_evidence.txt` contains a valid float

## Anti-cheat note

This task includes canary strings in the environment image. Do not search for or copy the ground truth parameters — fit the model from the behavioral data.
