# github-cloudflare-pages-deploy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)

[简体中文](README.zh-CN.md)

A Codex / Claude Code / Kiro skill for publishing local frontend and static site projects through GitHub and Cloudflare Pages. It guides an agent through repository creation, commit and push, Pages project setup, GitHub source binding, custom domain and DNS setup, deployment polling, and live-site verification.

## What It Does

- Runs local preflight checks for CLI auth, Git state, `.gitignore`, package scripts, and large files.
- Publishes the project to GitHub with intentional staging and push verification.
- Creates or updates a Cloudflare Pages project linked to the GitHub repository.
- Adds the custom domain and required Cloudflare DNS `CNAME`.
- Triggers or waits for a production deployment and verifies that the real site loads.

## Supported Agents

| Agent | Install path |
| --- | --- |
| Codex | `~/.codex/skills/github-cloudflare-pages-deploy` |
| Claude Code | `~/.claude/skills/github-cloudflare-pages-deploy` |
| Kiro or custom runtimes | Use the skills directory configured by that environment |

The installer defaults to Codex. Set `AGENT=claude` or `AGENT=kiro` when you want another target.

## Prerequisites

- Git
- [GitHub CLI (`gh`)](https://cli.github.com/) authenticated with `gh auth login`
- Node.js and npm for the frontend project being published
- A Cloudflare account with access to the target zone
- Cloudflare API/MCP access in the agent environment

## Installation

Install for Codex on macOS or Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.sh | bash
```

Install for Codex on Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.ps1 | iex
```

Install for Claude Code instead:

```bash
curl -fsSL https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.sh | AGENT=claude bash
```

```powershell
$env:AGENT = "claude"; irm https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.ps1 | iex
```

Manual installation:

```bash
git clone https://github.com/learning-kai/my-skill.git
mkdir -p ~/.codex/skills
cp -R my-skill/github-cloudflare-pages-deploy ~/.codex/skills/
```

## Usage

Example trigger prompt:

```text
Use $github-cloudflare-pages-deploy to publish this frontend project to GitHub and Cloudflare Pages with a custom domain.
```

The skill expects the agent to establish:

- Local project root
- GitHub owner, repository name, and visibility
- Production branch, usually `main`
- Build command and output directory from `package.json`
- Cloudflare account, zone, and target custom domain

If the target domain is not specified, the skill tells the agent to ask before touching Cloudflare DNS.

## Local Preflight

Run the preflight script from the installed skill directory before publishing a frontend project.

Windows:

```powershell
& "$env:USERPROFILE\.codex\skills\github-cloudflare-pages-deploy\scripts\preflight.ps1" -ProjectRoot "<project-root>"
```

macOS / Linux:

```bash
bash ~/.codex/skills/github-cloudflare-pages-deploy/scripts/preflight.sh "<project-root>"
```

The preflight reports GitHub CLI auth, Git status, remotes, ignored generated files, package scripts, and large tracked or untracked candidates.

## Configuration

No static configuration file is required. Runtime values come from the project being deployed and from the user's GitHub and Cloudflare accounts.

Cloudflare API field notes live in [`references/cloudflare-pages-api.md`](references/cloudflare-pages-api.md). The reference includes a freshness callout because Cloudflare API fields can change.

## Repository Structure

```text
SKILL.md                            Core skill instructions
agents/interface.yaml               Agent UI metadata
agents/openai.yaml                  Codex/OpenAI UI metadata
references/cloudflare-pages-api.md  Cloudflare Pages API field notes
scripts/preflight.ps1               Windows project preflight
scripts/preflight.sh                macOS/Linux project preflight
scripts/install.ps1                 Windows skill installer
scripts/install.sh                  macOS/Linux skill installer
```

## Verification

This skill directory has no application test/build command. Validate the skill metadata with:

```bash
python ../skill-creator/scripts/quick_validate.py .
```

When the skill is used to publish a frontend project, run that project's own `npm test`, `npm run build`, and `npm run lint` commands when they exist.

## Troubleshooting

- `gh` is not authenticated: run `gh auth login`, then retry the preflight.
- Cloudflare CLI auth is broken: continue through the Cloudflare API/MCP connector when it is available.
- Pages domain says `CNAME record not set`: add a proxied Cloudflare DNS `CNAME` pointing to `<project>.pages.dev`.
- Deployment does not start after project creation: trigger a production deployment or push a fresh commit.
- Live site verification fails: check DNS resolution, deployment stage logs, and the built output directory.

## License

MIT. See [LICENSE](LICENSE).
