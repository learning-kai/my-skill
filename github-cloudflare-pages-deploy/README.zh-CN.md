# github-cloudflare-pages-deploy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/learning-kai/my-skill?label=release)](https://github.com/learning-kai/my-skill/releases/latest)

[English](README.md)

这是一个面向 Codex / Claude Code / Kiro 的技能，用于把本地前端或静态站点项目发布到 GitHub，并通过 Cloudflare Pages 完成 GitHub 源绑定、自定义域名、DNS、生产部署和真实访问验证。

## 功能

- 运行本地预检，检查 CLI 登录状态、Git 状态、`.gitignore`、package scripts 和大文件候选项。
- 将项目发布到 GitHub，并要求明确的暂存、提交、推送与远端验证。
- 创建或更新绑定 GitHub 仓库的 Cloudflare Pages 项目。
- 添加自定义域名和必要的 Cloudflare DNS `CNAME`。
- 触发或等待生产部署，并验证真实站点是否能打开。

## 支持的 Agent

| Agent | 安装路径 |
| --- | --- |
| Codex | `~/.codex/skills/github-cloudflare-pages-deploy` |
| Claude Code | `~/.claude/skills/github-cloudflare-pages-deploy` |
| Kiro 或自定义运行时 | 使用该环境配置的 skills 目录 |

安装脚本默认安装到 Codex。需要安装到其他环境时设置 `AGENT=claude` 或 `AGENT=kiro`。

## 前置条件

- Git
- 已通过 `gh auth login` 登录的 [GitHub CLI (`gh`)](https://cli.github.com/)
- 待发布前端项目所需的 Node.js 和 npm
- 拥有目标 zone 权限的 Cloudflare 账号
- Agent 环境中可用的 Cloudflare API/MCP 访问能力

## 安装

macOS 或 Linux 安装到 Codex：

```bash
curl -fsSL https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.sh | bash
```

Windows PowerShell 安装到 Codex：

```powershell
irm https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.ps1 | iex
```

安装到 Claude Code：

```bash
curl -fsSL https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.sh | AGENT=claude bash
```

```powershell
$env:AGENT = "claude"; irm https://raw.githubusercontent.com/learning-kai/my-skill/main/github-cloudflare-pages-deploy/scripts/install.ps1 | iex
```

手动安装：

```bash
git clone https://github.com/learning-kai/my-skill.git
mkdir -p ~/.codex/skills
cp -R my-skill/github-cloudflare-pages-deploy ~/.codex/skills/
```

## 用法

示例触发语：

```text
Use $github-cloudflare-pages-deploy to publish this frontend project to GitHub and Cloudflare Pages with a custom domain.
```

该技能会引导 agent 先确认：

- 本地项目根目录
- GitHub owner、仓库名和可见性
- 生产分支，通常是 `main`
- `package.json` 中的构建命令和输出目录
- Cloudflare account、zone 和目标自定义域名

如果没有给出目标域名，技能会要求 agent 先询问用户，而不是脑补一个域名去改 DNS。DNS 这种东西不能靠玄学。

## 本地预检

发布前端项目之前，从已安装的技能目录运行预检脚本。

Windows：

```powershell
& "$env:USERPROFILE\.codex\skills\github-cloudflare-pages-deploy\scripts\preflight.ps1" -ProjectRoot "<project-root>"
```

macOS / Linux：

```bash
bash ~/.codex/skills/github-cloudflare-pages-deploy/scripts/preflight.sh "<project-root>"
```

预检会报告 GitHub CLI 登录状态、Git 状态、远端、生成文件忽略规则、package scripts，以及可能不该提交的大文件。

## 配置

不需要静态配置文件。运行时信息来自待部署项目，以及用户自己的 GitHub 和 Cloudflare 账号。

Cloudflare API 字段说明位于 [`references/cloudflare-pages-api.md`](references/cloudflare-pages-api.md)。该参考文档带有更新时间提示，因为 Cloudflare API 字段可能变化。

## 仓库结构

```text
SKILL.md                            核心技能说明
agents/interface.yaml               Agent UI 元数据
agents/openai.yaml                  Codex/OpenAI UI 元数据
references/cloudflare-pages-api.md  Cloudflare Pages API 字段说明
scripts/preflight.ps1               Windows 项目预检
scripts/preflight.sh                macOS/Linux 项目预检
scripts/install.ps1                 Windows 技能安装脚本
scripts/install.sh                  macOS/Linux 技能安装脚本
```

## 验证

这个技能目录本身没有应用级 test/build 命令。可以使用下面的命令验证技能元数据：

```bash
python ../skill-creator/scripts/quick_validate.py .
```

实际使用该技能发布前端项目时，应运行目标项目自身已有的 `npm test`、`npm run build` 和 `npm run lint`。

## 常见问题

- `gh` 未登录：运行 `gh auth login`，然后重新执行预检。
- Cloudflare CLI 登录异常：如果 Cloudflare API/MCP connector 可用，可以继续通过 API/MCP 操作。
- Pages 域名提示 `CNAME record not set`：在 Cloudflare DNS 中添加指向 `<project>.pages.dev` 的 proxied `CNAME`。
- 创建 Pages 项目后没有自动部署：触发一次生产部署，或推送一个新提交。
- 真实站点访问失败：检查 DNS 解析、部署阶段日志和构建输出目录。

## 许可证

MIT。见 [LICENSE](LICENSE)。
