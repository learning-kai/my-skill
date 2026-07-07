# Task Decomposer

![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Platform](https://img.shields.io/badge/platform-Codex%20Skill-black)

[简体中文](README.zh-CN.md)

First-principles task decomposition for turning vague, oversized, or multi-agent work into executable plans.

## Why

Most task plans are polite filler: research, design, implement, test. Task Decomposer forces the agent to start from outcome, current state, gaps, required transformations, verification, and dependencies before it creates tasks.

## Core Features

- Sanity gate for impossible, contradictory, or bloated goals.
- Granularity alignment from `G0` goal-level plans to `G4` command-level operations.
- Default `G3` atomic tasks with inputs, outputs, dependencies, and completion criteria.
- Five-view internal contest mode: strategist, executor, skeptic, minimalist, and parallelizer.
- Final-only output policy: internal agent drafts are not exposed unless audit/debug mode is requested.
- DAG-first execution planning with explicit `depends_on` relationships.

## Screenshots & Demo

This is a text workflow skill, so screenshots are not useful proof. A typical trigger is:

```text
Use $task-decomposer to break this project into executable tasks and align the granularity first.
```

## Quick Start

Install into Codex on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/learning-kai/my-skill/main/task-decomposer/install.sh | bash
```

Install into Codex on Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/learning-kai/my-skill/main/task-decomposer/install.ps1 | iex
```

Manual install paths:

| Agent | Path |
|---|---|
| Codex | `%USERPROFILE%\.codex\skills\task-decomposer` or `$HOME/.codex/skills/task-decomposer` |
| Claude Code | `%USERPROFILE%\.claude\skills\task-decomposer` or `$HOME/.claude/skills/task-decomposer` |
| Kiro | Copy the folder into the configured Kiro skills directory |

## Engineering Quality

- `SKILL.md` validates with the official `skill-creator` `quick_validate.py` script.
- The skill was smoke-tested against ordinary planning and intentionally unrealistic scope-explosion prompts.
- No runtime dependencies are required for normal skill use.

## Project Docs

- [`SKILL.md`](SKILL.md): the actual skill instructions.
- [`agents/openai.yaml`](agents/openai.yaml): Codex UI metadata.
- [`install.sh`](install.sh) and [`install.ps1`](install.ps1): source install helpers.

## Privacy & Security

The skill does not call external services by itself. In contest mode it may instruct Codex to use available subagent tooling, but it does not store internal drafts unless the user explicitly requests audit/debug retention.

## Release & Updates

No GitHub Release has been cut yet. The latest release page will be available at [releases/latest](https://github.com/learning-kai/my-skill/releases/latest) once release assets are published.

## Roadmap

- Add packaged `.skill` release assets.
- Add optional examples for product planning, codebase refactors, and research workflows.
- Add stricter smoke-test prompts for multi-agent dispatch plans.

## Contributing

Keep the skill compact. Do not add decorative files, generic planning templates, or extra agent roles unless they solve a real failure observed in testing.

## Troubleshooting

- If Codex does not discover the skill, confirm the folder is named `task-decomposer` and contains `SKILL.md`.
- On Windows, run validation with `PYTHONUTF8=1` if Python defaults to `gbk` and fails to read Chinese text.

## License

MIT. See [`LICENSE`](LICENSE).
