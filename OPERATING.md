# Operating Rules — Terminal-Bench Science Benchmark

## Phase Gates

### Phase 0: Scaffold (DONE)
- [x] Create project directory structure
- [x] Install relevant Harbor skills
- [x] Create COLLECTION.md, OPERATING.md, raw_log.md
- [x] Scaffold first example task

### Phase 1: Task Population (TODO)
- [ ] Define 3-5 scientific workflow tasks
- [ ] Write task.toml for each task
- [ ] Write instruction.md for each task
- [ ] Create Dockerfile with scientific dependencies
- [ ] Create solution/solve.sh (reference solution)
- [ ] Create tests/test.sh (verification script)
- [ ] Run `harbor validate -p` on each task

### Phase 2: Evaluation (TODO)
- [ ] Install Harbor CLI
- [ ] Configure agent harnesses (terminus-2, claude-code, openhands)
- [ ] Run evaluations on selected models
- [ ] Collect and aggregate results

### Phase 3: Analysis (TODO)
- [ ] Categorize failures by root cause
- [ ] Compute per-model and per-task solve rates
- [ ] Produce analysis report

## Rules

1. All tasks must have a unique `<org>/<name>` format.
2. Agent timeout for scientific tasks must be >= 1800s.
3. Verifier must run as non-root user.
4. Every `harbor run` must produce results in `evaluations/`.
5. All findings go in `raw_log.md` with L### provenance entries.
6. Evaluation reports follow the format from the harbor-evaluation skill.