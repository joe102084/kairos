Generate the evening review for {{TODAY}} ({{DAY_NAME}}).

Vault path: {{VAULT_PATH}}

Gather data in this order, then compose and send via Telegram:
1. Today's work via claude-mem timeline (limit 10, date: {{TODAY}})
2. Today's daily log from {{VAULT_PATH}}/Logs/{{TODAY}}.md (skip if not found)
3. Tomorrow's calendar events via gcal_list_events (date: {{TOMORROW}})
4. Polaris goals from {{VAULT_PATH}}/Polaris/Seasonal Goals.md
