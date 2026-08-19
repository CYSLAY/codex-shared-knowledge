# 飞书机器人内容同步：从私聊链接到本地知识队列

这份指南复用一条已经长期运行验证过的轻量路线：飞书只作为随时可用的链接收件箱；机器人不回复消息，只把符合白名单的链接写成 JSON 待办；Codex 或其他消费者稍后异步读取、分析和沉淀。

它适合个人或小团队的本地知识摄取，不适合要求消息实时处理、多人广播、复杂交互卡片或高可用服务集群的场景。

## 1. 架构与边界

```text
飞书私聊消息
    ↓ im.message.receive_v1
Node.js 长连接接收器
    ↓ 只做校验、去重和落盘
knowledge/inbox/pending/*.json
    ↓ 定时或人工触发
Codex / 内容处理器
    ↓
来源笔记、候选洞见、主题知识
```

关键原则：事件回调只负责入队，不在回调里下载、转写或调用大模型。飞书官方说明长连接事件应在 3 秒内完成处理，超时可能重推；快速落盘还能把平台接收与后续重任务解耦。

## 2. 创建飞书自建应用

1. 登录[飞书开放平台](https://open.feishu.cn/)，进入开发者后台。
2. 创建“企业自建应用”，填写名称、描述和图标。
3. 在“应用能力”中添加“机器人”。
4. 在权限管理中只申请“读取用户发给机器人的单聊消息”，权限标识为 `im:message.p2p_msg:readonly`。
5. 不需要机器人回复时，不申请“以应用的身份发消息”。这能减少权限和误操作面。

官方的[机器人快速教程](https://open.feishu.cn/document/develop-an-echo-bot/introduction)和[应用配置说明](https://open.feishu.cn/document/develop-an-echo-bot/faq)展示了创建自建应用、添加机器人、配置权限、订阅事件和发布版本的完整入口。官方示例为了“自动回复”会额外申请发送权限；本方案不回复，因此应坚持最小权限。

## 3. 配置事件订阅

1. 进入“事件与回调”或“事件订阅”。
2. 选择“使用长连接接收事件/回调”。
3. 添加事件“接收消息”，事件标识为 `im.message.receive_v1`。
4. 保存配置。

长连接方案由官方 SDK 建立 WebSocket 通道，不要求公网域名、固定 IP 或内网穿透；鉴权在建连时完成，后续事件无需自己实现 Webhook 的签名校验和解密。[飞书事件接收说明](https://open.feishu.cn/document/server-docs/event-subscription-guide/event-subscription-configure-/encrypt-key-encryption-configuration-case?lang=en-US)

如果改用“发送至开发者服务器”的 Webhook 模式，则必须提供 HTTPS 公网地址，并按官方说明完成 URL 校验、签名校验以及启用加密时的事件解密。本仓库模板没有实现 Webhook，不要混用两套配置。

## 4. 发布并限制可用范围

1. 创建应用版本并提交发布；权限、机器人能力或事件变更后也要重新发布才能在正式版生效。
2. 把应用可用范围限制为确实需要投递内容的人；个人使用时只加入自己。
3. 在飞书客户端搜索机器人名称并打开单聊。

若客户端找不到机器人，先检查应用是否已发布，以及当前用户是否在可用范围内。测试版与正式版是两套逻辑独立的应用，凭据也不同，不要交叉使用。[测试企业与人员说明](https://open.feishu.cn/document/tools-and-resources/test-and-release-app)

## 5. 安装本地接收器

模板位于 [`examples/feishu-content-inbox/`](../examples/feishu-content-inbox/)。建议使用 Node.js 20 或更新的 LTS 版本。

```bash
cd examples/feishu-content-inbox
npm install
cp .env.example .env
chmod 600 .env
```

然后只在本机编辑 `.env`：

- `FEISHU_APP_ID`：开发者后台“凭证与基础信息”中的应用 ID。
- `FEISHU_APP_SECRET`：同一页面中的应用密钥。
- `QUEUE_DIR`：待办 JSON 的绝对目录，例如某个知识库的 `knowledge/inbox/pending`。
- `ALLOWED_HOSTS`：允许入队的域名白名单，以英文逗号分隔。

`.env` 已被 `.gitignore` 排除。不要把凭据粘贴进聊天、知识库、日志、截图或版本库。

启动接收器：

```bash
npm start
```

正常情况下会看到正在建立事件流的日志。随后给机器人私聊发送一个白名单域名链接，`QUEUE_DIR` 中应生成一条权限为 `0600` 的 JSON 待办。

## 6. 队列记录约定

模板只保存后续处理需要的最小字段：

```json
{
  "source": "feishu",
  "platform": "douyin",
  "url": "https://v.douyin.com/example/",
  "dedupe_key": "32-character-hash",
  "received_at": "2026-01-01T00:00:00.000Z",
  "status": "pending",
  "attempts": 0
}
```

- 文件名和 `dedupe_key` 来自消息 ID、链接序号与 URL 的哈希，重复事件不会创建第二份待办。
- 默认不保存发送者标识和整段消息正文，减少不必要的个人信息沉淀。
- 只接受单聊文本消息和域名白名单中的链接。
- 使用排他创建；同一事件被平台重推时视为幂等成功。

消费者应采用 `pending → done/failed` 状态机：成功完成全部写入后才移动到 `done`；失败时记录尝试次数和错误，达到上限后移动到 `failed`。不要让机器人等待内容处理完成。

## 7. macOS 登录自启与锁屏运行

模板 [`com.example.feishu-content-inbox.plist.template`](../examples/feishu-content-inbox/com.example.feishu-content-inbox.plist.template) 使用 `launchd` 托管进程，并用 `caffeinate -i` 防止空闲导致系统睡眠。它不阻止显示器熄灭或锁屏。

1. 运行 `which node`，把结果替换模板中的 `__NODE_PATH__`。
2. 把接收器目录的绝对路径替换 `__PROJECT_DIR__`。
3. 先创建 `logs/`，再把模板复制到 `~/Library/LaunchAgents/com.example.feishu-content-inbox.plist`。
4. 校验并加载：

```bash
plutil -lint ~/Library/LaunchAgents/com.example.feishu-content-inbox.plist
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.example.feishu-content-inbox.plist
launchctl kickstart -k "gui/$(id -u)/com.example.feishu-content-inbox"
```

停用时执行：

```bash
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/com.example.feishu-content-inbox.plist
```

`RunAtLoad` 负责登录后启动，`KeepAlive` 负责异常退出后重启，`ThrottleInterval` 避免崩溃时高速循环。电脑若真正睡眠或断网，长连接会中断；恢复后 SDK/托管进程应重连，因此仍要监控日志和队列最新时间。

## 8. 验收清单

- 应用已发布，测试账号在可用范围。
- 机器人能力已启用。
- 只有所需的单聊只读权限；无回复需求时没有发送权限。
- 订阅方式为长连接，事件包含 `im.message.receive_v1`。
- `.env` 未进入 Git，权限为 `0600`。
- 非文本、群聊、非白名单链接不会入队。
- 同一消息重推不会产生重复文件。
- 日志不打印完整消息正文、凭据或发送者标识。
- 锁屏后发送链接仍能生成待办；真正睡眠后的行为按设备电源策略验证。
- 消费者失败不会删除待办，成功才归档。

## 9. 常见故障

| 现象 | 优先检查 |
|---|---|
| 飞书里搜索不到机器人 | 应用版本是否发布；当前用户是否在可用范围 |
| SDK 提示长连接不可用 | 是否为企业自建应用；后台是否选择长连接接收事件 |
| 能连接但收不到消息 | 是否添加 `im.message.receive_v1`；是否有单聊只读权限；新配置是否已发布 |
| 收到事件但没有 JSON | 消息是否为单聊文本；域名是否在 `ALLOWED_HOSTS`；`QUEUE_DIR` 是否为可写绝对路径 |
| 一条消息生成多条记录 | 是否用排他创建和稳定哈希；是否在不同应用版本运行了多个接收器 |
| 锁屏后停止接收 | 判断是锁屏还是系统睡眠；检查 `launchctl` 状态、错误日志和电源策略 |
| 回调偶发重复 | 飞书超时重推是正常故障模型；入队必须幂等，处理器也应按 URL/内容 ID 去重 |

## 10. 方案选择

使用本模板的条件：个人或小团队、自建应用、只接收链接、本机可以持续联网、允许本地保存待办。

不要使用本模板的条件：需要公网多租户服务、严格高可用、多人广播同一事件、需要卡片交互或机器人回复、需要处理文件/图片消息、不能在本机保存链接。此时应改用正式服务端、队列和数据库，并重新设计鉴权、审计、加密、删除和灾难恢复。

## 官方来源

- [飞书机器人快速开发](https://open.feishu.cn/document/develop-an-echo-bot/introduction)
- [应用配置说明](https://open.feishu.cn/document/develop-an-echo-bot/faq)
- [接收事件与长连接/Webhook边界](https://open.feishu.cn/document/server-docs/event-subscription-guide/event-subscription-configure-/encrypt-key-encryption-configuration-case?lang=en-US)
- [接收消息事件与权限](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/im-v1/message-development-tutorial/introduction)
- [官方 Node.js SDK](https://github.com/larksuite/node-sdk)
- [测试企业与正式版边界](https://open.feishu.cn/document/tools-and-resources/test-and-release-app)
