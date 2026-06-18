# publish-to-github

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4)
![PowerShell 7](https://img.shields.io/badge/PowerShell-7%2B-5391FE)
![Bash](https://img.shields.io/badge/Bash-supported-4EAA25)
![GitHub CLI](https://img.shields.io/badge/GitHub%20CLI-gh-181717)

[English](README.md) | 简体中文

> 一个面向 Codex、Claude Code 和 Kiro 的 release-first GitHub 发布 skill。它用双语 README 检查、发布前门禁、精确暂存和 GitHub Release 安装附件，把普通项目和 skill 目录发布到 GitHub。

`publish-to-github` 把“推到 GitHub”变成一个可控的发布流程。它会在碰 Git 之前先检查仓库门面：README 质量、release 信号、平台声明、风险文件、生成物、secret、大文件、验证命令，以及到底哪些路径应该被暂存。

## 为什么做

大多数 GitHub 发布事故并不高级。它们通常很朴素：README 讲不清楚、badge 是假的、`.env` 忘了排除、安装命令跑不通、release 没附件，或者一发 `git add .` 直接把桌面边角料也扫进提交里。

这个 skill 的目标是让发布变成一次小型 release review，哪怕项目很小、只是一个本地 skill。它不是为了把仓库装饰成样板间，而是让用户快速看懂价值、快速安装、相信发布质量，并且别把私有文件或半成品推上去。

## 核心特性

- 支持普通项目和 agent skill 目录发布到 GitHub。
- 支持二次发布：对已发布仓库做精准优化（刷新 README、描述、badge、release），或在已发布内容与当前需求差别很大时重写并重新发布。
- 根据目标路径自动识别 project 模式或 skill 模式。
- 强制双语 README 结构：英文 `README.md` 和简体中文 `README.zh-CN.md`。
- 检查高 star README 信号：顶部 badge、语言互链、一句话定位、快速开始、release/安装路径、故障排查、路线图、贡献说明和 License。
- 保留 skill 专用验证：`SKILL.md`、`.skill` 包、release 附件和触发示例。
- 源码发布与 tag / GitHub Release 分离，除非用户明确确认 release 创建。
- 执行只读预检，覆盖 Git 状态、远程仓库、GitHub CLI 登录、风险待提交路径、大文件、乱码、占位符和常见验证命令。

## 截图与演示

这是 workflow skill，不是视觉型应用。它的价值证明不是截图，而是可复现的发布链路：

```text
preflight -> README quality gate -> validation -> exact staging -> commit -> push -> optional tag/release -> install assets
```

使用本 skill 发布视觉型项目时，截图、GIF、Demo 或明确素材补充计划仍然是 README 门禁的一部分。对 CLI、库、自动化 workflow 和 skill 项目来说，命令示例、一行安装、release 附件和故障排查才是更强的可信度信号。

## 快速开始

### 安装

安装最新发布版 skill：

```bash
curl -fsSL https://github.com/learning-kai/my-skill/releases/latest/download/install.sh | bash
```

Windows PowerShell：

```powershell
irm https://github.com/learning-kai/my-skill/releases/latest/download/install.ps1 | iex
```

手动安装：把本目录复制或克隆到你的 agent skill 目录。

| Agent | 默认 skill 路径 |
| --- | --- |
| Codex | `C:\Users\<user>\.codex\skills\publish-to-github\` |
| Claude Code | `~/.claude/skills/publish-to-github/` |
| Kiro | 你的 Kiro skills 配置目录 |

### 典型提示词

```text
Use publish-to-github to prepare this project and publish it to GitHub.
```

```text
Use publish-to-github to review and release my local skill directory.
```

```text
Use publish-to-github to run a high-star README review before I push.
```

```text
Use publish-to-github to optimize my already-published repo, or rewrite and republish it if it no longer matches what I want.
```

### 预检

内置预检脚本是只读的，不会暂存、提交、推送、打 tag、创建 release、删除、重命名或移动文件。

PowerShell 7：

```powershell
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode auto -ProjectName "."
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode skill -ProjectName "my-skill"
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode project -ProjectName "my-project"
```

Bash：

```bash
bash scripts/preflight.sh --repo-root /path/to/repo --mode auto --project-name .
bash scripts/preflight.sh --repo-root /path/to/repo --mode skill --project-name my-skill
bash scripts/preflight.sh --repo-root /path/to/repo --mode project --project-name my-project
```

## 工程质量

这个 skill 把 README 质量和仓库卫生当作发布门禁，而不是发布后再想起来补的装饰：

- README 顶部 badge 必须包含真实的 License、release/version、platform 或 tech-stack 信号。
- badge 声明必须来自真实文件或仓库事实，例如 `LICENSE`、GitHub Releases、`.github/workflows/`、`package.json`、`Cargo.toml`、`pyproject.toml`、`go.mod` 或已有平台支持说明。
- `README.md` 和 `README.zh-CN.md` 必须在顶部互链，并暴露等价核心章节。
- 门禁会检查乱码、占位符、本地路径泄露、生成目录、缓存文件、secret 风险命名和超过 5 MB 的待提交文件。
- 如果存在标准测试或构建命令，发布报告必须运行或明确列出；如果没有，也必须直说，别装作质量验证凭空存在。

本地验证：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\test_preflight.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\preflight.ps1 -RepoRoot .. -Mode skill -ProjectName publish-to-github
python ..\skill-creator\scripts\quick_validate.py .
```

```bash
bash -n scripts/preflight.sh
bash scripts/preflight.sh --repo-root .. --mode skill --project-name publish-to-github
```

## 项目文档

建议按下面顺序阅读：

1. [SKILL.md](SKILL.md) - 工作流规则和发布行为。
2. [README.md](README.md) - 英文 README，与中文版结构等价。
3. [scripts/preflight.ps1](scripts/preflight.ps1) - PowerShell 预检门禁。
4. [scripts/preflight.sh](scripts/preflight.sh) - Bash 预检门禁。
5. [scripts/make_release.sh](scripts/make_release.sh) - 仅用于 skill 的打包和 GitHub Release helper。
6. [scripts/install.sh](scripts/install.sh) 和 [scripts/install.ps1](scripts/install.ps1) - release 安装附件。

## 隐私与安全边界

- 预检脚本是只读的，不会改变 Git 状态。
- skill 默认不创建 GitHub 仓库；除非用户明确要求，否则使用现有 `origin`。
- 暂存、提交、推送、打 tag 或创建 GitHub Release 前都会要求用户确认。
- secret 风险文件、本地环境文件、生成物、缓存、日志和大文件会在发布前暴露出来。
- README 声明不应泄露私有本地路径、机器名、token、凭据、数据库或备份文件。

## 发布与更新

skill release 应附带：

- `publish-to-github.skill`
- `scripts/install.sh`
- `scripts/install.ps1`

打包并发布单个 skill：

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --skill-name publish-to-github
```

打包并发布仓库内所有 skill：

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --all --notes "Initial skill release"
```

普通项目 release 只有在用户要求时才创建 tag 和 GitHub Release。除非目标确实是 skill，否则不应该产出 `.skill` 包。

## 路线图

- 保持 PowerShell 和 Bash 的 Kaoyan-style README 门禁一致。
- 更精确地检测项目类型、包管理器和平台 badge 建议。
- 在存在合适工具时增加 Markdown 链接检查。
- 改进普通项目和 skill 的 release notes 模板。
- 扩展 fixture，覆盖缺失 badge 类型和视觉型项目截图 warning。

## 贡献

改动要收敛，跑完 preflight 测试，并保持双语 README 同步。如果一个 badge 或声明不能从仓库事实证明，就别加。高 star 门面很有用；假自信只是穿了件漂亮外套的技术债。

## 故障排查

- **没有配置远程仓库**：先添加 GitHub remote，或者在 skill 询问时提供仓库 URL。
- **GitHub CLI 未登录**：运行 `gh auth login`。
- **预检提示缺少双语 README**：补齐 `README.md` 和 `README.zh-CN.md`。
- **语言互链缺失**：在两份 README 顶部添加可见互链。
- **Badge 检查失败**：添加真实的 License、release/version、platform 或 tech-stack badge。
- **检测到乱码**：先修复损坏文本再发布。
- **测试失败**：先修项目；这个 skill 不应该发布已知坏代码。

## License

MIT License。见 [LICENSE](LICENSE)。
