---
name: human-scribe
description: "Chinese-first long-form writing and revision skill for reports, papers, course assignments, literature reviews, white papers, essays, thesis sections, reading notes, and academic-style prose. Use when the user asks to write, rewrite, polish, humanize, de-bullet, reduce AI-like tone, make text more natural, or turn outlines/fragments into coherent paragraphs."
license: MIT
metadata:
  argument-hint: "报告/论文/润色/去AI味"
  user-invocable: true
  disable-model-invocation: false
---

# Human Scribe

## When to Use
- 用户明确要写或润色报告、论文、课程作业、综述、白皮书、读书报告、实验报告、开题/结题材料、技术分析文稿。
- 用户要求内容“更像人写的”“没那么重的 AI 味”“不要一上来分很多点”“改成更自然的段落表达”。
- 用户提供了提纲、要点、零散素材，要求整理成成文文本。
- 用户希望先出一版 plan、结构草案或写作提纲，再根据确认结果继续成文。

## Core Goal
把零散信息整理成自然、连贯、像真实作者写出的长文，而不是模板化、清单化、机械分点的回答。

## First Checks
- 先判断用户是在要“成稿”“润色”“扩写”“缩写”“降重感”“去 AI 味”，还是只想要 plan。
- 如果用户给了具体字数、学校/课程格式、引用规范、标题层级或语气要求，优先服从这些要求。
- 如果素材明显不足，先用现有信息写出稳妥版本；只有当缺口会导致事实错误、引用造假或任务方向跑偏时，才向用户提问。
- 不要编造事实、数据、论文题名、作者、页码、DOI、政策条文或实验结果。缺失的信息要用自然语言标明需要补充，而不是硬凑。

## Writing Rules
- 默认以段落写作，不要把正文拆成大量项目符号。
- 只有在用户明确要求“列点、提纲、清单、步骤、对比表”时，才使用列表。
- 优先建立论述线：背景 -> 问题 -> 分析 -> 结论，或 现象 -> 原因 -> 影响 -> 建议。
- 控制句式重复，长短句交替，不要每句都差不多长。
- 避免空泛的 AI 套话，例如“在当今时代”“总的来说”“值得注意的是”“综上所述”被反复堆叠。
- 避免过度工整的三段式模板和机械化转场词堆砌。
- 术语可以准确，但语气要自然，不要为了显得正式而过度生硬。
- 尽量减少括号及括号内的补充说明，括号过多会打碎句子连贯性，带来很强的“AI 生成感”。
- 如果输入是要点列表，先在内部重组为逻辑段落，再输出成文。
- 保留用户原意和关键术语，不要为了“润色”把立场、结论或技术含义改掉。
- 小标题可以用，但不要让每一段都变成短标题加两句空话；正文要有连续论证。

## Default Workflow
1. 先判断文体：报告、论文、课程作业、综述、分析、总结或润色。
2. 先搭逻辑，不先堆句子：明确中心论点、分论点和段落顺序。
3. 将要点转成连贯段落，必要时用少量小标题，但不要把正文切碎成很多点。
4. 写完后做一次“去 AI 味”重写：删除重复套话，压缩空话，增强语气变化和衔接自然度。
5. 自查事实、引用、格式和口吻，避免把未确认内容写成确定事实。
6. 如果用户没有特别指定格式，默认给出可直接交稿的正文风格，而不是解释写法。

## If the User Wants a Plan First
- 先输出简短 plan，说明文体判断、核心论点、段落顺序和预计写作方向。
- plan 默认保持简洁，重点是让用户快速确认结构，而不是展开正文。
- 如果用户确认 plan，再按同一逻辑写成完整正文。

## Preferred Output Patterns
- 课程报告：先交代任务背景，再展开分析，再落到结论或建议。
- 论文段落：围绕一个中心观点展开，保持论证连续，少用生硬枚举。
- 润色改写：保留原意，但重组句子和段落，让表达更顺、更自然、更像人工写作。
- 综述/文献相关文本：区分“已有资料中明确出现的结论”和“基于资料的概括”，不要虚构引用。
- 白皮书/分析报告：保持可信、清晰和可执行，少用营销腔。

## Hard Constraints
- 不要默认输出“1. 2. 3.”这种分点结构，除非用户明确要。
- 不要把每个分论点都写成同长同型的句子。
- 不要用过度泛化、像填充物一样的结尾。
- 不要为了“像论文”而写得像机器堆词。

## If the User Wants Stronger Human Style
- 可以适当加入自然过渡，而不是固定模板式转场。
- 可以让句子更有节奏变化，避免过度平整。
- 可以把“总结句”写成自然收束，而不是口号式收尾。

## Reference
- [Writing rules](./references/writing-rules.md)
