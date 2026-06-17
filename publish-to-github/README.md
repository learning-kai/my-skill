# publish-to-github

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

English | [简体中文](README.zh-CN.md)

`publish-to-github` is a Codex, Claude Code, and Kiro skill for publishing local projects or skills to GitHub with a release-style workflow.

## What It Does

- Publishes ordinary projects and skill directories to GitHub.
- Auto-detects project mode or skill mode from the target path.
- Runs read-only preflight checks for Git state, remotes, GitHub CLI auth, bilingual README files, license files, risky paths, large files, mojibake, and placeholder literals.
- Requires a high-star-style readiness review before publishing.
- Preserves skill-specific checks for `SKILL.md`, `.skill` packages, and release assets.
- Keeps source publishing separate from tags and releases unless the user explicitly confirms release creation.

## Quick Start

```text
Use publish-to-github to prepare this project and publish it to GitHub.
```

```text
Use publish-to-github to review and publish my local skill directory.
```

## Prerequisites

- Git installed and configured.
- GitHub CLI (`gh`) installed and authenticated for release creation and checks.
- Windows: PowerShell 7+ for `scripts/preflight.ps1` and `scripts/test_preflight.ps1`.
- macOS / Linux: Bash and Git for `scripts/preflight.sh` and `scripts/make_release.sh`.
- Python 3.10+ when validating skills with `skill-creator/scripts/quick_validate.py`.

Supported platforms: Windows, macOS, and Linux.

## Installation

Install from the latest GitHub Release:

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

## Usage

The skill uses the current `origin` remote when one exists. If no suitable remote is configured, it asks for the GitHub repository URL instead of inventing one.

## Preflight Checks

The bundled preflight scripts are read-only. They do not stage, commit, push, tag, release, delete, rename, or move files.

Windows:

```powershell
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode auto -ProjectName "."
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode skill -ProjectName "my-skill"
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode project -ProjectName "my-project"
```

macOS / Linux:

```bash
bash scripts/preflight.sh --repo-root /path/to/repo --mode auto --project-name .
bash scripts/preflight.sh --repo-root /path/to/repo --mode skill --project-name my-skill
bash scripts/preflight.sh --repo-root /path/to/repo --mode project --project-name my-project
```

## Readiness Gate

Before publishing, the skill checks the target for:

- English `README.md` and Simplified Chinese `README.zh-CN.md`.
- Visible language switch links near the top of both READMEs.
- A concise positioning statement, quickstart, installation, usage, troubleshooting, and license in both READMEs.
- License file.
- Git remote, branch, upstream, and pending changes.
- Secret-looking, generated, cache, log, and large files.
- Mojibake and replacement characters.
- Placeholder literals that should not ship.
- Standard test/build commands.
- Skill frontmatter when `SKILL.md` is present.

When standard verification commands exist, the skill runs them before publishing. If no test or build command is detected, the final publish report must say so clearly.

## Project Publishing

For ordinary projects, the workflow is:

1. Identify the target path, repository root, branch, upstream, and remote.
2. Run preflight in project or auto mode.
3. Fix readiness issues such as missing bilingual README files, `.gitignore`, mojibake, placeholders, or risky pending paths.
4. Run available tests, builds, and linters.
5. Inspect `git status --short` and the relevant diff.
6. Ask for confirmation before staging, committing, pushing, tagging, or releasing.
7. Stage only intended paths.
8. Commit and push.
9. Verify the pushed revision.

## Skill Publishing

For skill directories, the workflow also validates:

- `SKILL.md` exists.
- Frontmatter has kebab-case `name`.
- Frontmatter has a useful `description`.
- `README.md` and `README.zh-CN.md` both exist.
- The skill can pass `skill-creator/scripts/quick_validate.py` when that validator is available.

For skill releases, `scripts/make_release.sh` packages `.skill` assets and creates a GitHub Release. This helper is for skill releases only; ordinary project releases do not produce `.skill` packages.

## Release Helper

Package and release one skill:

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --skill-name my-skill
```

Package and release every skill found in a repository:

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --all --notes "Initial skill release"
```

## Troubleshooting

- **No remote is configured**: add a GitHub remote or provide the repository URL when the skill asks.
- **GitHub CLI is not authenticated**: run `gh auth login`.
- **Preflight reports missing bilingual README files**: add `README.md` and `README.zh-CN.md` before publishing.
- **Language links are missing**: add visible links between the two README files near the top.
- **Validation finds mojibake**: fix the corrupted text before publishing. A broken README is not a charming personality trait.
- **Tests fail**: fix the project first; the skill should not publish known-bad code.

## Contributing

Follow the preflight output, keep the README pair in sync, and stage only the intended paths.

## License

MIT. See [LICENSE](LICENSE).
