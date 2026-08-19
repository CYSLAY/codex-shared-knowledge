import "dotenv/config";
import * as Lark from "@larksuiteoapi/node-sdk";
import { createHash } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

const appId = process.env.FEISHU_APP_ID;
const appCredential = process.env.FEISHU_APP_SECRET;
const queueDir = process.env.QUEUE_DIR;
const allowedHosts = new Set(
  (process.env.ALLOWED_HOSTS ?? "v.douyin.com,www.douyin.com")
    .split(",")
    .map((host) => host.trim().toLowerCase())
    .filter(Boolean),
);

if (!appId || !appCredential) {
  throw new Error("Missing Feishu application credentials in the local .env file.");
}

if (!queueDir || !path.isAbsolute(queueDir)) {
  throw new Error("QUEUE_DIR must be an explicit absolute path.");
}

await mkdir(queueDir, { recursive: true });

function extractAllowedUrls(text) {
  const matches = text.match(/https?:\/\/[^\s<>"']+/g) ?? [];
  const urls = [];

  for (const match of matches) {
    const candidate = match.replace(/[\]）)】}，。！？、；：,.;:!?]+$/u, "");
    try {
      const parsed = new URL(candidate);
      if (allowedHosts.has(parsed.hostname.toLowerCase())) urls.push(parsed.href);
    } catch {
      // Ignore malformed URLs instead of blocking the event callback.
    }
  }

  return [...new Set(urls)];
}

function makeDedupeKey(messageId, index, url) {
  return createHash("sha256")
    .update(`${messageId}:${index}:${url}`)
    .digest("hex")
    .slice(0, 32);
}

const eventDispatcher = new Lark.EventDispatcher({}).register({
  "im.message.receive_v1": async (event) => {
    const message = event.message;
    if (message?.chat_type !== "p2p" || message?.message_type !== "text") return;

    let text;
    try {
      text = JSON.parse(message.content).text ?? "";
    } catch {
      return;
    }

    const urls = extractAllowedUrls(text);
    for (const [index, url] of urls.entries()) {
      const dedupeKey = makeDedupeKey(String(message.message_id), index, url);
      const target = path.join(queueDir, `${dedupeKey}.json`);
      const record = {
        source: "feishu",
        platform: new URL(url).hostname.endsWith("douyin.com") ? "douyin" : "web",
        url,
        dedupe_key: dedupeKey,
        received_at: new Date().toISOString(),
        status: "pending",
        attempts: 0,
      };

      try {
        await writeFile(target, `${JSON.stringify(record, null, 2)}\n`, {
          flag: "wx",
          mode: 0o600,
        });
        console.log(`Queued link ${dedupeKey} from ${new URL(url).hostname}`);
      } catch (error) {
        if (error?.code !== "EEXIST") throw error;
      }
    }
  },
});

const wsClient = new Lark.WSClient({
  appId,
  appSecret: appCredential,
  loggerLevel: Lark.LoggerLevel.info,
});

console.log("Connecting to Feishu event stream...");
await wsClient.start({ eventDispatcher });
