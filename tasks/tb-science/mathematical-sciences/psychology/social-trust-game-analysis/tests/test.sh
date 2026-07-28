#!/bin/bash
set -euo pipefail

echo "=== Verifier: Social Trust Game Analysis ==="

RESULTS_DIR="/workspace/results"

# Check all output files exist
for f in fitted_params.json model_fit.json individual_params.csv offer_by_condition.csv; do
    if [ ! -f "$RESULTS_DIR/$f" ]; then
        echo "FAIL: $RESULTS_DIR/$f not found"
        exit 1
    fi
done

# Check fitted_params.json has correct keys and valid bounds
if ! python3 -c "
import json
with open('$RESULTS_DIR/fitted_params.json') as f:
    params = json.load(f)
required = ['alpha_trustor', 'beta_trustor', 'alpha_trustee', 'beta_trustee', 'trustor_offer_bias']
for k in required:
    if k not in params:
        print(f'FAIL: Missing key {k}')
        exit(1)
    if not isinstance(params[k], (int, float)) or not (np.isfinite(params[k])):
        print(f'FAIL: {k} is not a finite float')
        exit(1)
# Bounds checks
if not (0 <= params['alpha_trustor'] <= 3):
    print(f'FAIL: alpha_trustor {params[\"alpha_trustor\"]} out of bounds [0, 3]')
    exit(1)
if not (0 <= params['beta_trustor'] <= 1.5):
    print(f'FAIL: beta_trustor {params[\"beta_trustor\"]} out of bounds [0, 1.5]')
    exit(1)
print('PASS: fitted_params.json valid')
" 2>/dev/null; then
    echo "FAIL: fitted_params.json invalid"
    exit 1
fi

# Check model_fit.json
if ! python3 -c "
import json
with open('$RESULTS_DIR/model_fit.json') as f:
    fit = json.load(f)
required = ['log_likelihood', 'aic', 'bic', 'n_observations', 'n_parameters']
for k in required:
    if k not in fit:
        print(f'FAIL: Missing key {k}')
        exit(1)
# AIC = 2k - 2*LL
expected_aic = 2 * fit['n_parameters'] - 2 * fit['log_likelihood']
if abs(fit['aic'] - expected_aic) > 0.01:
    print(f'FAIL: AIC mismatch: expected {expected_aic}, got {fit[\"aic\"]}')
    exit(1)
print('PASS: model_fit.json valid')
" 2>/dev/null; then
    echo "FAIL: model_fit.json invalid"
    exit 1
fi

# Check individual_params.csv has at least 2 players
if ! python3 -c "
import csv
with open('$RESULTS_DIR/individual_params.csv') as f:
    reader = csv.DictReader(f)
    rows = list(reader)
if len(rows) < 2:
    print(f'FAIL: Need at least 2 players, got {len(rows)}')
    exit(1)
required_cols = ['player_id', 'player_type', 'alpha', 'beta']
for col in required_cols:
    if col not in rows[0]:
        print(f'FAIL: Missing column {col}')
        exit(1)
print('PASS: individual_params.csv valid')
" 2>/dev/null; then
    echo "FAIL: individual_params.csv invalid"
    exit 1
fi

# Check offer_by_condition.csv has exactly 2 data rows
if ! python3 -c "
import csv
with open('$RESULTS_DIR/offer_by_condition.csv') as f:
    reader = csv.DictReader(f)
    rows = list(reader)
if len(rows) != 2:
    print(f'FAIL: Expected 2 condition rows, got {len(rows)}')
    exit(1)
required_cols = ['condition', 'mean_offer', 'median_offer', 'n_trials']
for col in required_cols:
    if col not in rows[0]:
        print(f'FAIL: Missing column {col}')
        exit(1)
conditions = {r['condition'] for r in rows}
if conditions != {'in-group', 'out-group'}:
    print(f'FAIL: Expected in-group and out-group, got {conditions}')
    exit(1)
print('PASS: offer_by_condition.csv valid')
" 2>/dev/null; then
    echo "FAIL: offer_by_condition.csv invalid"
    exit 1
fi

# Check no NaN or Inf values
if ! python3 -c "
import json, csv, math
import glob as glob_lib

all_files = [
    '$RESULTS_DIR/fitted_params.json',
    '$RESULTS_DIR/model_fit.json',
]
for fpath in all_files:
    with open(fpath) as f:
        data = json.load(f)
    for k, v in data.items():
        if isinstance(v, float) and (math.isnan(v) or math.isinf(v)):
            print(f'FAIL: NaN/Inf in {fpath}[{k}]')
            exit(1)
print('PASS: All values finite')
" 2>/dev/null; then
    echo "FAIL: NaN/Inf values found"
    exit 1
fi

echo "PASS: All verifier checks passed"
exit 0