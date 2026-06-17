---
name: publish-to-github
description: Use this skill whenever the user wants to publish, sync, commit, push, prepare, or release a local project or a Codex/Claude/Kiro skill to GitHub. It covers ordinary software projects, static sites, repositories containing SKILL.md, .skill packages, GitHub CLI workflows, release readiness reviews, bilingual README requirements, pre-publish quality gates, git staging safety, commits, pushes, and GitHub Releases.
---

# Publish to GitHub

## Overview

Publish local projects and agent skills to GitHub safely. Treat publishing as a release workflow, not a casual `git add .` sprint into the wall.

This skill supports two target types:

- **Project**: ordinary software repositories, static sites, libraries, tools, documents, or mixed projects.
- **Skill**: repositories or directories containing `SKILL.md`, bundled scripts, references, `.skill` packages, and skill-specific release assets.

Use the current repository settings unless the user says otherwise:

- Remote: `origin`
- Branch: current branch
- Repository URL: ask for the GitHub repository URL only when no suitable remote exists.

Do not invent repository owners, tags, release notes, licenses, or project claims. Guessing is not initiative; it is how bad READMEs get written.

## Skill Directory

`<skill-dir>` means the installed directory for this skill. Common locations:

- Codex: `C:\Users\<user>\.codex\skills\publish-to-github\`
- Claude Code: `~/.claude/skills/publish-to-github/`
- Kiro: the skills directory configured by the Kiro environment

Compatibility note: older prompts may mention `publish-skills-to-github`. Treat those as requests for this `publish-to-github` skill.

## Target Detection

Before publishing, identify the target:

1. If the user names a target path, use that path.
2. If the target contains `SKILL.md`, use **skill mode**.
3. Otherwise use **project mode**.
4. If the user asks for all pending publishable changes, inspect changed top-level directories and classify each with the same rule.

Run the preflight script in the target mode:

**Windows**

```powershell
& "<skill-dir>\scripts\preflight.ps1" -RepoRoot "<repo-root>" -Mode auto -ProjectName "<project-or-skill-path>"
& "<skill-dir>\scripts\preflight.ps1" -RepoRoot "<repo-root>" -Mode project -ProjectName "."
& "<skill-dir>\scripts\preflight.ps1" -RepoRoot "<repo-root>" -Mode skill -ProjectName "<skill-name>"
```

**macOS / Linux**

```bash
bash "<skill-dir>/scripts/preflight.sh" --repo-root "<repo-root>" --mode auto --project-name "<project-or-skill-path>"
bash "<skill-dir>/scripts/preflight.sh" --repo-root "<repo-root>" --mode project --project-name "."
bash "<skill-dir>/scripts/preflight.sh" --repo-root "<repo-root>" --mode skill --project-name "<skill-name>"
```

The preflight scripts are read-only. They must not stage, commit, push, delete, rename, move, tag, release, or rewrite files.

## High-Star Readiness Gate

Before any publish action, inspect the target and fix issues that would make the repository look incomplete, unreliable, or amateurish on GitHub.

Scale the gate to the target type. High-star polish means low friction and clear value, not blindly stuffing every repository with the same marketing furniture:

- Visual projects, dashboards, games, UI kits, and demos should include screenshots, GIFs, live demos, playgrounds, or benchmark images when those assets help users judge the result quickly.
- CLI tools, libraries, automation workflows, and skills should prioritize badges, one-line install commands, fast quickstarts, examples, troubleshooting, releases, and trustworthy verification notes. Screenshots or GIFs are optional unless the tool produces visual output.
- For tiny or narrowly scoped projects, keep the README compact but still make the value, install path, usage, license, and release status obvious within the first few sections.

### Documentation

Require bilingual README files for every publish target:

- `README.md`: English primary README for GitHub landing pages.
- `README.zh-CN.md`: Simplified Chinese README with equivalent usage information.
- Both files must include a visible language switch near the top:
  - `README.md` links to `README.zh-CN.md`.
  - `README.zh-CN.md` links back to `README.md`.
- The two README files should expose the same core sections, even when the wording is localized instead of mechanically translated.

Both READMEs should include:

- A concise one-sentence positioning statement near the top.
- What the project or skill does.
- Prerequisites and supported platforms.
- Installation or setup.
- A quickstart or fastest useful path.
- Basic usage examples.
- Configuration, if any.
- Test/build/publish commands, if relevant.
- Troubleshooting or FAQ for common failure points.
- License.

For high-star-style README structure, prefer a compact top section with a clear title, badges, language switch, one-sentence value proposition, quickstart, installation, usage examples, release or version information, FAQ/troubleshooting, contribution notes when appropriate, and license. Do not bury the value proposition below three screens of ceremony; users are impatient, and honestly they are right to be.

For skills, also include:

- Supported agents or environments.
- Installation paths for Codex, Claude Code, and Kiro when applicable.
- Example trigger prompts.
- Release badge that points to the latest GitHub Release.
- One-line install commands:
  - macOS / Linux: `curl -fsSL <latest-release-install.sh-url> | bash`
  - Windows: `irm <latest-release-install.ps1-url> | iex`
- Packaging or release installation instructions when `.skill` assets are published.

### Repository Hygiene

Check and fix:

- Mojibake or replacement characters, especially common corrupted UTF-8 marker sequences.
- Placeholder literals unless they are clearly intentional examples.
- Local absolute paths, private machine names, or environment-specific claims.
- Missing `.gitignore`.
- Generated or cache directories: `node_modules`, `dist`, `build`, `.cache`, `__pycache__`, `.pytest_cache`, Playwright reports, logs.
- Secret-looking files or names: `.env`, `.pem`, `.key`, `id_rsa`, tokens, credentials, keychains.
- Large files over 5 MB unless the user explicitly intends to publish them.

### Quality Evidence

If standard commands exist, run them before publishing:

- Node: `npm test`, `npm run build`, `npm run lint` when present.
- Python: `python -m pytest` when tests or pytest config exist.
- Rust: `cargo test`, `cargo build`.
- Go: `go test ./...`.
- Skill: run `python "<repo-root>/skill-creator/scripts/quick_validate.py" "<target-skill>"` when available.

If no test or build command exists, say that explicitly in the publish report. Do not hand-wave it as "not needed" unless the user made that tradeoff.

## Project Publish Workflow

Use this for ordinary projects.

1. Identify repository root, target path, branch, upstream, and remote.
2. Run preflight in project or auto mode.
3. Apply the high-star readiness gate:
   - Fix missing bilingual README files.
   - Add or fix `.gitignore` when needed.
   - Ask before creating or changing a license.
   - Fix mojibake and obvious placeholders.
4. Run detected tests/builds/lints, or report that no standard commands exist.
5. Inspect `git status --short` and diffs.
6. Report exact files to stage, warnings, verification results, and intended commit message.
7. Ask for explicit confirmation before `git add`, `git commit`, `git push`, tag creation, or GitHub Release creation.
8. Stage only intended paths.
9. Commit with a concise message, for example:

```bash
git commit -m "publish project to github"
git commit -m "prepare <project-name> for github release"
```

10. Push to the current upstream. If no upstream exists, ask before setting one.
11. Verify:

```bash
git status -sb
git rev-parse --short HEAD
git ls-remote origin HEAD
```

## Skill Publish Workflow

Use this when the target contains `SKILL.md`.

1. Identify target skill directory and repository root.
2. Run preflight in skill or auto mode.
3. Validate frontmatter:
   - `name` exists and is kebab-case.
   - `description` exists, is useful for triggering, and does not include angle-bracket placeholders.
4. Run `skill-creator/scripts/quick_validate.py` when available:

```bash
python "<repo-root>/skill-creator/scripts/quick_validate.py" "<repo-root>/<skill-name>"
```

5. Apply the high-star readiness gate:
   - Require `README.md` and `README.zh-CN.md`.
   - Require `LICENSE`, `LICENSE.md`, or `LICENSE.txt`.
   - Document OS-specific scripts.
   - Add Python requirement notes if Python scripts exist.
   - Add freshness callouts to third-party API reference docs when relevant.
6. Inspect changed files and confirm the exact staging set.
7. Stage only intended paths.
8. Commit with a concise message, for example:

```bash
git commit -m "add <skill-name> skill"
git commit -m "update <skill-name> skill"
```

9. Push and verify with the same commands as project publishing.

## GitHub Releases

Ask before creating releases. Releases are separate from normal source publishing.

### Project Releases

For ordinary projects:

1. Ask for or infer only from existing project metadata a semantic version such as `v1.0.0`.
2. Run tests/builds first.
3. Create an annotated tag only after confirmation:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

4. Create the release with `gh`:

```bash
gh release create v1.0.0 --title "v1.0.0" --notes "<release notes>"
```

Attach build artifacts only when the user asks or the project already has a release artifact convention.

### Skill Releases

For skills, package `.skill` assets before release. Use the bundled release helper only for skill releases:

```bash
bash "<skill-dir>/scripts/make_release.sh" --repo-root "<repo-root>" --version v1.0.0 --skill-name "<skill-name>"
```

If `skill-creator/scripts/package_skill.py` is available, use it. Otherwise zip the skill directory while excluding caches and generated files.

High-star skill releases should include:

- A `.skill` package asset.
- `install.sh` for the one-line curl install path.
- `install.ps1` for Windows PowerShell installation.
- README badges for license, latest release, and platform.
- Release notes that state what changed and how to install.

## Staging Rules

Prefer explicit path staging:

```bash
git add -- "<target-path>/SKILL.md" "<target-path>/README.md" "<target-path>/README.zh-CN.md"
git add -- "<target-path>"
```

Avoid `git add .` unless the preflight, status, and diff show every pending change is intentional. `git add .` is not a workflow; it is a confession with a keyboard.

## Stop and Ask

Stop before publishing when:

- Remote is missing, unexpected, or points to the wrong owner.
- Working tree contains unrelated edits.
- The target path is ambiguous.
- A requested skill lacks `SKILL.md`.
- Frontmatter validation fails.
- A license is missing and there is no existing license choice.
- Files look like secrets or local environment config.
- Generated/cache directories are pending.
- Large files are pending without explicit intent.
- Tests/builds fail.
- The user asks for repository creation, tags, releases, or deployment beyond a normal push.

## Final Report

After publishing, report:

- Repository URL and branch.
- Commit hash.
- Files or directories published.
- Preflight command and result.
- Validation and test/build/lint results.
- Push verification result.
- Release URL and install command, if a release was created.
- Files intentionally left uncommitted.
