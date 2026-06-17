# human-scribe

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

[English](README.md) | 简体中文

`human-scribe` 是一个中文优先的长文写作与润色 skill，适用于报告、论文、课程作业、综述、白皮书、读书报告、论文段落和长文改写。

它的核心目标是把提纲、要点、草稿和零散素材整理成自然、连贯、少一点模板味和 AI 味的正文。

## 功能

- 写作和润色中文长篇学术或报告类文本。
- 在用户没有明确要求列表时，把要点列表改写成连贯段落。
- 保留用户原意、结论和关键术语，同时改善结构和表达节奏。
- 减少重复转场、机械分点、空泛结尾和过度工整的模板句。
- 不编造事实、引用、论文信息、统计数据、政策条文或实验结果。

## 前置要求

- 支持 `SKILL.md` 的 agent 环境，例如 Codex、Claude Code、Kiro，或其他兼容运行时。
- 不需要额外运行时依赖。本 skill 只包含提示词规则和一个简短参考文档。

支持平台：Windows、macOS 和 Linux。

## 安装

在发布了包含 `human-scribe.skill` 的最新 GitHub Release 之后，一行安装：

```bash
curl -fsSL https://github.com/learning-kai/my-skill/releases/latest/download/install.sh | SKILL_NAME=human-scribe bash
```

Windows PowerShell：

```powershell
$env:SKILL_NAME = "human-scribe"; irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1 | iex
```

也可以显式传入 skill 名称：

```powershell
& ([scriptblock]::Create((irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1))) -SkillName human-scribe
```

手动安装：把 `human-scribe/` 目录复制到你的 agent skill 目录。

| Agent | 默认 skill 路径 |
| --- | --- |
| Codex | `C:\Users\<user>\.codex\skills\human-scribe\` |
| Claude Code | `~/.claude/skills/human-scribe/` |
| Kiro | 你的 Kiro skills 配置目录 |

## 使用

当你要写作、改写、润色、去 AI 味，或把要点整理成长文时，就可以触发这个 skill。

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

## 工作方式

skill 会先判断用户要的是成稿、润色、扩写、缩写、写作计划，还是更自然的人类表达风格，然后先搭逻辑线，再写句子。

默认输出是段落优先的正文。只有用户明确要求提纲、清单、表格、步骤或分点时，才使用列表。

## 参考文件

- `SKILL.md` 包含主要行为规则。
- `references/writing-rules.md` 包含改写检查清单、常见套话提醒和默认结构建议。

## 验证

在仓库根目录运行：

```powershell
$env:PYTHONUTF8='1'
python .\skill-creator\scripts\quick_validate.py .\human-scribe
```

这是一个纯提示词 skill，没有构建步骤，也没有运行时测试套件。发布前仍然应该运行 frontmatter 校验和仓库预检。

## 故障排查

- **输出还是太像列表**：明确要求“写成连续段落”，不要同时要求提纲。
- **文本编造了细节**：补充来源材料，或要求 agent 对未知事实做标注，不要自行补全。
- **语气太僵硬**：要求“自然的学术表达”，不要只说“更正式”。
- **Windows 校验出现编码错误**：运行校验前设置 `PYTHONUTF8=1`。

## License

MIT。见 [LICENSE](LICENSE)。
