# publish-to-github

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

[English](README.md) | 简体中文

`publish-to-github` 是一个面向 Codex、Claude Code 和 Kiro 的 skill，用发布级流程把本地项目或 skill 发布到 GitHub。

## 功能

- 支持普通项目和 skill 目录发布到 GitHub。
- 根据目标路径自动识别 project 模式或 skill 模式。
- 执行只读预检，检查 Git 状态、远程仓库、GitHub CLI 登录、双语 README、License、风险路径、大文件、乱码和占位符。
- 发布前执行接近高 star 仓库标准的完整度审查。
- 保留 skill 专用检查，包括 `SKILL.md`、`.skill` 包和 release 附件。
- 默认只发布源码；标签和 release 必须由用户明确确认后创建。

## 快速开始

```text
Use publish-to-github to prepare this project and publish it to GitHub.
```

```text
Use publish-to-github to review and publish my local skill directory.
```

## 前置要求

- 已安装并配置 Git。
- 已安装并登录 GitHub CLI (`gh`)；创建 release 和检查凭据时需要。
- Windows：使用 `scripts/preflight.ps1` 和 `scripts/test_preflight.ps1` 需要 PowerShell 7+。
- macOS / Linux：使用 `scripts/preflight.sh` 和 `scripts/make_release.sh` 需要 Bash 和 Git。
- 如果要用 `skill-creator/scripts/quick_validate.py` 校验 skill，需要 Python 3.10+。

支持平台：Windows、macOS 和 Linux。

## 安装

从最新 GitHub Release 一行安装：

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

## 使用

skill 默认使用当前仓库的 `origin` 远程。如果没有合适的远程仓库，它会询问 GitHub 仓库 URL，不会自己瞎编。

## 预检

内置预检脚本是只读的，不会暂存、提交、推送、打 tag、创建 release、删除、重命名或移动文件。

Windows：

```powershell
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode auto -ProjectName "."
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode skill -ProjectName "my-skill"
.\scripts\preflight.ps1 -RepoRoot "C:\path\to\repo" -Mode project -ProjectName "my-project"
```

macOS / Linux：

```bash
bash scripts/preflight.sh --repo-root /path/to/repo --mode auto --project-name .
bash scripts/preflight.sh --repo-root /path/to/repo --mode skill --project-name my-skill
bash scripts/preflight.sh --repo-root /path/to/repo --mode project --project-name my-project
```

## 发布门禁

发布前，skill 会检查目标是否具备：

- 英文 `README.md` 和简体中文 `README.zh-CN.md`。
- 两份 README 顶部都有可见的语言切换链接。
- 两份 README 都包含简洁定位、快速开始、安装、使用、故障排查和 License。
- License 文件。
- Git 远程、分支、上游和待提交改动。
- secret、生成物、缓存、日志和大文件风险路径。
- 乱码和替换字符。
- 不该发布的占位符。
- 标准测试或构建命令。
- `SKILL.md` 存在时的 skill frontmatter。

如果发现标准验证命令，发布前必须运行。若没有检测到测试或构建命令，最终发布报告必须明确说明，不要装作这事不存在。

## 普通项目发布

普通项目发布流程：

1. 识别目标路径、仓库根目录、分支、上游和远程仓库。
2. 使用 project 或 auto 模式运行预检。
3. 修复缺失双语 README、`.gitignore`、乱码、占位符或风险路径等发布前问题。
4. 运行可用的测试、构建和 lint。
5. 检查 `git status --short` 和相关 diff。
6. 暂存、提交、推送、打 tag 或创建 release 前先请求用户确认。
7. 只暂存预期路径。
8. 提交并推送。
9. 验证推送后的修订版本。

## Skill 发布

skill 目录发布还会校验：

- `SKILL.md` 存在。
- frontmatter 里的 `name` 是 kebab-case。
- frontmatter 里的 `description` 有效。
- `README.md` 和 `README.zh-CN.md` 同时存在。
- 仓库可通过 `skill-creator/scripts/quick_validate.py`。

skill release 会使用 `scripts/make_release.sh` 打包 `.skill` 附件并创建 GitHub Release。这个 helper 只用于 skill release；普通项目 release 不会强制产出 `.skill` 包。

## Release Helper

打包并发布单个 skill：

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --skill-name my-skill
```

打包并发布仓库内所有 skill：

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --all --notes "Initial skill release"
```

## 故障排查

- **没有配置远程仓库**：先添加 GitHub remote，或者在 skill 询问时提供仓库 URL。
- **GitHub CLI 未登录**：运行 `gh auth login`。
- **预检提示缺少双语 README**：先补 `README.md` 和 `README.zh-CN.md`。
- **语言互链缺失**：在两份 README 顶部添加可见互链。
- **检测到乱码**：先修复损坏文本再发布。README 烂掉不是风格，是事故。
- **测试失败**：先修项目；这个 skill 不应该发布已知坏代码。

## 贡献

跟着预检输出修，保持双语 README 同步，只暂存需要发布的路径。

## License

MIT。见 [LICENSE](LICENSE)。
