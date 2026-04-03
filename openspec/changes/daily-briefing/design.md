## Context

Kairos 的 Phase A 目標是建立每日兩次的自動化 briefing 系統。所有資料源（claude-mem、Obsidian、Gmail、Calendar、Telegram）已經透過 MCP tools 可用於 Claude Code session 中，但缺少一個定時觸發的 orchestration 機制。

## Goals / Non-Goals

**Goals:**
- 每日 09:00 / 22:00 SGT 自動產生並推送 briefing
- 使用既有 MCP tools，不引入新的 infrastructure
- Token 消耗可控（~$10/month）
- 非工程師可維護（改 config 而非改 code）

**Non-Goals:**
- 不做雙向對話（briefing 是單向推送）
- 不做即時觸發（只有排程觸發）
- 不建立新的 server 或 daemon process

## Decisions

### Decision 1: `claude -p` Headless Mode as Runtime

使用 `claude -p` (print/headless mode) 搭配 `--system-prompt-file` 執行 briefing。

**Why:** Claude Code 的 `-p` mode 支援所有 MCP tools（包括 cloud connectors 如 Gmail/Calendar），每次執行是獨立 session，不需要 persistent process。替代方案（自建 Python script 呼叫 API）需要自行管理 OAuth tokens 和 MCP 連線。

**Trade-off:** 每次啟動有 ~5-10 秒的 cold start，但對排程任務可接受。

### Decision 2: macOS launchd over crontab

使用 launchd plist 做排程，而非 crontab。

**Why:** macOS 官方推薦 launchd 取代 crontab。launchd 會在 sleep/wake 後補執行錯過的排程、可以設定 environment variables、有內建 logging、生存 reboot。crontab 在 macOS 上行為不一致，且需要 Full Disk Access 權限。

### Decision 3: Sonnet 4.5 as Default Model

使用 `claude-sonnet-4-5` 而非 Opus。

**Why:** Briefing 是 routine 任務，不需要 Opus 的深度推理。Sonnet 的品質對於資料收集 + 摘要足夠，成本約為 Opus 的 1/5。在 config.env 中可切換。

### Decision 4: Permission Mode — 先 Skip 後 Tighten

初始使用 `--dangerously-skip-permissions`，穩定後改用 `allowedTools`。

**Why:** `-p` mode 在首次使用每個 MCP tool 時需要互動式核准。自動化場景無法互動。`--dangerously-skip-permissions` 是 bootstrap 階段的務實選擇，因為 script 是本機執行、無外部輸入、明確限定 scope。穩定後可改為 project-level `allowedTools` 白名單。

### Decision 5: Graceful Degradation per Data Source

每個資料源獨立，任一失敗不阻塞整體 briefing。

**Why:** Cloud MCP connectors（Gmail/Calendar）可能因 OAuth token 過期或網路問題失敗。claude-mem worker 可能未啟動。Obsidian 檔案可能被移動。System prompt 中明確指示：每個區塊獨立嘗試，失敗時標註 `[unavailable]` 並繼續。

## Token Budget Breakdown

| Component | Est. Tokens |
|-----------|------------|
| System prompt (static, cacheable) | ~1,500 |
| Calendar events (3-8 events) | ~500 |
| Gmail subjects (5 emails) | ~500 |
| claude-mem timeline (10 obs) | ~1,500 |
| Obsidian Polaris (2 files) | ~800 |
| Daily log (if exists) | ~1,000 |
| Tool call overhead + reasoning | ~9,200 |
| **Total input** | **~15,000** |
| **Output (briefing message)** | **~2,000** |

月成本估算：15K + 2K tokens × 2 runs/day × 30 days = ~1M input + ~120K output tokens/month ≈ $7-10/month on Sonnet

## File Architecture

```
kairos/
├── kairos-system.md          ← System prompt：briefing agent 的角色、規則、資料收集步驟
├── kairos-briefing.sh        ← Shell wrapper：launchd 呼叫的入口
├── config.env                ← 運行時配置（chat_id, paths, model, kill switch）
├── templates/
│   ├── morning.md            ← Morning user prompt（日期 + 收集順序指示）
│   └── evening.md            ← Evening user prompt
└── logs/                     ← 執行日誌（.gitignore'd）
```

launchd plists 放在 `~/Library/LaunchAgents/com.kairos.{morning,evening}.plist`。

## Risks / Trade-offs

- Cloud MCP connectors 在 `-p` mode 可能需要 bridge session → 先手動測試，失敗時 graceful skip
- launchd 環境的 PATH 不含 `claude` → plist 中顯式設定 PATH
- Telegram plugin 在 `-p` mode 的 boot/shutdown 行為未知 → 先手動驗證
- System prompt 會隨使用迭代調整 → 預留 Phase 5 做 prompt refinement
