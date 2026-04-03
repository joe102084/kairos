## Why

Jo 的日常工作資料分散在五個系統中：claude-mem（工作日誌）、Obsidian Vault（個人目標與知識）、Google Calendar（行程）、Gmail（信件）、Telegram（通訊）。每天早上需要手動打開多個工具來拼湊「今天該做什麼」，晚上也沒有系統性的回顧機制。

需要一個 orchestration layer，自動從各資料源收集資訊，產生精煉的每日 briefing，透過 Telegram 主動推送——從「我去找 AI」變成「AI 來找我」。

## What Changes

- 建立 morning briefing（每日 09:00 SGT）：今日行程、昨日工作摘要、Polaris 目標提醒、重要未讀信件
- 建立 evening review（每日 22:00 SGT）：今日完成事項、明日行程預覽、與 Polaris 目標對齊的反思提問
- 透過 macOS launchd 定時排程，呼叫 `claude -p`（headless mode）執行
- 所有資料收集透過既有 MCP tools，不建立新 server 或 daemon

## Capabilities

### New Capabilities

- `morning-briefing`：每日早報，整合 Calendar + Gmail + claude-mem + Obsidian Polaris
- `evening-review`：每日晚報，整合 claude-mem + Calendar + Obsidian Polaris + 反思提問

### Modified Capabilities

（None）

## Not Doing

- 不建立新的 MCP server 或 persistent daemon
- 不建立新的資料庫
- 不整合 Home Assistant / Aqara 智慧家庭（Phase B）
- 不做 Gmail/Calendar 中午摘要推送（Phase C）
- 不做自然語言互動回覆（briefing 是單向推送）
- 不修改任何現有系統的配置

## Impact

- **Code**: 新增 `kairos-system.md`, `kairos-briefing.sh`, `templates/*.md`, `config.env`
- **Infrastructure**: 新增 2 個 launchd plist（`~/Library/LaunchAgents/com.kairos.*.plist`）
- **Dependencies**: 僅使用已安裝的 `claude` CLI 和既有 MCP tools
- **Cost**: 預估 ~$10/month（2 runs/day × ~17K tokens/run on Sonnet）

## MCP Tools Used

| Tool | Source | Purpose |
|------|--------|---------|
| `gcal_list_events` | Google Calendar MCP | 取得今日/明日行程 |
| `gmail_search_messages` | Gmail MCP | 搜尋近 24 小時重要信件 |
| `search`, `timeline` | claude-mem plugin | 查詢昨日/今日工作紀錄 |
| `reply` | Telegram plugin | 發送 briefing 訊息 |
| Read tool | Built-in | 讀取 Obsidian Vault Polaris 檔案 |
