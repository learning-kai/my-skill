# publish-to-github

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4)
![PowerShell 7](https://img.shields.io/badge/PowerShell-7%2B-5391FE)
![Bash](https://img.shields.io/badge/Bash-supported-4EAA25)
![GitHub CLI](https://img.shields.io/badge/GitHub%20CLI-gh-181717)

English | [简体中文](README.zh-CN.md)

> A release-first GitHub publishing skill for Codex, Claude Code, and Kiro. It prepares ordinary projects and skill directories for GitHub with bilingual README checks, preflight gates, careful staging, and GitHub Release install assets.

`publish-to-github` turns "push this to GitHub" into a controlled publishing workflow. It checks the repository front door before touching Git: README quality, release signals, platform claims, risky files, generated artifacts, secrets, large files, validation commands, and the exact paths that should be staged.

## Why

Most GitHub publishing mistakes are not clever engineering failures. They are boring release hygiene failures: missing README context, fake badges, forgotten `.env` files, broken install commands, no release assets, or a heroic `git add .` that sweeps half the desk into the commit.

This skill exists to make publishing feel like a small release review, even for compact projects and local skills. The goal is not to decorate a repo until it looks expensive; the goal is to help users understand value, install quickly, trust the release, and avoid shipping private or sloppy files.

## Core Features

- Publishes ordinary projects and agent skill directories to GitHub.
- Republishes already-published repos: optimizes the live README, description, badges, and release with surgical fixes, or rewrites and republishes when the published repo diverges greatly from current requirements.
- Auto-detects project mode or skill mode from the target path.
- Enforces bilingual README structure: `README.md` in English and `README.zh-CN.md` in Simplified Chinese.
- Checks high-star README signals: top badges, language switch, one-line positioning, quick start, release/install path, troubleshooting, roadmap, contribution notes, and license.
- Preserves skill-specific validation for `SKILL.md`, `.skill` packages, release assets, and trigger examples.
- Keeps source publishing separate from tags and GitHub Releases unless the user explicitly confirms release creation.
- Runs read-only preflight checks for Git state, remotes, GitHub CLI auth, risky pending paths, large files, mojibake, placeholders, and common verification commands.

## Screenshots & Demo

This is a workflow skill, not a visual app. Screenshots are not the proof of value here; the useful demo is the release flow itself:

```text
preflight -> README quality gate -> validation -> exact staging -> commit -> push -> optional tag/release -> install assets
```

For visual projects that use this skill, screenshots, GIFs, demos, or an explicit asset plan are still part of the README gate. For CLI, library, automation, and skill projects, command examples, one-line install, release assets, and troubleshooting are the stronger signal.

## Quick Start

### Installation

Install the latest released skill:

```bash
curl -fsSL https://github.com/learning-kai/my-skill/releases/latest/download/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1 | iex
```

Manual install: copy or clone this directory into one of your agent skill folders.

| Agent | Default skill path |
| --- | --- |
| Codex | `C:\Users\<user>\.codex\skills\publish-to-github\` |
| Claude Code | `~/.claude/skills/publish-to-github/` |
| Kiro | Your configured Kiro skills directory |

### Typical Prompts

```text
Use publish-to-github to prepare this project and publish it to GitHub.
```

```text
Use publish-to-github to review and release my local skill directory.
```

```text
Use publish-to-github to run a high-star README review before I push.
```

```text
Use publish-to-github to optimize my already-published repo, or rewrite and republish it if it no longer matches what I want.
```

### Preflight

The bundled preflight scripts are read-only. They do not stage, commit, push, tag, release, delete, rename, or move files.

PowerShell 7:

```powershell
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode auto -ProjectName "."
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode skill -ProjectName "my-skill"
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode project -ProjectName "my-project"
```

Bash:

```bash
bash scripts/preflight.sh --repo-root /path/to/repo --mode auto --project-name .
bash scripts/preflight.sh --repo-root /path/to/repo --mode skill --project-name my-skill
bash scripts/preflight.sh --repo-root /path/to/repo --mode project --project-name my-project
```

## Engineering Quality

The skill treats README quality and repository hygiene as release gates, not afterthoughts:

- README top badges must include truthful License, release/version, and platform or tech-stack signals.
- Badge claims must come from real files or repository facts such as `LICENSE`, GitHub Releases, `.github/workflows/`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or documented platform support.
- `README.md` and `README.zh-CN.md` must link to each other near the top and expose equivalent core sections.
- The gate checks mojibake, placeholder literals, local path leaks, generated directories, cache files, secret-looking names, and pending files over 5 MB.
- When standard test/build commands exist, the publish report must run or name them. When no such command exists, the report must say that plainly.

Local verification:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\test_preflight.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\preflight.ps1 -RepoRoot .. -Mode skill -ProjectName publish-to-github
python ..\skill-creator\scripts\quick_validate.py .
```

```bash
bash -n scripts/preflight.sh
bash scripts/preflight.sh --repo-root .. --mode skill --project-name publish-to-github
```

## Project Docs

Recommended reading order:

1. [SKILL.md](SKILL.md) - workflow rules and release behavior.
2. [README.zh-CN.md](README.zh-CN.md) - Simplified Chinese README with equivalent structure.
3. [scripts/preflight.ps1](scripts/preflight.ps1) - PowerShell preflight gate.
4. [scripts/preflight.sh](scripts/preflight.sh) - Bash preflight gate.
5. [scripts/make_release.sh](scripts/make_release.sh) - skill-only packaging and GitHub Release helper.
6. [scripts/install.sh](scripts/install.sh) and [scripts/install.ps1](scripts/install.ps1) - release install assets.

## Privacy & Security

- The preflight scripts are read-only and do not mutate Git state.
- The skill does not create GitHub repositories by default; it uses the existing `origin` unless the user explicitly asks for another flow.
- The release flow asks before staging, committing, pushing, tagging, or creating GitHub Releases.
- Secret-looking files, local environment files, generated output, caches, logs, and large files are surfaced before publishing.
- README claims should not expose private local paths, machine names, tokens, credentials, databases, or backup files.

## Release & Updates

Skill releases should attach:

- `publish-to-github.skill`
- `scripts/install.sh`
- `scripts/install.ps1`

Package and release one skill:

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --skill-name publish-to-github
```

Package and release every skill found in a repository:

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --all --notes "Initial skill release"
```

Ordinary project releases should create tags and GitHub Releases only when the user asks. They should not produce `.skill` packages unless the target is actually a skill.

## Roadmap

- Keep the Kaoyan-style README gate aligned across PowerShell and Bash.
- Add more precise detection for project type, package manager, and platform badge recommendations.
- Add optional Markdown link checks when a suitable checker is available.
- Improve release note templates for ordinary projects and skills.
- Expand fixture coverage for missing badge categories and visual-project screenshot warnings.

## Contributing

Keep changes narrow, run the preflight tests, and keep the bilingual README pair synchronized. If a badge or claim cannot be proven from the repository, do not add it. High-star polish is useful; fake confidence is just technical debt wearing a nice jacket.

## Troubleshooting

- **No remote is configured**: add a GitHub remote or provide the repository URL when the skill asks.
- **GitHub CLI is not authenticated**: run `gh auth login`.
- **Preflight reports missing bilingual README files**: add `README.md` and `README.zh-CN.md`.
- **Language links are missing**: add visible links between the two README files near the top.
- **Badge checks fail**: add truthful License, release/version, and platform or tech-stack badges.
- **Validation finds mojibake**: fix the corrupted text before publishing.
- **Tests fail**: fix the project first; the skill should not publish known-bad code.

## License

MIT License. See [LICENSE](LICENSE).
