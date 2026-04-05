## 1. Prerequisites Validation

- [x] 1.1 確認 `claude` CLI 路徑，為 Decision 1: `claude -p` Headless Mode as Runtime 做準備
- [x] 1.2 測試 Calendar MCP in `-p` mode — ✓ 成功取得今日行程
- [x] 1.3 測試 Gmail MCP in `-p` mode — ⚠ Auth 失敗，Decision 5: Graceful Degradation per Data Source 適用
- [x] 1.4 測試 claude-mem in `-p` mode — ✓ timeline tool 可用
- [x] 1.5 測試 Telegram — ✓ 初始用 MCP plugin（不穩定），後改為 Decision 6: Telegram Delivery via Direct Bot API
- [x] 1.6 測試 Obsidian 檔案讀取 — ✓ Seasonal Goals.md 可正常讀取
- [x] 1.7 確認 Decision 4: Permission Mode — 先 Skip 後 Tighten — 需要 `--dangerously-skip-permissions`

## 2. System Prompt & Templates

- [x] 2.1 撰寫 `kairos-system.md` — 實作 Morning Data Gathering、Evening Data Gathering、Morning Telegram Delivery、Evening Telegram Delivery 的內容生成邏輯，含 Decision 3: Sonnet 4.5 as Default Model、Decision 5: Graceful Degradation、Decision 7: Daily Log — 事實自動、反思手動、Token Budget 限制
- [x] 2.2 撰寫 `templates/morning.md` — 使用 {{}} 佔位符
- [x] 2.3 撰寫 `templates/evening.md` — 含 Daily Log Auto-Generation 指示
- [x] 2.4 撰寫 `config.env` — 含 BOT_TOKEN 支援 Decision 6: Direct Bot API
- [x] 2.5 手動測試 morning prompt — ✓ Telegram 送達
- [x] 2.6 手動測試 evening prompt — ✓ Telegram 送達，Daily log graceful skip 正常

## 3. Shell Wrapper

- [x] 3.1 撰寫 `kairos-briefing.sh` — 實作 Decision 1 和 Decision 6: Telegram Delivery via Direct Bot API (not MCP Plugin)（curl Bot API 取代 MCP plugin）
- [x] 3.2 加入 retry 機制 — Decision 5: Graceful Degradation
- [x] 3.3 加入 kill switch
- [x] 3.4 手動執行 morning — ✓ 驗證通過
- [x] 3.5 手動執行 evening — ✓ 驗證通過

## 4. launchd Scheduling

- [x] 4.1 撰寫 `com.kairos.morning.plist` — Decision 2: macOS launchd over crontab，06:00 SGT，Decision 8: 專案位置 `~/.kairos/`
- [x] 4.2 撰寫 `com.kairos.evening.plist` — 18:00 SGT
- [x] 4.3 載入 plists — ✓ 成功
- [x] 4.4 手動觸發 launchctl start — ✓ 送達
- [x] 4.5 確認 launchd 環境 PATH — ✓ Decision 2: macOS launchd 環境差異已解決

## 5. Validation & Polish

- [x] 5.1 確認自動排程執行 — ✓ 4/3 evening 和 4/4 morning 成功送達；4/4 evening 和 4/5 morning 因 MCP plugin 不穩定失敗，已透過 Decision 6 修復
- [ ] 5.2 根據實際收到的訊息迭代 system prompt — ⏳ 需收到 2-3 次 briefing 後調整
- [x] 5.3 加入 weekend mode — ✓ 已在 kairos-system.md 中實作
- [ ] 5.4 驗證 Mac mini 重啟後 Decision 2: macOS launchd 自動恢復排程 — ⏳ 需下次重啟驗證
- [ ] 5.5 確認月 token 消耗符合 Token Budget 預算（~$10/month） — ⏳ 需運行一週後估算
- [x] 5.6 Daily Log Auto-Generation — ✓ evening briefing 自動寫入 Vault/Logs/，標記 #source/kairos，保留空白 Diary 區塊
