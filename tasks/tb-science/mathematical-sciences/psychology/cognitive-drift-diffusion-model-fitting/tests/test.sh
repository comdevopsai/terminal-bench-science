#!/bin/bash
set -euo pipefail

echo "=== Verifier: DDM Parameter Recovery ==="

RESULTS_DIR="/workspace/results"

# Check all output files exist
for f in fitted_params.json mcmc_diagnostics.json parameter_recovery.csv log_evidence.txt; do
    if [ ! -f "$RESULTS_DIR/$f" ]; then
        echo "FAIL: $RESULTS_DIR/$f not found"
        exit 1
    fi
done

# Check fitted_params.json has correct keys
for key in v a t z; do
    if ! python3 -c "import json; d=json.load(open('$RESULTS_DIR/fitted_params.json')); assert '$key' in d" 2>/dev/null; then
        echo "FAIL: fitted_params.json missing key '$key'"
        exit 1
    fi
done

# Check parameter recovery errors (absolute error < threshold)
if ! python3 -c "
import json, csv

with open('/app/true_params.json') as f:
    true_params = json.load(f)
with open('$RESULTS_DIR/fitted_params.json') as f:
    fitted = json.load(f)

for pname in ['v', 'a', 't', 'z']:
    error = abs(fitted[pname] - true_params[pname])
    if error > 0.5:  # generous tolerance for MCMC
        print(f'FAIL: {pname} absolute error {error} exceeds tolerance')
        exit(1)
print('PASS: All parameter recovery errors within tolerance')
" 2>/dev/null; then
    echo "FAIL: Parameter recovery errors too large"
    exit 1
fi

# Check MCMC diagnostics
if ! python3 -c "
import json
with open('$RESULTS_DIR/mcmc_diagnostics.json') as f:
    diag = json.load(f)

for key in ['n_samples', 'n_chains', 'rhat_max', 'ess_min']:
    if key not in diag:
        print(f'FAIL: Missing key {key}')
        exit(1)

if diag['rhat_max'] >= 1.1:
    print(f'FAIL: rhat_max {diag[\"rhat_max\"]} >= 1.1 (not converged)')
    exit(1)

if diag['ess_min'] < 100:
    print(f'FAIL: ess_min {diag[\"ess_min\"]} < 100 (insufficient)')
    exit(1)

print('PASS: MCMC diagnostics indicate convergence')
" 2>/dev/null; then
    echo "FAIL: MCMC diagnostics do not indicate convergence"
    exit 1
fi

# Check parameter_recovery.csv format
if ! python3 -c "
import csv
with open('$RESULTS_DIR/parameter_recovery.csv') as f:
    reader = csv.reader(f)
    rows = list(reader)
    if len(rows) != 5:  # header + 4 rows
        print(f'FAIL: Expected 5 rows, got {len(rows)}')
        exit(1)
    if rows[0] != ['parameter', 'true_value', 'recovered_value', 'absolute_error']:
        print(f'FAIL: Wrong header: {rows[0]}')
        exit(1)
    params_found = set()
    for row in rows[1:]:
        params_found.add(row[0])
    for p in ['v', 'a', 't', 'z']:
        if p not in params_found:
            print(f'FAIL: Missing parameter {p}')
            exit(1)
    print('PASS: parameter_recovery.csv format correct')
" 2>/dev/null; then
    echo "FAIL: parameter_recovery.csv format incorrect"
    exit 1
fi

# Check log_evidence.txt contains a valid float
if ! python3 -c "
with open('$RESULTS_DIR/log_evidence.txt') as f:
    content = f.read().strip()
    float(content)
print('PASS: log_evidence.txt contains valid float')
" 2>/dev/null; then
    echo "FAIL: log_evidence.txt does not contain a valid float"
    exit 1
fi

echo "PASS: All verifier checks passed"
exit 0