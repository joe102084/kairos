## 1. Prerequisites Validation

- [x] 1.1 確認 `claude` CLI 路徑：執行 `which claude` 並記錄絕對路徑，為 Decision 1: `claude -p` Headless Mode as Runtime 做準備
- [x] 1.2 測試 Calendar MCP in `-p` mode — ✓ 成功取得今日行程
- [x] 1.3 測試 Gmail MCP in `-p` mode — ⚠ Auth 失敗，需重新授權。Design Decision 5 Graceful Degradation 適用，briefing 將跳過 email 區塊直到修復
- [x] 1.4 測試 claude-mem in `-p` mode — ✓ timeline tool 可用（當日 observations 可查）
- [x] 1.5 測試 Telegram reply in `-p` mode — ✓ 訊息成功送達 (message ID: 62)
- [x] 1.6 測試 Obsidian 檔案讀取 — ✓ Seasonal Goals.md 可正常讀取並摘要
- [x] 1.7 確認 Decision 4: Permission Mode — 先 Skip 後 Tighten — 確認需要 `--dangerously-skip-permissions` 才能在 `-p` mode 使用 MCP tools

## 2. System Prompt & Templates

- [x] 2.1 撰寫 `kairos-system.md` — ✓ 含角色定義、token 限制、收集順序、Telegram 格式、error handling、weekend mode
- [x] 2.2 撰寫 `templates/morning.md` — ✓ 使用 {{}} 佔位符避免 sed 碰撞
- [x] 2.3 撰寫 `templates/evening.md` — ✓ 同上格式
- [x] 2.4 撰寫 `config.env` — ✓ 含 CLI path、model、vault path、kill switch
- [x] 2.5 手動測試 morning prompt — ✓ Telegram message ID: 63 成功送達，Gmail graceful degradation 正常
- [x] 2.6 手動測試 evening prompt — ✓ Telegram message ID: 64，Daily log graceful skip 正常

## 3. Shell Wrapper

- [x] 3.1 撰寫 `kairos-briefing.sh` — ✓ 含 source config、日期計算、template substitution、claude -p 呼叫
- [x] 3.2 加入 retry 機制 — ✓ 首次失敗等 60 秒重試
- [x] 3.3 加入 kill switch — ✓ 檢查 KAIROS_ENABLED
- [x] 3.4 手動執行 morning — ✓ Task 2.5 已驗證（Telegram message ID: 63）
- [x] 3.5 手動執行 evening — ✓ Telegram message ID: 64，~60 秒完成

## 4. launchd Scheduling

- [x] 4.1 撰寫 `com.kairos.morning.plist` — ✓ 06:00 SGT，項目移至 ~/.kairos/ 避免 macOS TCC 限制
- [x] 4.2 撰寫 `com.kairos.evening.plist` — ✓ 18:00 SGT
- [x] 4.3 載入 plists — ✓ 兩個 plist 成功載入
- [x] 4.4 手動觸發 launchctl start — ✓ Telegram message ID: 65 送達，~2m45s 執行完成
- [x] 4.5 確認 launchd 環境 PATH — ✓ 使用 /bin/zsh 顯式調用 + 明確設定 PATH 解決環境差異

## 5. Validation & Polish

- [ ] 5.1 等待一次自動排程執行，確認 Morning Telegram Delivery 或 Evening Telegram Delivery 自動送達 — ⏳ 下次觸發：今天 18:00 SGT evening briefing
- [ ] 5.2 根據實際收到的訊息調整 system prompt 中 Morning Data Gathering 和 Evening Data Gathering 的呈現格式 — ⏳ 需收到 2-3 次 briefing 後迭代
- [x] 5.3 加入 weekend mode — ✓ 已在 kairos-system.md 中實作（週末跳過 email，聚焦 side project/personal goals）
- [ ] 5.4 驗證 Mac mini 重啟後 Decision 2: macOS launchd 自動恢復排程 — ⏳ 需下次重啟驗證
- [ ] 5.5 確認月 token 消耗符合 Token Budget 預算（~$10/month） — ⏳ 需運行一週後估算
