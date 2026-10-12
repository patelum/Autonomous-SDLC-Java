# Trial: Spring PetClinic, feature track, Claude Code

**Date:** 2026-10-12 · **Kit:** `e59aefc` (upgraded in place with `install.sh`; config, context and specs kept) · **Harness:** Claude Code 2.1.296 headless, claude-sonnet-5-5
**App:** Spring PetClinic, same branch as the [defect trial](2026-10-12-spring-petclinic.md) · **Result:** [patelum/spring-petclinic `ai-sdlc-trial`](https://github.com/patelum/spring-petclinic/tree/ai-sdlc-trial), commit `1f210a3`

**Ticket PET-12:** record which vet a visit is with. Optional vet dropdown on Add Visit; vet name on the owner page; existing visits vet-less; vets stay read-only.

Chosen because it crosses a module boundary (owner → vet), needs a schema change in three hand-written `schema.sql` files that were on the `protect:` list, and touches 11 locale files guarded by a sync test.

## Outcome

| Step | What happened | Human input |
| --- | --- | --- |
| Intake | Ticket given with `/ai-sdlc build a feature: …`, so the menu was skipped | ticket text |
| Spec, G1 | 12 ACs, including edge cases not in the request (empty vet list, selection kept after a validation error, all locales, upgrade of existing DBs) | `y` |
| Design, G2 | Escalations folded into the design card: owner → vet dependency, schema change, protected `schema.sql` edits, H2 DROP reordering. **But** it left MySQL upgrade as an open "human decision" | `n` → `4` + chose manual ALTER |
| Design, G2 | Revised with my choice | `y` |
| Plan, G3 | 8 steps; corrected its own design (only one test slice needs the new mock); noted the DB tests need Docker | `y` |
| Implement → verify | 7 steps green with no retries; the full build failed once on `I18nPropertiesSyncTest` (an `&nbsp;` in the new dropdown), fixed automatically on the first retry | — |
| Test, review, security | 11/12 ACs covered by passing tests; review found a must-fix (nested `vet.*` binding could rename the shared cached vet), fixed and re-reviewed; security 0 high/medium | — |
| Final, G4 | I ran the app: posting an unknown vet showed Spring's raw conversion error to the user. Review had rated it only "consider" | `n` → `3` + finding |
| Rework | One `typeMismatch.vet` key in the message files, tests asserting the rendered text; no Java change | — |
| Final, G4 | | `y` |

- **Diff:** 24 files, +359/−15, 2 new classes (`VetFormatter`, tests). No new library.
- **Build:** `./mvnw verify` green, 105 test cases (103 run, 2 skipped: MySQL/Postgres Testcontainers, no Docker), independently re-run.
- **Live check:** dropdown lists 6 vets; visit booked with Helen Leary shows her on the owner page; visit without vet shows blank; unknown vet shows "invalid vet" (German: "ungültiger Tierarzt").
- **Not verified:** AC-8 on MySQL and PostgreSQL. Flagged on every card.
- **Cost / time:** about $4.50 for the ticket session; about 39 minutes of agent time (28 in implement → security).
- **Human time:** 7 answers, plus my own review and live check.

## Problems found and fixed in the kit

| # | Problem | Fix |
| --- | --- | --- |
| 1 | A gate carried an open either/or choice, so `y` could not approve a complete design. | Approval-card rule: every Decide item states the choice already made; open choices become a numbered escalation before the gate. |
| 2 | Log timestamps were invented (19:20–20:35 when the clock said ~17:15). | Status format and orchestrator: timestamps come from `date`, never memory. |
| 3 | Protected-path and dependency approvals given at G2 lived only in prose. | `approvals:` list in `status.md`; implementer and reviewer read it; an unlisted protected-path edit is a must-fix. |
| 4 | Raw conversion error shown to users was rated "consider". | Review skill: user-facing text that leaks internals or bypasses message files is must-fix; exercise the main user path when the app starts cheaply. |
| 5 | `.claude/settings.json` permissions were ignored because the folder was untrusted. | README: trust the folder once in interactive Claude Code. |

## What worked

- Spec quality: ACs covered upgrade, i18n and edge cases a developer would likely forget.
- Self-healing loop: full-build failure fixed without bothering the human.
- Independent review and security caught a real mass-assignment issue before the human saw the diff.
- Honest cards: unverified DB paths and agent-written translations were called out every time.
- In-place upgrade of the kit kept config, context and the earlier ticket intact.
