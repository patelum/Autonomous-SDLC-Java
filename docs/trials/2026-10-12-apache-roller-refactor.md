# Trial: Apache Roller, refactor track, Claude Code

**Date:** 2026-10-12 · **Kit:** `1abe856` plus the wrapper fix below · **Harness:** Claude Code 2.1.296 headless, claude-sonnet-5-5
**App:** [apache/roller](https://github.com/apache/roller) at `457de9c`: Jakarta EE 10 blog server, Maven multi-module (`app`, `db-utils`), no Maven wrapper, 705 Java files, 488 tests on embedded Derby

**Ticket RF-3:** move the HTML and truncation helpers out of the 1,114-line `Utilities` class into a new `HtmlUtilities`, keeping every old public method as a `@Deprecated` one-line delegate. No behaviour change.

## Outcome

| Step | What happened | Human input |
| --- | --- | --- |
| Install | No `mvnw` in the repo; installer (after the fix below) wrote `mvn` commands and multi-module defaults | — |
| Context, pass 1 | Two context files: `app` (564 of 565 main classes) and `db-utils` (1 class). Correct, but useless as per-task context. Agent flagged the planet ↔ weblogger cycle | `/ai-sdlc set up project context` |
| Context, pass 2 | I asked for logical modules inside `app`. Agent made 8 (weblogger-business, -pojos, util-config, ui-core, ui-rendering, ui-struts2, webservices, planet), a scoped test pattern per module, and recorded 3 package cycles. It corrected my suggested Surefire pattern after testing it | answers to 7 questions |
| Characterise | 48 characterisation tests on the original code, all green; found 3 latent bugs and pinned them as-is | — |
| Plan, G1 | 6 steps. Every Decide item said what `y` means (new rule worked) | `y` |
| Refactor → verify → review | Moved in 3 groups with scoped builds; full build green; reviewer confirmed all moved bodies and 24 regexes identical and 40 public signatures intact | — |
| Final, G2 | 0 must-fix, 3 consider | `y` |

- **Diff:** `Utilities.java` 1,114 → 674 lines; `HtmlUtilities.java` new (583 lines); `UtilitiesCharacterisationTest` new. No existing test line changed.
- **Build:** `mvn verify` green, 536 test cases (488 + 48), 0 failures, independently re-run.
- **Safety net check:** with the original `Utilities.java` restored and `HtmlUtilities` removed, the 48 characterisation tests and `UtilitiesTest` all pass. They pin the original behaviour, not the new one.
- **Latent bugs found** (preserved, for separate defect tickets), independently confirmed:
  - `addNofollow` has an inverted condition: links without `rel="nofollow"` are left alone, and links that already have it get it twice.
  - `truncateNicely(null, …)` throws a NullPointerException.
  - `truncate(s, n, null)` appends the text "null".
- **Cost / time:** about $1.60 for context (two passes) and $2.00 for the ticket; about 15 minutes of agent time for the ticket.
- **Human input:** 3 answers for the ticket.

## Problems found and fixed in the kit

| # | Problem | Fix |
| --- | --- | --- |
| 1 | Config assumed `./mvnw`; Roller has no wrapper. Default permissions allowed only `./mvnw`. | Installer falls back to `mvn` / `gradle` when no wrapper exists; default permissions also allow `mvn` and `gradle`. |
| 2 | "Multi-module" monolith with one giant build module produced one giant context file. | Context skill: split any build module over ~150 main classes into logical modules by package, with a `tests` pattern each; record package cycles. Config documents `{tests}` and Surefire pattern rules. |
| 3 | Timestamps: `date` was used in the first session but not after resuming, so later entries were extrapolated (some in the future). | The `date` call moved into the orchestrator's Record step itself, every time, including after resume. |
| 4 | Context agent piped `mvn verify` through `tail` and never saw the exit code (it said so). | Orchestrator, implement skill and config: no pipes on build commands; an unseen exit code is not green. |

## What worked

- Characterisation-first did its job: a real safety net, verified against the original code, plus three genuine bugs surfaced without being "fixed" inside a refactor.
- The open-choice rule from the feature trial held: both gates were plain approvals of complete artifacts.
- Kit upgrade path and coexistence: Roller's own `skills/` folder was untouched.
