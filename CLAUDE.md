<!-- SPECTRA:START v1.0.1 -->

# Spectra Instructions

This project uses Spectra for Spec-Driven Development(SDD). Specs live in `openspec/specs/`, change proposals in `openspec/changes/`.

## Use `/spectra:*` skills when:

- A discussion needs structure before coding → `/spectra:discuss`
- User wants to plan, propose, or design a change → `/spectra:propose`
- Tasks are ready to implement → `/spectra:apply`
- There's an in-progress change to continue → `/spectra:ingest`
- User asks about specs or how something works → `/spectra:ask`
- Implementation is done → `/spectra:archive`

## Workflow

discuss? → propose → apply ⇄ ingest → archive

- `discuss` is optional — skip if requirements are clear
- Requirements change mid-work? Plan mode → `ingest` → resume `apply`

## Parked Changes

Changes can be parked（暫存）— temporarily moved out of `openspec/changes/`. Parked changes won't appear in `spectra list` but can be found with `spectra list --parked`. To restore: `spectra unpark <name>`. The `/spectra:apply` and `/spectra:ingest` skills handle parked changes automatically.

<!-- SPECTRA:END -->

# Kairos Project Rules

## Spec-Code Sync (MANDATORY)

Every implementation change MUST be reflected in the corresponding spec artifacts:
- Feature added/changed → update `specs/`, `design.md`, `tasks.md`
- Architecture decision → add to `design.md` Decisions section
- New risk discovered → add to `design.md` Risks section
- Schedule or config changed → update all references across specs

### Enforcement Checklist (run before EVERY commit that touches code)
1. `spectra validate --changes <name>` — must pass
2. `spectra analyze <name>` — must show 0 findings
3. If either fails, fix the specs BEFORE committing

### Version Tracking
- Each feature/phase = one Spectra change (`spectra new change <name>`)
- When a phase is complete → `spectra archive <name>`
- Update `CHANGELOG.md` with every user-facing change (timestamp + summary)
- Archived changes in `openspec/changes/archive/` serve as version history

## Git Discipline

- Every change gets its own commit — do NOT batch unrelated changes
- Spec updates and code changes may share a commit if tightly coupled, but prefer separate commits when the scope is distinct
- Commit message format: `type: description` (feat, fix, docs, refactor, chore)
- This project will be published to GitHub — keep history clean and meaningful

## Obsidian Vault Boundary

- Kairos auto-writes to `Vault/Logs/` with `#source/kairos` tag — objective facts only
- Personal reflections are triggered manually by Jo via the `second-brain` skill
- NEVER write interpretive or emotional content to the Vault automatically

## Project Location

This project lives at `~/.kairos/` (not `~/Documents/`) to avoid macOS TCC restrictions on launchd agents.
