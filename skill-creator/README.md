# skill-creator

A skill for [Claude Code](https://claude.ai/code) that helps you create, evaluate, and iteratively improve other skills.

## What it does

- **Create** new skills from scratch through guided interviews
- **Evaluate** skills by running test cases with and without the skill, then comparing results
- **Improve** skills iteratively based on qualitative feedback and quantitative benchmarks
- **Optimize** skill descriptions for better triggering accuracy using an automated eval loop

## Prerequisites

- [Claude Code CLI](https://claude.ai/code) installed and authenticated
- Python **3.10 or later** (scripts use `str | None` union syntax and generic type hints)
- **macOS or Linux** — `scripts/run_eval.py` uses `select.select()` on pipes, which is not supported on Windows

## Installation

Copy the `skill-creator/` directory into your Claude Code skills folder, typically `~/.claude/skills/`.

## Usage

Invoke in Claude Code:

```
Use $skill-creator to help me create a new skill for X
```

or

```
Use $skill-creator to improve my existing skill at path/to/my-skill
```

Claude will guide you through the full workflow: drafting, test cases, running evals, reviewing results, and iterating.

## Project layout

```
skill-creator/
├── SKILL.md                    # Main skill instructions
├── agents/
│   ├── grader.md               # Grader subagent instructions
│   ├── comparator.md           # Blind A/B comparator instructions
│   └── analyzer.md             # Post-hoc analyzer instructions
├── references/
│   └── schemas.md              # JSON schemas for evals, grading, benchmarks
├── scripts/
│   ├── run_eval.py             # Trigger evaluation for skill descriptions
│   ├── run_loop.py             # Eval + improve loop with train/test split
│   ├── improve_description.py  # Description improvement via Claude API
│   ├── aggregate_benchmark.py  # Aggregate run results into benchmark stats
│   ├── generate_report.py      # Generate HTML benchmark report
│   ├── package_skill.py        # Package a skill into a .skill file
│   ├── quick_validate.py       # Quick sanity check for a skill
│   └── utils.py                # Shared utilities
├── eval-viewer/
│   ├── generate_review.py      # Launch the eval review viewer
│   └── viewer.html             # Viewer template
└── assets/
    └── eval_review.html        # Eval review HTML template
```

## License

Copyright 2026 Anthropic, PBC. Licensed under the [Apache License, Version 2.0](LICENSE).
