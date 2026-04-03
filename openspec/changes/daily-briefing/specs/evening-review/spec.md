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

系統 SHALL 將 evening review 透過 Telegram 發送，格式與 morning briefing 一致。

#### Scenario: Successful delivery
- **WHEN** review 內容組合完成
- **THEN** 系統 SHALL 發送一則 Telegram 訊息
- **AND** 訊息長度不超過 2000 字元

#### Scenario: Weekend mode
- **WHEN** 當日為星期六或星期日
- **THEN** 系統 SHALL 跳過 email 和工作相關區塊
- **AND** 改為聚焦 side project 進度和個人目標
