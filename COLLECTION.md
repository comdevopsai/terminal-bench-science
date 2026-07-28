# Terminal-Bench Science Benchmark — Research Project

## Charter

Research project to build, run, and analyze a Terminal-Bench Science benchmark using the Harbor framework. Terminal-Bench Science evaluates AI agents on real computational workflows in the natural sciences.

**Source:** https://www.harborframework.com/docs/tasks and https://github.com/harbor-framework/terminal-bench-science

## Project Overview

Terminal-Bench Science extends Terminal-Bench to scientific workflows across:
- Life Sciences (biology, ecology, medicine, neuroscience)
- Physical Sciences (astronomy, chemistry, materials science, physics)
- Earth Sciences (atmospheric, environmental, geosciences, ocean)
- Mathematical Sciences (applied math, formal math, OR, statistics)
- Engineering Sciences (chemical, civil, electrical, mechanical)

## Directory Layout

```
terminal-bench-science/
├── COLLECTION.md              # curated index of benchmark tasks
├── raw_log.md                 # append-only provenance log
├── OPERATING.md              # how this project operates
├── tasks/                     # Harbor task directories
│   ├── tb-science/
│   │   └── life-sciences/
│   │       ├── biology-protein-folding/
│   │       │   ├── task.toml
│   │       │   ├── instruction.md
│   │       │   ├── environment/
│   │       │   │   └── Dockerfile
│   │       │   ├── solution/
│   │       │   │   └── solve.sh
│   │       │   └── tests/
│   │       │       └── test.sh
│   │       └── ...
│   └── ...
├── evaluations/               # harbor run output
│   └── <task-name>/
│       └── trials/
├── datasets/                  # dataset definitions
├── rubrics/                   # evaluation rubrics per task
├── scripts/                   # automation scripts
│   ├── run_all.sh
│   ├── collect_results.py
│   └── score_analysis.py
└── assets/                    # graphs, slides, figures
```

## Status

- Scaffold created: 2026-07-28
- Skills installed: harbor-task-authoring, terminal-bench-science-setup, harbor-evaluation, harbor-task-publishing
- Next phase: populate tasks, run evaluations, analyze results