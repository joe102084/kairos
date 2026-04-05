# Changelog

All notable changes to Kairos are documented here.

## [0.2.0] — 2026-04-05

### Fixed
- Telegram delivery switched from MCP plugin to direct Bot API (curl) — MCP plugin was unreliable in launchd headless mode

### Changed
- Claude now outputs briefing text to stdout; shell wrapper handles delivery
- Added Markdown → plain text fallback for Telegram formatting errors

## [0.1.0] — 2026-04-03

### Added
- Morning briefing at 06:00 SGT — calendar, claude-mem work log, Polaris goals, email summary
- Evening review at 18:00 SGT — accomplishments, tomorrow preview, reflection prompt
- macOS launchd scheduling (survives reboot)
- Graceful degradation per data source (skip unavailable, still deliver)
- Weekend mode (skip work email, focus on personal goals)
- Daily log auto-generation to Obsidian Vault (`#source/kairos`, facts only)
- Empty `## Diary` section preserved for manual personal reflection
- Kill switch via `KAIROS_ENABLED` in config.env
- Retry mechanism (60s wait, one retry on failure)

### Architecture
- Runtime: `claude -p` headless mode + `--system-prompt-file`
- Scheduler: macOS launchd (not cron)
- Model: Sonnet 4.5 (cost-efficient for routine tasks)
- Project at `~/.kairos/` (avoids macOS TCC restrictions on ~/Documents/)
- SDD methodology with Spectra (proposal → specs → design → tasks)
