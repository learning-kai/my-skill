# publish-to-github

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)
![Platform: Windows | macOS | Linux](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

[English](README.md) | 简体中文

`publish-to-github` 是一个面向 Codex、Claude Code 和 Kiro 的 skill，用来把本地普通项目或 agent skill 安全发布到 GitHub。它把发布当成正式发布流程处理：检查仓库状态，执行高质量发布前审查，必要时校验 skill 元数据，只暂存预期文件，提交、推送，并在用户确认后创建 GitHub Release。

## 功能

- 支持普通项目和 skill 目录发布到 GitHub。
- 根据目标路径自动识别 project 模式或 skill 模式。
- 执行只读预检，检查 Git 状态、远程仓库、GitHub CLI 登录、双语 README、License、风险路径、大文件、乱码和占位符。
- 发布前执行接近高星仓库标准的完整度审查。
- 保留 skill 专用检查，包括 `SKILL.md`、`.skill` 包和 release 附件。
- 默认只发布源码；标签和 release 必须由用户明确确认后才创建。

## 前置要求

- 已安装并配置 [Git](https://git-scm.com/)。
- 已安装 [GitHub CLI (`gh`)](https://cli.github.com/)；创建 release 和检查凭据时需要。
- Windows 使用 `scripts/preflight.ps1` 需要 PowerShell 5.1 或更高版本。
- macOS / Linux 使用 `scripts/preflight.sh` 和 `scripts/make_release.sh` 需要 Bash、Git 和常见 Unix 工具。
- 如果要用 `skill-creator/scripts/quick_validate.py` 校验 skill，需要 Python 3.10 或更高版本。

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
| Kiro | 你的 Kiro 环境配置的 skills 目录 |

如果通过仓库克隆安装，请把 `publish-to-github/` 目录放到对应 skill 目录下。skill 名称是 `publish-to-github`；旧的 `publish-skills-to-github` 只作为兼容说法保留。

## 使用

示例提示词：

```text
Use publish-to-github to prepare this project and publish it to GitHub.
```

```text
Use publish-to-github to review and publish my local skill directory.
```

```text
Use publish-to-github to create a GitHub Release for this skill after validation.
```

skill 默认使用当前仓库的 `origin` 远程。如果没有合适的远程仓库，它会询问 GitHub 仓库 URL，而不是瞎编一个，毕竟瞎编仓库名这事挺离谱。

## 预检

内置预检脚本是只读的。它们不会暂存、提交、推送、打标签、创建 release、删除、重命名或移动文件。

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

模式说明：

| 模式 | 行为 |
| --- | --- |
| `auto` | 目标存在 `SKILL.md` 时使用 skill 模式，否则使用 project 模式。 |
| `project` | 按普通 GitHub 项目审查目标。 |
| `skill` | 按 agent skill 审查目标并校验 `SKILL.md`。 |

## 发布前质量门禁

发布前，skill 会检查目标是否具备：

- 英文 `README.md` 和简体中文 `README.zh-CN.md`。
- License 文件。
- Git 远程、分支、上游和待提交改动。
- 类似 secret、生成物、缓存、日志和大文件的风险路径。
- 乱码和替换字符。
- 不应该发布的占位符。
- 标准测试或构建命令。
- 存在 `SKILL.md` 时的 skill frontmatter。

如果发现标准验证命令，发布前必须运行。如果没有检测到测试或构建命令，最终发布报告必须明确说明，不要装作这件事不存在。

## 普通项目发布

普通项目发布流程：

1. 识别目标路径、仓库根目录、分支、上游和远程仓库。
2. 使用 project 或 auto 模式运行预检。
3. 修复缺失双语 README、`.gitignore`、乱码或占位符等发布前问题。
4. 运行可用的测试、构建和 lint。
5. 检查 `git status --short` 和 diff。
6. 暂存、提交、推送、打标签或创建 release 前先请求用户确认。
7. 只暂存预期路径。
8. 提交并推送。
9. 验证推送后的修订版本。

## Skill 发布

skill 目录发布还会校验：

- 存在 `SKILL.md`。
- frontmatter 里有 kebab-case 的 `name`。
- frontmatter 里有有用的 `description`。
- 同时存在 `README.md` 和 `README.zh-CN.md`。
- 当仓库里有 `skill-creator/scripts/quick_validate.py` 时，目标 skill 能通过该校验脚本。

skill release 会使用 `scripts/make_release.sh` 打包 `.skill` 附件并创建 GitHub Release。这个 helper 只用于 skill release；普通项目 release 不会强行产出 `.skill` 包。

## Release Helper

打包并发布单个 skill：

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --skill-name my-skill
```

打包并发布仓库内所有 skill：

```bash
bash scripts/make_release.sh --repo-root /path/to/repo --version v1.0.0 --all --notes "Initial skill release"
```

该 helper 依赖 `gh`，并在 skill 发布流程中经过确认后创建 Git tag 和 GitHub Release。

## 故障排查

- **没有配置远程仓库**：添加 GitHub remote，或在 skill 询问时提供仓库 URL。
- **GitHub CLI 未登录**：运行 `gh auth login`。
- **预检提示缺少双语 README**：发布前补齐 `README.md` 和 `README.zh-CN.md`。
- **检测到乱码**：先修复损坏文本再发布。README 烂掉不会显得项目更有个性。
- **测试失败**：先修项目；这个 skill 不应该发布已知坏掉的代码。

## License

MIT。见 [LICENSE](LICENSE)。
