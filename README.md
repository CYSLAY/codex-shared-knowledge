# Codex Shared Knowledge

这是一个经过脱敏的 Codex 共享知识库。它把公开来源中提炼的方法、工具路由、项目经验和验收门保存为 Markdown，让不同电脑上的 Codex 能按任务语义检索并应用。

## 包含内容

- AI 设计、前端、PPT、视频、科研绘图和文档摄取方法。
- 本地优先、数据安全、生产状态机和交付验收经验。
- 已去除客户内容与本机路径的历史项目复盘。
- 公开抖音视频的结构化来源笔记及官方资料核验。
- 第三方 Skill 的使用判断与官方安装来源。
- 第一方 `design-director` Skill，用于按最佳成品效果协同网站/UI、PPT、图片与视频能力。
- 飞书机器人把链接写入本地待办队列的脱敏部署指南与代码模板。

## 不包含内容

- 原作者的个人偏好、客户资料、飞书消息和自动化队列。
- API Key、Cookie、Token、账号信息或个人电脑的绝对路径。
- 第三方 Skill 源码。Skill 需要从其官方仓库单独安装。

## 安装

克隆仓库后运行：

```bash
bash scripts/install.sh
```

脚本会保留现有 `~/.codex/AGENTS.md`，只添加一个受管理区块，指向本仓库的 `knowledge/INDEX.md`；同时安装或安全更新本仓库第一方 `design-director` Skill。若目标位置已有非本仓库管理的同名 Skill，脚本会停止而不是覆盖。新启动的本地 Codex 任务会继承知识入口和设计路由能力。

更新知识库：

```bash
bash scripts/update.sh
```

移除全局入口但保留仓库：

```bash
bash scripts/uninstall.sh
```

## 使用原则

Codex 不会把整个仓库放进每次上下文。它应先读索引，再按当前目标选择最相关的 1—3 个主题或项目页。当前任务的明确要求优先；单一外部来源仍保留证据强度和信息边界。

知识不等于能力。只有当前电脑实际存在对应 Skill、工具和权限时，Codex 才能声称已调用；否则只能应用已经沉淀的方法和检查单。

本仓库采用安全增量更新：个人知识库每次完成更新后，只发布通过脱敏与公开门禁的变化；每周再执行一次对账补漏。个人偏好、客户信息、飞书配置和凭据始终不会进入公开仓库。

## 可复用部署指南

- [飞书机器人内容同步：从私聊链接到本地知识队列](guides/feishu-bot-content-sync.md)

## 官方依据

- [Codex 的 AGENTS.md 指令发现与全局继承](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Codex Skill 的隐式调用与存放位置](https://learn.chatgpt.com/docs/build-skills)
