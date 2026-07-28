#!/bin/bash
set -euo pipefail

echo "=== Terminal-Bench Science: Protein Folding Verifier ==="

# Check RMSD file exists
if [ ! -f /workspace/results/rmsd.txt ]; then
    echo "FAIL: /workspace/results/rmsd.txt not found"
    exit 1
fi

# Check trajectory file exists and is non-empty
if [ ! -s /workspace/results/trajectory.xtc ]; then
    echo "FAIL: /workspace/results/trajectory.xtc not found or empty"
    exit 1
fi

# Read RMSD value
RMSD=$(cat /workspace/results/rmsd.txt | tr -d '[:space:]')

# Validate it's a valid float
if ! echo "$RMSD" | grep -qE '^[0-9]+\.?[0-9]*$'; then
    echo "FAIL: rmsd.txt does not contain a valid float: '$RMSD'"
    exit 1
fi

# Check RMSD is in expected range (1.0 - 5.0 Angstroms)
PASS=$(python3 -c "
try:
    rmsd = float('$RMSD')
    if 1.0 <= rmsd <= 5.0:
        print('PASS')
    else:
        print(f'FAIL: RMSD {rmsd} outside expected range [1.0, 5.0]')
except ValueError:
    print('FAIL: could not parse RMSD as float')
")

echo "$PASS"

if [ "$PASS" = "PASS" ]; then
    echo "All checks passed."
    exit 0
else
    echo "$PASS"
    exit 1
fi