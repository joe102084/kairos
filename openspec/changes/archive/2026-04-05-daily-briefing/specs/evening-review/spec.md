## ADDED Requirements

### Requirement: Evening Data Gathering

系統 SHALL 在每日 18:00 SGT 自動收集以下資料源。

#### Scenario: Today's accomplishments
- **WHEN** evening review 被觸發
- **THEN** 系統 SHALL 透過 claude-mem `timeline` 查詢今日的 observations（limit 10）
- **AND** 摘要為「今日完成事項」列表

#### Scenario: Today's daily log
- **WHEN** evening review 被觸發
- **THEN** 系統 SHALL 嘗試讀取 `Vault/Logs/YYYY-MM-DD.md`（當日日期）
- **AND** 如果檔案不存在，跳過此區塊

#### Scenario: Tomorrow's calendar preview
- **WHEN** evening review 被觸發
- **THEN** 系統 SHALL 透過 `gcal_list_events` 取得明日行程
- **AND** 標記第一個行程的時間，作為「明天幾點要出門」的提醒

#### Scenario: Polaris reflection prompt
- **WHEN** evening review 被觸發
- **THEN** 系統 SHALL 讀取 Polaris 目標檔案
- **AND** 產生一個與今日工作內容相關的反思提問
- **AND** 提問應具體且可回答，而非泛泛的「你今天學到了什麼」

### Requirement: Evening Telegram Delivery

Claude 生成 evening review 至 stdout，shell wrapper 透過 Telegram Bot API 發送，機制與 morning briefing 一致。

#### Scenario: Successful delivery
- **WHEN** review 內容組合完成
- **THEN** Claude SHALL 輸出 review 文字至 stdout
- **AND** shell wrapper SHALL 透過 Telegram Bot API 發送
- **AND** 訊息長度不超過 2000 字元
- **AND** 若 Markdown 解析失敗，自動以純文字重送

#### Scenario: Weekend mode
- **WHEN** 當日為星期六或星期日
- **THEN** 系統 SHALL 跳過 email 和工作相關區塊
- **AND** 改為聚焦 side project 進度和個人目標

### Requirement: Daily Log Auto-Generation

Evening review 完成 Telegram 推送後，SHALL 將當日客觀事實寫入 Obsidian Vault。

#### Scenario: New daily log
- **WHEN** `Vault/Logs/YYYY-MM-DD.md` 不存在
- **THEN** 系統 SHALL 建立該檔案，包含 Meetings、Completed 區塊
- **AND** 標記 `#source/kairos` 以區分機器生成與手動內容
- **AND** 底部保留空白的 `## Diary` 區塊供 Jo 手動填寫

#### Scenario: Existing daily log
- **WHEN** `Vault/Logs/YYYY-MM-DD.md` 已存在（Jo 或其他 session 已寫入）
- **THEN** 系統 SHALL 在檔案末尾 APPEND `## Kairos Auto-Log` 區塊
- **AND** 不得覆蓋或修改既有內容

#### Scenario: Content boundary
- **WHEN** 系統寫入 daily log
- **THEN** 系統 SHALL 僅記錄客觀事實（會議、完成的 task、code changes）
- **AND** 不得加入詮釋、情緒判斷或主觀評論
- **AND** Jo 的個人反思由 second-brain skill 手動觸發寫入，不在此範圍
