# Task Decomposer

![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Platform](https://img.shields.io/badge/platform-Codex%20Skill-black)

[English](README.md)

一个从第一性原理出发的任务拆解 skill，用来把模糊、过大、需要多 agent 协同的任务转成可执行方案。

## 为什么做

大多数任务计划都是体面废话：调研、设计、实现、测试。Task Decomposer 强制 agent 先推导目标状态、当前状态、关键差距、必要状态变化、验证方式和依赖关系，再开始拆任务。

## 核心特性

- 先审判目标，识别不现实、矛盾、范围爆炸的任务。
- 支持 `G0` 目标级到 `G4` 操作级的颗粒度对齐。
- 默认 `G3` 原子任务级，要求输入、输出、依赖和完成标准明确。
- 内部五视角 contest：strategist、executor、skeptic、minimalist、parallelizer。
- 默认只交付最终方案，不把内部 agent 草稿甩给用户。
- DAG 优先，要求用 `depends_on` 表达真实依赖关系。

## 截图与演示

这是文本工作流 skill，截图不是有效证明。典型触发方式：

```text
Use $task-decomposer to break this project into executable tasks and align the granularity first.
```

## 快速开始

macOS/Linux 安装到 Codex：

```bash
curl -fsSL https://raw.githubusercontent.com/learning-kai/my-skill/main/task-decomposer/install.sh | bash
```

Windows PowerShell 安装到 Codex：

```powershell
irm https://raw.githubusercontent.com/learning-kai/my-skill/main/task-decomposer/install.ps1 | iex
```

手动安装路径：

| Agent | 路径 |
|---|---|
| Codex | `%USERPROFILE%\.codex\skills\task-decomposer` 或 `$HOME/.codex/skills/task-decomposer` |
| Claude Code | `%USERPROFILE%\.claude\skills\task-decomposer` 或 `$HOME/.claude/skills/task-decomposer` |
| Kiro | 复制到 Kiro 配置的 skills 目录 |

## 工程质量

- `SKILL.md` 已通过官方 `skill-creator` 的 `quick_validate.py` 校验。
- 已用普通规划任务和故意范围爆炸的任务做过 smoke test。
- 正常使用 skill 不需要额外运行时依赖。

## 项目文档

- [`SKILL.md`](SKILL.md)：skill 主体说明。
- [`agents/openai.yaml`](agents/openai.yaml)：Codex UI 元数据。
- [`install.sh`](install.sh) 与 [`install.ps1`](install.ps1)：源码安装脚本。

## 隐私与安全边界

这个 skill 本身不会调用外部服务。contest 模式可能指导 Codex 使用当前环境可用的 subagent 工具，但除非用户明确要求 audit/debug 保留，否则不会保存内部草稿。

## 发布与更新

当前还没有创建 GitHub Release。发布资产创建后，可从 [releases/latest](https://github.com/learning-kai/my-skill/releases/latest) 获取最新版本。

## 路线图

- 增加 `.skill` 发布包。
- 增加产品规划、代码重构、研究工作流示例。
- 增加更严格的多 agent 分派 smoke test。

## 贡献

保持 skill 紧凑。不要添加装饰性文件、泛泛任务模板或额外 agent 角色，除非它们解决了测试中真实出现的问题。

## 故障排查

- 如果 Codex 没发现 skill，确认目录名是 `task-decomposer`，并且里面有 `SKILL.md`。
- Windows 下如果 Python 默认用 `gbk` 读取中文失败，校验前设置 `PYTHONUTF8=1`。

## License / 许可证

MIT。见 [`LICENSE`](LICENSE)。
