# human-scribe

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

English | [简体中文](README.zh-CN.md)

`human-scribe` is a Chinese-first writing skill for reports, papers, course assignments, literature reviews, white papers, essays, thesis sections, reading notes, and long-form polishing.

It helps turn outlines, bullet notes, rough drafts, and fragmented material into coherent prose with a more natural rhythm and less template-heavy AI flavor.

## What It Does

- Writes and polishes Chinese long-form academic or report-style text.
- Reworks bullet lists into connected paragraphs when the user does not explicitly request a list.
- Preserves the user's meaning, conclusion, and technical terms while improving structure and flow.
- Reduces repetitive transition phrases, mechanical enumerations, and generic conclusions.
- Avoids inventing facts, citations, paper metadata, statistics, policies, or experiment results.

## Prerequisites

- A supported agent environment: Codex, Claude Code, Kiro, or another agent runtime that can load `SKILL.md` skills.
- No runtime dependencies are required. This skill contains prompt instructions and a small reference document only.

Supported platforms: Windows, macOS, and Linux.

## Installation

Install from the latest GitHub Release after a release containing `human-scribe.skill` is published:

```bash
curl -fsSL https://github.com/learning-kai/my-skill/releases/latest/download/install.sh | SKILL_NAME=human-scribe bash
```

Windows PowerShell:

```powershell
$env:SKILL_NAME = "human-scribe"; irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1 | iex
```

You can also pass the skill name explicitly:

```powershell
& ([scriptblock]::Create((irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1))) -SkillName human-scribe
```

Manual install: copy the `human-scribe/` directory into your agent skill folder.

| Agent | Default skill path |
| --- | --- |
| Codex | `C:\Users\<user>\.codex\skills\human-scribe\` |
| Claude Code | `~/.claude/skills/human-scribe/` |
| Kiro | Your configured Kiro skills directory |

## Usage

Trigger the skill with writing, rewriting, polishing, or "make this less AI-like" prompts.

```text
Use human-scribe to polish this course report and make the expression more natural.
```

```text
把下面这些论文笔记整理成一段综述，不要列点，语气像正式课程作业。
```

```text
这段文字 AI 味太重了，帮我保留原意但改得像人写的。
```

```text
先给我一个写作 plan，确认后再扩写成完整报告。
```

## Workflow

The skill first identifies whether the user wants a finished draft, a revision, an expansion, a shorter version, a plan, or a more human style. It then builds a clear argument line before writing sentences.

By default, the output is paragraph-first prose. Lists are used only when the user explicitly asks for an outline, checklist, comparison table, steps, or bullet points.

## References

- `SKILL.md` contains the main behavior rules.
- `references/writing-rules.md` contains the rewrite checklist, phrase warnings, and preferred default structure.

## Verification

From the repository root, validate the skill with:

```powershell
$env:PYTHONUTF8='1'
python .\skill-creator\scripts\quick_validate.py .\human-scribe
```

There is no build step and no runtime test suite for this prompt-only skill. The release gate should still run frontmatter validation and repository preflight before publishing.

## Troubleshooting

- **The output is still too list-like**: explicitly ask for prose paragraphs and avoid requesting an outline.
- **The draft invents details**: provide the missing source material, or ask the agent to mark unknown facts instead of filling them in.
- **The style is too stiff**: ask for a more natural academic tone rather than a more formal tone.
- **Validation fails on Windows with an encoding error**: set `PYTHONUTF8=1` before running the validator.

## License

MIT. See [LICENSE](LICENSE).
