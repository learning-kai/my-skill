# document-organization

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

[English](README.md) | 简体中文

`document-organization` 是一个计划优先的文件整理 agent skill，用来把混乱文件夹整理成清晰、可检索、可维护的目录结构，同时避免随手删除文件或破坏上下文。

## 为什么做

整理文件听起来很简单，直到一个文件夹里同时出现课程笔记、截图、压缩包、重复草稿、代码片段、安装包和一堆 `final-final` 文件。粗暴清理通常只会按扩展名分类、造一个巨大的 `Other` 文件夹，或者把看起来没用但其实重要的东西删掉。说难听点，这不叫整理，这叫把混乱换个姿势摆好。

这个 skill 的目标是让 agent 先理解文件用途，再决定怎么整理。它强调稳定分类、明确命名规则、可回溯方案，以及在删除、去重、批量重命名等高风险动作前先取得用户确认。

## 核心特性

- 为下载目录、文档库、课程资料、项目素材、代码文件夹、图片素材库和混合归档设计清晰结构。
- 优先根据用途和上下文分类，而不是只看扩展名或文件名瞎猜。
- 把混杂目录拆成职责明确的子文件夹，而不是把所有东西塞进 `Other`。
- 为日期、版本、草稿、终版、备份和临时文件制定统一命名规则。
- 在移动、重命名、合并或删除前，先输出整理方案。
- 明确标出高风险动作：重复文件删除、直接删除、破坏性合并和大批量重命名都需要确认。
- 执行时保留可追溯性，例如移动映射表或原路径到目标路径摘要。

## 截图与演示

这是一个工作流 skill，不是视觉应用。它的有效演示是强制执行的规划流程：

```text
扫描现状 -> 按用途分类 -> 提出目标目录树 -> 制定命名规则 -> 标出风险 -> 等待确认 -> 安全执行 -> 汇总变更
```

示例触发：

```text
Use document-organization to clean up my Downloads folder. First give me a plan, and do not delete anything until I confirm.
```

示例输出结构：

```text
当前问题：
- 文档、压缩包、截图、安装包和临时文件混在同一层。

目标结构：
Downloads/
  01_Documents/
  02_Images/
  03_Archives/
  04_Installers/
  90_Review_Before_Delete/

风险提示：
- 看起来重复的文件需要先复核，再决定是否删除。
- 文件名含糊的内容需要查看上下文或向用户确认。
```

## 快速开始

### 前置要求

- 支持 `SKILL.md` 的 agent 环境，例如 Codex、Claude Code、Kiro，或其他兼容运行时。
- 不需要额外运行时依赖。这是一个纯提示词 skill，只附带一个参考文档。

支持平台：Windows、macOS 和 Linux。

### 安装

在发布了包含 `document-organization.skill` 的最新 GitHub Release 之后，可以一行安装：

```bash
curl -fsSL https://github.com/learning-kai/my-skill/releases/latest/download/install.sh | SKILL_NAME=document-organization bash
```

Windows PowerShell：

```powershell
$env:SKILL_NAME = "document-organization"; irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1 | iex
```

也可以显式传入 skill 名称：

```powershell
& ([scriptblock]::Create((irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1))) -SkillName document-organization
```

手动安装：把 `Document-organization/` 目录复制到你的 agent skill 目录。

| Agent | 默认 skill 路径 |
| --- | --- |
| Codex | `C:\Users\<user>\.codex\skills\document-organization\` |
| Claude Code | `~/.claude/skills/document-organization/` |
| Kiro | 你的 Kiro skills 配置目录 |

### 典型用法

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

## 工程质量

这个 skill 刻意保守，因为文件整理经常会碰到用户不可替代的数据：

- 把删除视为需要确认的高风险动作。
- 文件名含糊时，不只凭文件名分类。
- 对项目和代码目录，优先保留原有构建结构、模块结构和引用关系。
- 当一个类别内部出现明显不同用途、来源、阶段或文件类型时，建议继续拆分子文件夹。
- 在执行移动、重命名、合并或删除前要求确认。
- 优先选择后续能维护的结构，而不是为了整齐过度分类。

在仓库根目录运行本地校验：

```powershell
$env:PYTHONUTF8='1'
python .\skill-creator\scripts\quick_validate.py .\Document-organization
```

这是一个纯提示词 skill，没有构建步骤，也没有运行时测试套件。发布前仍应运行 skill 校验和 publish preflight。

## 项目文档

- [SKILL.md](SKILL.md) 包含主要行为规则。
- [references/organization-rules.md](references/organization-rules.md) 包含精简整理检查清单、常见转换方式、命名标准和应避免的表达。
- [README.md](README.md) 是英文 README，包含等价使用说明。

## 隐私与安全边界

- 未经明确确认，不应删除、覆盖或合并文件。
- 对疑似密钥、私有本地路径、凭据和环境文件，应作为风险提示，而不是随手移动到公开输出中。
- 用户要求执行整理时，应通过移动映射或变更摘要保留原始上下文。
- 除非用户另行要求其他工作流，本 skill 不发布、上传或暴露用户文件，只指导本地整理。

## 发布与更新

当前仓库发布：[latest GitHub Release](https://github.com/learning-kai/my-skill/releases/latest)。

发布 skill release 时建议附带：

- `document-organization.skill`
- `install.sh`
- `install.ps1`

打包与发布示例：

```bash
bash publish-to-github/scripts/make_release.sh --repo-root /path/to/my-skill --version v1.0.0 --skill-name Document-organization
```

## 路线图

- 增加课程资料整理、图片素材库、代码与文档混合仓库的更多示例。
- 增加批量重命名和移动计划的可选映射模板。
- 增加实用去重复核模式，区分完全重复和近似重复。
- 保持参考检查清单足够短，只在需要时加载。

## 贡献

变更应保持窄而实用。这个 skill 应该让文件整理更安全、更容易维护，而不是把每个文件夹都整理成博物馆目录。修改行为时，请保留“先计划、再确认、后执行”的流程，以及对破坏性动作的确认边界。

## 故障排查

- **目标结构太深**：明确要求更扁平的结构，并指定最大层级深度。
- **分类维度不符合习惯**：说明你希望优先按项目、主题、时间、文件类型、来源还是工作阶段分类。
- **agent 过早想删除重复文件**：要求先输出重复文件复核清单，并单独确认删除。
- **代码项目移动后可能失效**：要求 agent 在提出移动方案前保留构建、导入和配置路径。
- **Windows 校验出现编码错误**：运行校验前设置 `PYTHONUTF8=1`。

## License

MIT License。见 [LICENSE](LICENSE)。
