# document-organization

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

English | [简体中文](README.zh-CN.md)

`document-organization` is a planning-first agent skill for turning messy folders into clear, searchable, maintainable file structures without casually deleting or breaking user context.

## Why

File organization sounds simple until a folder mixes course notes, screenshots, archives, duplicate drafts, code snippets, installers, and unnamed final-final files. A naive cleanup usually sorts by extension, invents a giant `Other` folder, or deletes something important because it looked useless. That is not organization; that is clutter with better posture.

This skill exists to make agents inspect intent before moving files. It emphasizes stable categories, explicit naming rules, recoverable plans, and user confirmation before risky operations such as deletion, deduplication, or bulk renaming.

## Core Features

- Designs clear folder structures for downloads, documents, course materials, project assets, code folders, image libraries, and mixed archives.
- Prioritizes purpose and context before file extension or filename-only guesses.
- Splits mixed folders into focused subfolders instead of hiding everything under `Other`.
- Defines naming rules for dates, versions, drafts, final files, backups, and temporary files.
- Produces an organization plan before execution when files may be moved, renamed, merged, or deleted.
- Keeps risky actions explicit: duplicate removal, deletion, destructive merges, and large renames require confirmation.
- Preserves traceability with move maps or source-to-target summaries when execution is involved.

## Screenshots & Demo

This is a workflow skill, not a visual application. The useful demo is the planning pattern it enforces:

```text
scan current files -> classify by purpose -> propose target tree -> define naming rules -> flag risks -> wait for confirmation -> execute safely -> summarize changes
```

Example prompt:

```text
Use document-organization to clean up my Downloads folder. First give me a plan, and do not delete anything until I confirm.
```

Example output shape:

```text
Current problem:
- Documents, archives, screenshots, installers, and temp files are mixed in one level.

Target structure:
Downloads/
  01_Documents/
  02_Images/
  03_Archives/
  04_Installers/
  90_Review_Before_Delete/

Risk notes:
- Duplicate-looking files should be reviewed before deletion.
- Unclear filenames need content checks or user confirmation.
```

## Quick Start

### Prerequisites

- A supported agent environment: Codex, Claude Code, Kiro, or another runtime that can load `SKILL.md` skills.
- No runtime dependencies are required. This is a prompt-only skill with one reference document.

Supported platforms: Windows, macOS, and Linux.

### Installation

Install from the latest GitHub Release after a release containing `document-organization.skill` is published:

```bash
curl -fsSL https://github.com/learning-kai/my-skill/releases/latest/download/install.sh | SKILL_NAME=document-organization bash
```

Windows PowerShell:

```powershell
$env:SKILL_NAME = "document-organization"; irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1 | iex
```

You can also pass the skill name explicitly:

```powershell
& ([scriptblock]::Create((irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1))) -SkillName document-organization
```

Manual install: copy the `Document-organization/` directory into your agent skill folder.

| Agent | Default skill path |
| --- | --- |
| Codex | `C:\Users\<user>\.codex\skills\document-organization\` |
| Claude Code | `~/.claude/skills/document-organization/` |
| Kiro | Your configured Kiro skills directory |

### Typical Prompts

```text
Use document-organization to organize this folder. Give me the plan first.
```

```text
整理这个课程资料文件夹，按课程、作业、讲义、考试资料重新分类，不要直接删除文件。
```

```text
I have a mixed project folder with docs, code, screenshots, and zip files. Propose a clean structure and a rename plan.
```

```text
帮我检查这些文件哪些可能重复，先列出风险，不要直接去重。
```

## Engineering Quality

The skill is intentionally conservative because file organization often touches irreplaceable user data:

- It treats deletion as a confirmed high-risk action.
- It avoids filename-only classification when names are vague.
- It keeps project and code folders compatible with their existing build or module layout.
- It recommends subfolders when a category contains clearly different purposes, sources, stages, or file types.
- It asks for confirmation before executing moves, renames, merges, or deletion.
- It favors a maintainable structure over decorative over-sorting.

Local verification from the repository root:

```powershell
$env:PYTHONUTF8='1'
python .\skill-creator\scripts\quick_validate.py .\Document-organization
```

There is no build step and no runtime test suite for this prompt-only skill. Release preparation should still run the skill validator and the publish preflight gate.

## Project Docs

- [SKILL.md](SKILL.md) contains the main behavior rules.
- [references/organization-rules.md](references/organization-rules.md) contains the compact rewrite checklist, useful transformations, naming standards, and phrases to avoid.
- [README.zh-CN.md](README.zh-CN.md) is the Simplified Chinese README with equivalent usage information.

## Privacy & Security

- The skill should not delete, overwrite, or merge files without explicit confirmation.
- It should surface secret-looking files, private local paths, credentials, and environment files as risks instead of casually moving them into public outputs.
- It should preserve original file context through move maps or summaries when execution is requested.
- It should not publish, upload, or expose user files; it only guides local organization unless the user separately asks for another workflow.

## Release & Updates

Current repository release: [latest GitHub Release](https://github.com/learning-kai/my-skill/releases/latest).

When publishing a skill release, attach:

- `document-organization.skill`
- `install.sh`
- `install.ps1`

Package and release example:

```bash
bash publish-to-github/scripts/make_release.sh --repo-root /path/to/my-skill --version v1.0.0 --skill-name Document-organization
```

## Roadmap

- Add more examples for course-material cleanup, image asset libraries, and mixed code/document repositories.
- Add optional mapping templates for bulk rename and move plans.
- Add practical deduplication review patterns that separate exact duplicates from near-duplicates.
- Keep the reference checklist short enough to load only when needed.

## Contributing

Keep edits narrow and practical. This skill should make file cleanup safer and easier to maintain, not turn every folder into a museum catalog. When changing behavior, preserve the plan-first flow and the confirmation boundary around destructive actions.

## Troubleshooting

- **The proposed structure is too deep**: ask for a flatter structure and name the maximum depth.
- **The plan uses the wrong category dimension**: specify whether you prefer project, topic, time, file type, source, or workflow stage as the primary dimension.
- **The agent wants to delete duplicates too early**: require a duplicate review list first and confirm deletion separately.
- **A code project may break after moving files**: ask the agent to preserve build, import, and configuration paths before proposing moves.
- **Validation fails on Windows with an encoding error**: set `PYTHONUTF8=1` before running the validator.

## License

MIT License. See [LICENSE](LICENSE).
