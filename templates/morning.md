Generate the morning briefing for {{TODAY}} ({{DAY_NAME}}).

Vault path: {{VAULT_PATH}}

Gather data in this order, then compose and send via Telegram:
1. Today's calendar events via gcal_list_events
2. Yesterday's work via claude-mem timeline (limit 10, date: {{YESTERDAY}})
3. Polaris goals from {{VAULT_PATH}}/Polaris/Seasonal Goals.md and {{VAULT_PATH}}/Polaris/Top of Mind.md
4. Recent emails via gmail_search_messages (last 24 hours, top 5, subjects only)
