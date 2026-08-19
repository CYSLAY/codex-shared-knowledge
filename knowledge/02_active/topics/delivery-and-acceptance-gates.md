---
type: topic
tags: [delivery, qa, release, acceptance]
updated_at: "2026-08-16"
---

# 交付状态与验收门

## 四层完成定义

1. 代码完成：功能已实现，但可能尚未构建或运行。
2. 构建完成：静态检查、测试和构建通过。
3. 部署完成：目标环境已经更新并可访问。
4. 业务验收完成：真实用户、真实设备和关键业务路径已经验证。

这四层不能互相替代。localhost 可用不等于线上可用，网页发布成功不等于数据库迁移完成，成片导出不等于视觉、声音、授权和合规验收通过。

## 推荐门禁

- 开始前：确认目标环境、数据环境、备份和成功标准。
- 变更前：区分 UI/内容更新与数据协议/迁移更新，后者采用更严格流程。
- 构建门：测试、类型检查、构建及关键自动断言。
- 部署门：环境变量、权限、迁移顺序、资源路径和目标环境状态。
- 业务门：真实设备、真实数据流、恢复流程、视觉关键帧或业务关键路径。
- 交付说明：明确已完成到哪一层，以及仍未验证的部分。

## 来源项目

- [家庭资产分析工具](../projects/family-asset-analyzer.md)
- [健身小程序](../projects/fitness-miniprogram.md)
- [视频号与短视频内容生产系统](../projects/video-content-production.md)
- [CEC 客户看板](../projects/cec-customer-dashboard.md)
- [3D 阅读档案网站](../projects/reading-gallery-3d.md)
