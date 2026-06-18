---
name: publish-to-github
description: Use this skill whenever the user wants to publish, sync, commit, push, prepare, or release a local project or a Codex/Claude/Kiro skill to GitHub. It also covers improving, optimizing, re-doing, or rewriting an already-published repository, including refreshing READMEs, descriptions, badges, and releases, or rewriting and republishing when the live repo diverges greatly from current requirements. It covers ordinary software projects, static sites, repositories containing SKILL.md, .skill packages, GitHub CLI workflows, release readiness reviews, bilingual README requirements, pre-publish quality gates, git staging safety, commits, pushes, and GitHub Releases.
---

# Publish to GitHub

## Overview

Publish local projects and agent skills to GitHub safely. Treat publishing as a release workflow, not a casual `git add .` sprint into the wall.

This skill supports two target types:

- **Project**: ordinary software repositories, static sites, libraries, tools, documents, or mixed projects.
- **Skill**: repositories or directories containing `SKILL.md`, bundled scripts, references, `.skill` packages, and skill-specific release assets.

It handles both first-time publishing and **republishing**. When a target is already on GitHub, the skill optimizes the live publication with surgical fixes, or — when the published repo diverges greatly from current requirements — rewrites and republishes it while preserving history by default.

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

Also detect whether the target is **already published** before choosing a workflow:

- A remote exists and the current branch already tracks an upstream.
- `git ls-remote <remote> <branch>` returns a commit, meaning history is already on GitHub.
- A README, GitHub Release, or tags already exist for the target.

If the target is already published, prefer the **Republish Workflow** below instead of treating the task as a first-time publish. A first publish builds the repository front door from nothing; a republish improves or rebuilds a front door that visitors already see.

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

### Repository Description (About)

The repository description is the single line GitHub shows in search results, topic pages, stars lists, and the sidebar "About" box. Most people read it before they ever open the README. High-star repos treat it as a one-line pitch, not a label. Always set or improve it.

Write it like the best repos do:

- Lead with what it *is* and what it *does for the user*, in plain language. State the outcome, not the mechanism.
- One sentence, roughly 50-110 characters. It must survive truncation, so front-load the meaning.
- No trailing period, no marketing adjectives ("powerful", "blazing-fast", "ultimate", "simple"), no emoji unless the project's own brand already uses them.
- Do not repeat the repo name back ("publish-to-github is a tool that..."). The name is already shown right next to it.
- Use natural keywords a user would actually search, so the repo is discoverable without sounding stuffed.

Good shapes:

- `Release-first GitHub publishing for projects and agent skills, with preflight gates and bilingual READMEs`
- `Self-hostable bookmark manager with full-text search and one-click archiving`
- `Type-safe SQL query builder for TypeScript, zero dependencies`

Avoid:

- `A simple and powerful tool` — says nothing, all adjectives.
- `My awesome project` — placeholder energy, instant trust loss.
- `publish-to-github skill` — just the name again, zero value.

Apply the description with `gh` after confirmation, and keep it in sync with the README's one-sentence positioning statement so the two never contradict each other:

```bash
gh repo edit --description "<one-line pitch>"
```

If `gh` is unavailable or the user declines, state the recommended description text in the final report so they can paste it into the GitHub "About" box manually.

### Documentation

Require bilingual README files for every publish target:

- `README.md`: English primary README for GitHub landing pages.
- `README.zh-CN.md`: Simplified Chinese README with equivalent usage information.
- Both files must include a visible language switch near the top:
  - `README.md` links to `README.zh-CN.md`.
  - `README.zh-CN.md` links back to `README.md`.
- The two README files should expose the same core sections, even when the wording is localized instead of mechanically translated.

### Kaoyan-Style README Blueprint

When generating or repairing README files, use the mature project structure shown by the `考研专注` reference README: credibility first, value second, workflow third. The top of both README files should follow this order:

1. Project name.
2. Badge block.
3. Language switch.
4. One-sentence positioning statement.

### Writing Voice for High-Star READMEs

A high-star README is not just a complete README; it reads like one a careful maintainer wrote, not a template that got filled in. Structure gets you a passing grade. Voice is what makes a reader trust the project in the first ten seconds. Apply these rules to every section you generate or repair.

**Win the first screen.** Everything above the fold decides whether the reader keeps scrolling: name, badges, one-sentence positioning, and immediately after it the single clearest proof of value. For a CLI or library that proof is the shortest real command-plus-output or install-plus-usage snippet. For a visual project it is one hero screenshot or GIF. Do not make the reader scroll past a wall of prose or a table of contents to find out what the project does.

**The one-sentence positioning statement is the hook.** It mirrors the repository description but can be slightly fuller. Say what it is, who it is for, and the outcome it delivers. No "This project is a..." preamble, no adjective pile-up. Compare:

- Weak: `A powerful and easy-to-use tool that helps you with publishing your projects to GitHub in a simple way.`
- Strong: `Turns "push this to GitHub" into a controlled release: preflight gates, honest badges, and staging you can trust.`

**Show, don't tell.** Replace claims with evidence. "Fast" becomes a benchmark number or a comparison. "Easy to use" becomes a three-line quickstart the reader can copy. "Well-tested" becomes a passing CI badge and a test command. If a sentence asserts a quality without showing it, either back it with a concrete artifact or cut it.

**Cut ceremony, keep substance.** The section checklist below is the *menu*, not a mandate to serve every dish. Use the sections the project actually needs and keep each one tight. A reader skims; reward skimming with short paragraphs, real code blocks, and scannable lists. Do not pad a small project with empty Roadmap or Contributing sections just to hit the list — an honest three-section README beats eleven hollow ones.

**Concrete over generic, always.** Use the project's real commands, real file names, real flags, real output. Never ship `<your-command-here>` or invented example output. If a value is genuinely a placeholder the user must fill in, mark it unmistakably and say so. Generic filler is the single clearest tell that a README was generated rather than written.

**Match the project's register.** A developer tool reads precise and a little dry. A consumer app reads warmer. Either way: plain words, active voice, no hype, no exclamation points. Confidence comes from specifics, not from adjectives.

The badge block is a quality signal, not a sticker wall. Include at least three truthful badges:

- Required: License.
- Required: Latest release or version.
- Required: Platform or real tech stack.
- Optional when true: CI, test status, language/runtime, framework, build tool, package manager, GitHub CLI, PowerShell, Bash, Docker, Tauri, React, Rust, Python, Node.js, Go.

Infer badges from real repository facts before writing them:

- `LICENSE`, `LICENSE.md`, or `LICENSE.txt` for the license badge.
- GitHub Releases, package metadata, or version files for release/version badges.
- `.github/workflows/` for CI badges.
- `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `requirements.txt`, `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `bun.lockb`, `tauri.conf.json`, Vite/React config, or project scripts for tech badges.
- OS support from documented scripts, build targets, or existing project claims.

Do not fake badges for CI, test coverage, downloads, package versions, supported platforms, or framework support. If a useful badge cannot be proven from the repo, leave it out and add a warning or TODO instead. A fake badge is worse than no badge; it tells users the project is cosplaying maturity.

Both README files should use equivalent Kaoyan-style core sections:

- `Why` / `为什么做`
- `Core Features` / `核心特性`
- `Screenshots & Demo` / `截图与演示`
- `Quick Start` / `快速开始`
- `Engineering Quality` / `工程质量`
- `Project Docs` / `项目文档`
- `Privacy & Security` / `隐私与安全边界`
- `Release & Updates` / `发布与更新`
- `Roadmap` / `路线图`
- `Contributing` / `贡献`
- `License`

Scale the screenshots section by project type:

- Visual projects, desktop apps, mobile apps, web apps, games, dashboards, and UI libraries should include screenshots, GIFs, demos, playgrounds, or a concrete asset plan.
- CLI tools, libraries, automation workflows, and skills should not force decorative screenshots. Use command examples, release assets, install flow, troubleshooting, and typical workflows as the proof of value.

The README should still include prerequisites, installation or setup, usage examples, configuration when relevant, test/build/publish commands, troubleshooting or FAQ, release/version information, contribution guidance, and license. Do not bury the value proposition below three screens of ceremony; users are impatient, and honestly they are right to be.

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
   - Write or improve the README first-screen and one-sentence positioning per the writing-voice rules.
   - Propose a high-star repository description and set it with `gh repo edit --description` after confirmation.
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
   - Write or improve the README first-screen and one-sentence positioning per the writing-voice rules.
   - Propose a high-star repository description and set it with `gh repo edit --description` after confirmation.
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

## Republish Workflow

Use this when the target is already on GitHub and the user wants to improve, fix, re-do, or re-release it. The instinct on an already-published repo should not be "publish again from scratch." It should be "look at what is live, compare it to what the user now wants, and choose the smallest honest change that closes the gap."

### 1. Read what is already published

Do not assume the live repository matches the local working tree. Inspect both before deciding anything:

```bash
git fetch origin
git log --oneline -10
git status -sb
gh repo view --json name,description,url,defaultBranchRef
gh release list
```

Read the published `README.md`, `README.zh-CN.md`, repository description, badges, and any release notes that are currently live. The published state, not the local draft, is what users actually see.

### 2. Measure the gap against requirements

Compare the live publication to the user's current requirements and to the high-star readiness gate. Classify the gap into one of two paths:

- **Optimize** when the published repository is fundamentally right but imperfect: stale README sections, a weak or missing repository description, a broken install command, a fake or outdated badge, mojibake, a missing language link, an outdated release, or new local commits that were never pushed. Most republish requests land here.
- **Rewrite and republish** when the published repository diverges greatly from what the user now wants: the positioning is wrong, the README describes a different scope or audience, the project changed direction, large sections are obsolete, or the structure no longer matches the code. A rewrite replaces the front door rather than patching it.

State which path you chose and the concrete reasons. If the gap is ambiguous between the two, describe both options and ask the user which they want before changing files.

### 3a. Optimize path

Make targeted, surgical improvements. Do not rewrite sections that are already correct just to leave a fingerprint.

1. Run preflight in the matching mode to refresh repository state.
2. Apply only the high-star readiness gate items that actually fail: fix the specific README sections, badges, description, install command, language links, mojibake, or hygiene issues that are wrong.
3. Keep the existing voice, structure, and section order unless they are the problem. Continuity matters; a repo whose README is rewritten wholesale every week looks unstable.
4. Re-sync `README.md` and `README.zh-CN.md` so the pair stays equivalent after edits.
5. Run detected tests/builds/lints, or report that no standard commands exist.
6. Show a diff of exactly what changed and why before staging.
7. Confirm, then stage only the changed paths, commit with a message that names the improvement, and push.

```bash
git commit -m "improve <project-or-skill-name> readme and release readiness"
git commit -m "fix install command and repository description for <name>"
```

### 3b. Rewrite-and-republish path

A rewrite is a bigger change, so it needs more care, not less. The repository already has stars, links, and history pointing at it; do not casually torch that.

1. Confirm with the user that a rewrite, not an optimization, is what they want. Summarize what will change and what will be preserved.
2. Preserve history by default. Rewrite the README, description, badges, and structure with new commits on top of the existing history. Do not force-push, rewrite published history, delete the repository, or recreate it unless the user explicitly asks and accepts the loss of stars, watchers, issues, and existing clone URLs. Treat that as a high-risk action and surface the consequences first.
3. Rebuild the README first-screen, one-sentence positioning, and core sections from the user's current requirements, following the writing-voice rules. Keep real commands, real file names, and truthful badges.
4. Rewrite both `README.md` and `README.zh-CN.md` together so they stay equivalent.
5. Propose an updated repository description with `gh repo edit --description` after confirmation, since a rewrite usually changes the positioning.
6. Run detected tests/builds/lints, or report that no standard commands exist.
7. Show the full before/after of the README and description before staging. A rewrite is exactly when the user most needs to see what they are replacing.
8. Confirm, then stage, commit, and push:

```bash
git commit -m "rewrite <project-or-skill-name> readme and republish"
```

9. If the published release no longer matches the rewritten project, ask whether to cut a new release. Do not silently leave a release that contradicts the new README.

### Republish verification

Verify the same way as a first publish, and additionally confirm the live state now matches the intended result:

```bash
git status -sb
git rev-parse --short HEAD
git ls-remote origin HEAD
gh repo view --json description,url
```

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
- A republish would rewrite published history, force-push, or delete/recreate the repository. Surface the loss of stars, watchers, issues, and clone URLs first.
- A republish gap is ambiguous between optimizing and rewriting. Describe both and let the user choose.

## Final Report

After publishing, report:

- Repository URL and branch.
- Commit hash.
- Files or directories published.
- For a republish: whether it was an optimize or rewrite, and what changed versus what was preserved.
- Preflight command and result.
- Validation and test/build/lint results.
- Push verification result.
- Repository description: the text set via `gh`, or the recommended text to paste manually if it was not set.
- Release URL and install command, if a release was created.
- Files intentionally left uncommitted.
