---
type: topic
tags: [document-ingestion, markdown, agent-skill, rag]
updated_at: "2026-08-19"
---

# 多格式文档转 Markdown 与知识摄取

## 当前认识

把不同办公格式统一为 Markdown，可以为全文检索、RAG、知识库和 Agent 阅读建立稳定的文本入口；它解决的是“结构化读取”，不等于保留原文件的全部视觉、交互和计算能力。

## 使用判断

1. 先判断任务目标是读内容还是验版式。内容抽取可走 Markdown；PPT/PDF 视觉验收仍需渲染原文件。
2. 大文档先转成文件，再通过目录、标题和关键词按需读取，避免一次性注入全部上下文。
3. 对扫描型或纯图片 PDF 单独路由到 OCR；不要把 OCR 缺失误判为“文档没有内容”。
4. 本地 CLI 有利于敏感资料控制，但首次下载依赖、软件供应链和临时文件仍需纳入安全检查。
5. 转换后抽查标题、表格、脚注、图片说明和页序；涉及数值与合同条款时必须回看原文。

## AnyDoc 路由

- 官方仓库和 Skill 已核验，支持 Word、PowerPoint、Excel、OpenDocument、RTF、EPUB、CSV 和文本型 PDF 转 GitHub-Flavored Markdown。
- 触发：当前能力不能直接稳定读取上述格式，或需要批量规范化后进入检索/RAG/知识库。
- 不触发：扫描件 OCR、像素级还原、PPT 动画、Excel 公式执行或原生图表编辑。
- 当前状态：官方 `convert-documents-to-markdown` Skill 与 AnyDoc 路线已经过来源环境核验。接收者机器必须在使用前检查 Skill、Node.js、包管理器及 AnyDoc CLI 的实际可用状态；未安装时不得声称已调用，可在用户授权后按官方路线安装或临时执行并完成健康检查。

## 来源

- [AnyDoc 文档转 Markdown 与科研绘图工具展示](../../douyin/7674729901227822377.md)
- [AnyDoc 官方仓库](https://github.com/firecrawl/anydoc)
- [AnyDoc 官方 Skill](https://github.com/firecrawl/anydoc/blob/main/skills/convert-documents-to-markdown/SKILL.md)
