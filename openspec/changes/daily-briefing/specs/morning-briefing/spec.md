## ADDED Requirements

### Requirement: Morning Data Gathering

系統 SHALL 在每日 09:00 SGT 自動收集以下資料源，總 token 消耗不超過 5,000 tokens（不含 system prompt 和 reasoning）。

#### Scenario: Calendar events retrieval
- **WHEN** morning briefing 被觸發
- **THEN** 系統 SHALL 透過 `gcal_list_events` 取得今日所有行程
- **AND** 以「時間 + 事件名稱」格式呈現，依時間排序

#### Scenario: Yesterday's work summary
- **WHEN** morning briefing 被觸發
- **THEN** 系統 SHALL 透過 claude-mem `timeline` 查詢昨日的 observations（limit 10）
- **AND** 摘要為 3-5 個重點項目

#### Scenario: Polaris goals reminder
- **WHEN** morning briefing 被觸發
- **THEN** 系統 SHALL 讀取 Obsidian Vault 中 `Polaris/Seasonal Goals.md` 和 `Polaris/Top of Mind.md`
- **AND** 從中提取當季目標，與今日行程做交叉對照

#### Scenario: Important emails check
- **WHEN** morning briefing 被觸發
- **THEN** 系統 SHALL 透過 `gmail_search_messages` 搜尋過去 24 小時的信件
- **AND** 僅顯示寄件者 + 主旨，不讀取信件內文
- **AND** 最多顯示 5 封最相關的信件

### Requirement: Morning Telegram Delivery

系統 SHALL 將 briefing 透過 Telegram `reply` tool 發送至指定 chat_id。

#### Scenario: Successful delivery
- **WHEN** briefing 內容組合完成
- **THEN** 系統 SHALL 發送一則 Telegram 訊息
- **AND** 訊息長度不超過 2000 字元
- **AND** 使用 Telegram-compatible markdown 格式（bold, bullet points）

#### Scenario: Partial data source failure
- **WHEN** 任一資料源（Calendar / Gmail / claude-mem / Obsidian）不可用
- **THEN** 系統 SHALL 跳過該區塊並標註「[unavailable]」
- **AND** 仍然發送包含可用資料的 briefing

### Requirement: Token Budget

系統 SHALL 將每次 briefing 的總 token 消耗控制在 ~15K input + ~2K output 以內。

#### Scenario: Budget enforcement
- **WHEN** briefing agent 執行
- **THEN** system prompt 中 SHALL 明確限制：最多讀取 10 筆 claude-mem observations、2 個 Polaris 檔案、5 封 email subjects、不讀取 email body
