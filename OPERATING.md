# Operating Rules — Terminal-Bench Science Benchmark

## Phase Gates

All phases are tracked against the `raw_log.md` append-only provenance log.
Each phase must complete before the next begins.

### Phase 0: Scaffold (DONE)
- [x] Create project directory structure at `~/terminal-bench-science/`
- [x] Scaffold initial task (`tb-science/life-sciences/biology-protein-folding`)
- [x] Create `COLLECTION.md`, `OPERATING.md`, `raw_log.md`

### Phase 1: Research (DONE)
- [x] Fetch Harbor framework task configuration docs
- [x] Scrape terminal-bench-science GitHub repo (`tasks/`, `rubrics/`, `CONTRIBUTING.md`)
- [x] Scrape Task Dashboard snapshot (`stevendillmann.github.io/tb-science-task-dashboard/`)
- [x] Pull merged PRs list via `gh api` (118 merged PRs)
- [x] Pull open task proposals via `gh api` (106 proposals)
- [x] Identify domain gaps: cognitive science / social psychology (`mathematical-sciences/psychology`) is underrepresented

### Phase 2: Analyze Accepted Tasks (DONE)
- [x] Reviewed merged PRs for cognitive/social-psychology domain tasks
- [x] Found task proposals: ADHD neuroimaging (#40, #57, #58, #64, #74), fMRI (#10, #17, #42, #59, #76, #79, #82), EEG (#17, brain-age gap #55)
- [x] Reviewed contributing guide: 3-stage process (Propose → Build → Review), August 17 2026 deadline
- [x] Reviewed Task Proposal Rubric (7 criteria: Verifiable, Well-specified, Solvable, Difficult, Scientifically Grounded & Interesting, Scope, Outcome-verified) and Task Implementation Rubric (13 criteria)
- [x] Identified domain mapping: cognitive science & social psychology → `mathematical-sciences` domain, `psychology` field, `cognitive-science` / `social-psychology` subfields

### Phase 3: Update Skills (IN_PROGRESS)
- [x] `harbor-task-authoring`: Added cognitive/social-psychology task patterns section (Cognitive Science Task Patterns, Social Psychology Task Patterns, Task Design Considerations, Common Pitfalls)
- [x] `terminal-bench-science-setup`: Added cognitive/social-psychology to domain table, added 3-stage contribution process, added Quick Start for cognitive/social psychology tasks
- [x] `harbor-evaluation`: Already includes scientific computing eval workflow (no changes needed)
- [x] `harbor-task-publishing`: Already includes Harbor hub publishing instructions (no changes needed)

### Phase 4: Create Task Skeleton (IN_PROGRESS)
- [x] Created `cognitive-drift-diffusion-model-fitting` task skeleton
  - `task.toml` — Harbor 1.4 config, mathematical-sciences/psychology/cognitive-science
  - `instruction.md` — DDM parameter recovery from 2AFC data
  - `environment/Dockerfile` — Python 3.11 + numpy/scipy/pandas/emcee/arviz/pymc
  - `solution/solve.sh` — Reference Metropolis-Hastings MCMC implementation
  - `tests/test.sh` — Verifier checks all 4 output files, parameter recovery errors, MCMC convergence, CSV format

### Phase 5: Scaffold Second Task (PENDING)
- [ ] Create social-trust-game-analysis task skeleton under `mathematical-sciences/psychology/social-psychology/`

### Phase 6: Validate (BLOCKED)
- [ ] Wait for Harbor CLI installation before running `harbor validate`
- [ ] NO benchmark tests until Aaron authorizes

### Phase 7: Commit & Push (PENDING)
- [ ] Commit skills + task skeletons to `comdevopsai/skills`
- [ ] Commit task project to `comdevopsai/terminal-bench-science`

### Phase 8: Report (PENDING)
- [ ] Respond to Aaron with findings and next steps