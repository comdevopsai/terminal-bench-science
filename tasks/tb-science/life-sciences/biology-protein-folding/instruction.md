# Protein Folding Structure Prediction

## Goal

Run a molecular dynamics simulation to predict the 3D structure of a small protein (ubiquitin, 76 residues). Your task is to:

1. Install a molecular dynamics package (GROMACS or OpenMM).
2. Download the ubiquitin PDB structure (1UBQ).
3. Set up the simulation system (solvate, add ions, energy minimization).
4. Run a 10ns simulation.
5. Analyze the trajectory and compute the RMSD of the final structure relative to the crystal structure.

## Input Data

- PDB file: Download from RCSB PDB (https://files.rcsb.org/download/1UBQ.pdb)

## Expected Outputs

- `/workspace/results/rmsd.txt` — A single line containing the RMSD value in Angstroms (float). Example: `2.34`
- `/workspace/results/trajectory.xtc` — The final simulation trajectory file.

## Constraints

- The simulation must complete within 1 hour wall time.
- Use water model TIP3P and ion concentration 0.15M NaCl.
- Energy minimization must converge (max force < 1000 kJ/mol/nm).
- RMSD is computed on C-alpha atoms only.

## Verification

The test script will verify:
1. `/workspace/results/rmsd.txt` exists and contains a valid float.
2. The RMSD value is within the expected range (1.0–5.0 Å for ubiquitin with standard force fields).
3. `/workspace/results/trajectory.xtc` exists and is non-empty.