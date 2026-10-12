# Trial: feedback loop on Spring PetClinic

**Date:** 2026-10-12 · **Kit:** `b53deac` · **Harness:** Claude Code headless, claude-sonnet-5-5
**Input:** the two finished PetClinic tickets (PET-7 defect, PET-12 feature), delivered on older kit versions, with no retros.

## Outcome

| Step | Result |
| --- | --- |
| Upgrade | `install.sh` created `standards/` (3 files), `lessons.md`, `improvements/` and `VERSION`; kept config, context, settings and both tickets |
| Menu | Showed **Improve the process (2 new retros)** |
| Retros | Written for both tickets: PET-7 5 findings, PET-12 7, each tagged with component and scope |
| Grouping | 5 proposals across the two tickets; 1 group dropped because `standards/testing.md` already covered it |
| Decisions | 4 × `y`, 1 × `n` (logged with reason) |
| Local changes | `standards/testing.md` (input-handling tests and user-visible errors), `standards/security.md` (binder rule for cached entities), `standards/engineering.md` (grep callers in plans; tick steps), `lessons.md` (i18n test is outside the scoped build) |
| Upstream | 3 anonymised `[lesson]` issue drafts with kit version, proposed skill text and a regression scenario; nothing posted |
| Records | Decision log written; both retros marked `processed: true`; 1 group left for a later session |
| Cost | about $1 |

The most valuable lesson came from combining a human rejection in one ticket with a miss in another: input-handling changes need tests for unusual and invalid input, plus the user-visible message. That is something no single ticket showed clearly.

## Problems found and fixed in the kit

| # | Problem | Fix |
| --- | --- | --- |
| 1 | A proposal card was announced ("ready for your y or n") but never printed. | Approval-card rule, orchestrator and improve skill: the card is the last thing in the message, printed in full, every time. |
| 2 | Upstream parts proposed fixes the kit already had, because the tickets ran on an older kit. | Improve skill searches the installed kit files before drafting upstream, and reports `already in kit <VERSION>`. |
| 3 | The lessons template's example was a real PetClinic fact, which looked like a real entry. | Generic example, marked "delete once you have real entries". |
