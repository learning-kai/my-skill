# github-cloudflare-pages-deploy

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) / Kiro skill that publishes a local frontend or static site project end-to-end: GitHub repository creation, initial commit/push, Cloudflare Pages project, GitHub source binding, custom domain setup, deployment trigger, and real access verification.

## What it does

1. Runs a local preflight check (CLI auth, Git state, `.gitignore`, build scripts).
2. Creates a GitHub repository and pushes the initial commit.
3. Creates a Cloudflare Pages project linked to that repository.
4. Adds a custom domain and the required DNS CNAME record.
5. Triggers a production deployment and polls until it succeeds.
6. Opens the live site in a browser and confirms it loads correctly.

## Prerequisites

| Tool | Purpose |
|------|---------|
| [GitHub CLI (`gh`)](https://cli.github.com/) | Create repos, push code |
| [Git](https://git-scm.com/) | Version control |
| [Node.js + npm](https://nodejs.org/) | Build the frontend project |
| Cloudflare account | Pages hosting and DNS |
| Cloudflare API/MCP connector | Configured in your Claude Code environment |

Authenticate before running:

```bash
gh auth login
```

## Installation

Clone or copy this skill into your Claude Code skills directory:

```bash
# Global (available in all projects)
git clone https://github.com/YOUR_USERNAME/github-cloudflare-pages-deploy \
  ~/.claude/skills/github-cloudflare-pages-deploy

# Project-local
git clone https://github.com/YOUR_USERNAME/github-cloudflare-pages-deploy \
  .claude/skills/github-cloudflare-pages-deploy
```

Then invoke it in Claude Code:

```
Use $github-cloudflare-pages-deploy to publish this frontend project to GitHub and Cloudflare Pages with a custom domain.
```

## Platform support

| Platform | Preflight script |
|----------|-----------------|
| Windows | `scripts/preflight.ps1` |
| macOS / Linux | `scripts/preflight.sh` |

See `SKILL.md` for detailed usage instructions.

## Repository structure

```
SKILL.md                        Skill instructions for Claude
agents/interface.yaml           Skill interface metadata
references/cloudflare-pages-api.md  Cloudflare API field notes
scripts/preflight.ps1           Windows preflight check
scripts/preflight.sh            macOS/Linux preflight check
```

## License

MIT — see [LICENSE](LICENSE).
