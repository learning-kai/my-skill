---
name: github-cloudflare-pages-deploy
description: Use when publishing a local frontend/static site project to a GitHub repository and deploying it through Cloudflare Pages with GitHub integration, production builds, DNS records, custom domains, or Pages deployment verification.
---

# GitHub Cloudflare Pages Deploy

## Overview

Use this skill to publish a local web project end to end: GitHub repository, initial commit/push, Cloudflare Pages project, GitHub source binding, custom domain, deployment trigger, and real access verification.

Default to Cloudflare Pages for static/Vite/React frontends. Do not use direct Workers deployment unless the project actually contains edge runtime code.

## Inputs To Establish

- Project root and whether it is already a Git repository.
- GitHub owner/repository name and desired visibility.
- Cloudflare account and zone for the target domain.
- Production branch, usually `main`.
- Build command and output directory, usually from `package.json`.
- Target custom domain, for example `home.example.com`.

If the target domain is not specified, ask before creating Cloudflare records. Guessing domains is how people invent outages for sport.

## Local Preflight

`<skill-dir>` is the directory where this skill is installed, typically
`~/.claude/skills/github-cloudflare-pages-deploy` on macOS/Linux or
`%USERPROFILE%\.claude\skills\github-cloudflare-pages-deploy` on Windows.

**Windows** — run `scripts/preflight.ps1`:

```powershell
& "<skill-dir>\scripts\preflight.ps1" -ProjectRoot "<project-root>"
```

**macOS / Linux** — run `scripts/preflight.sh`:

```bash
bash "<skill-dir>/scripts/preflight.sh" "<project-root>"
```

Use the output to confirm:

- `gh` is installed and authenticated.
- Git status, current branch, and remotes are understood.
- `package.json` exposes build/test scripts.
- `.gitignore` excludes `node_modules`, build output, reports, and logs.
- Build and test commands are known before publishing.

If Cloudflare CLI auth is broken but Cloudflare API/MCP access works, continue with the Cloudflare API tool. Do not block on `wrangler whoami` when a valid Cloudflare API connector is available.

## GitHub Workflow

1. Run project checks first: install dependencies if needed, then run the relevant tests and build.
2. Inspect `git status -sb --ignored`.
3. If the directory is not a Git repository, initialize with `git init -b main`.
4. Confirm `.gitignore` excludes generated folders such as `node_modules/`, `dist/`, `test-results/`, reports, screenshots, and logs.
5. Create the GitHub repository only after confirming the intended owner/name:

```powershell
gh repo create OWNER/REPO --public --description "Short description"
```

Use `--private` when the user asks for private.

6. Add the remote, stage intentional files, commit, and push:

```powershell
git remote add origin https://github.com/OWNER/REPO.git
git add .
git commit -m "initial publish"
git push -u origin main
```

If `git push` initially fails with a connection or credential issue, run `gh auth setup-git` and retry before declaring GitHub permission failure.

## Cloudflare Pages Workflow

Use the Cloudflare API/MCP connector when available. Read `references/cloudflare-pages-api.md` before creating or patching Pages projects.

1. List existing Pages projects and the target zone. Check for existing projects/domains to avoid collisions.
2. Create or update a Pages project with:
   - `name`: stable lowercase project name.
   - `production_branch`: target branch.
   - `build_config.build_command`: project build command.
   - `build_config.destination_dir`: output directory.
   - `source.type`: `github`.
   - `source.config`: owner, repo name, repo ID, owner ID, production branch, deployment settings.
3. Add the custom domain with the Pages Domains API.
4. Ensure DNS has a proxied `CNAME` from the custom hostname to the Pages subdomain unless Cloudflare already created the correct record.
5. Trigger a production deployment if no deployment starts automatically after project creation.
6. Poll deployment stages until `deploy` is `success` or a failure is returned.
7. Confirm the Pages domain status becomes `active`.

## Verification

Before claiming success, verify all of these:

- GitHub repository URL resolves and `main` is pushed.
- Cloudflare Pages deployment stage `deploy` is `success`.
- The custom domain is in the Pages project `domains` list.
- DNS resolves through Cloudflare.
- `Invoke-WebRequest https://custom.domain/` returns `200`.
- Browser opens the custom domain and shows the expected title/content.
- The local Git working tree is clean after removing any tool-generated temporary files.

For frontend sites, use a browser snapshot or screenshot after deployment. A control panel saying "success" is not the same as a real user loading the site. Shocking, I know.

## Common Mistakes

- Creating a Pages project after pushing and then waiting forever for a deployment. Trigger an ad hoc production deployment or push a new commit.
- Forgetting the DNS `CNAME` for the custom domain. Pages may say the domain exists while verification still complains `CNAME record not set`.
- Uploading `node_modules`, `dist`, Playwright reports, screenshots, or local logs. Fix `.gitignore` before the first commit.
- Treating a broken local `wrangler whoami` as fatal when Cloudflare API access is already available.
- Guessing domain names or repository visibility. Ask when the user did not specify them.

## Final Report

Return a compact summary with:

- GitHub repository URL.
- Cloudflare Pages project name and pages.dev URL.
- Custom domain URL.
- Deployment ID or short ID.
- Validation commands/results.
- Any auth or permission issues that were worked around.
