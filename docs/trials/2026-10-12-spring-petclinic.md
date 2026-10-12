# Trial: Spring PetClinic, defect track, Claude Code

**Date:** 2026-10-12 · **Kit:** v0.1 (`ded5ed6`) · **Harness:** Claude Code 2.1.296, headless (`claude -p` with `--continue`), model claude-sonnet-5-5
**App:** [spring-projects/spring-petclinic](https://github.com/spring-projects/spring-petclinic) at `500158f`: single Maven module, Spring Boot 4.1, Java 17, 50 Java files, 58 tests
**Result branch:** [patelum/spring-petclinic `ai-sdlc-trial`](https://github.com/patelum/spring-petclinic/tree/ai-sdlc-trial)

## Outcome

A real defect was taken from ticket text to an approved, verified change, with the human answering only menu choices and yes/no.

| Step | What happened | Human input |
| --- | --- | --- |
| Install | `install.sh . --harness claude`; committed | — |
| Context | Menu put "Set up project context" first. Architect subagent wrote `index.md` + 4 module files (owner, vet, model, system), every claim cited, 11 open questions | `1`; reviewed files, answered questions in `config.yaml`, committed |
| Intake | Fresh session, menu → defect → ticket text for **PET-7** (padded pet names bypass the duplicate check) | `1`, ticket text |
| Reproduce | Tester subagent wrote 4 tests; all failed for the reported reason (302 instead of form error) | — |
| Plan, G1 | Architect: root cause `Owner.java:150`; fix by trimming at binding (2 lines). Card listed 3 real decisions | `y` |
| Implement, verify, review | Implementer subagent made the change; scoped and full builds green; separate reviewer subagent: 0 must-fix, 3 consider | — |
| Final, G2 | First card | `n` → `3 missing case` + text |
| Rework | 2 tests added, nested class renamed; re-verified, re-reviewed | — |
| Final, G2 | Card candidly flagged one test as a regression guard and one as never seen failing | `y` |
| Done | `pr.md` written, `state: done`, nothing committed | human committed |

- **Diff:** +2 production lines, +79 test lines. Full `./mvnw verify` green (58 tests, 0 failures), independently re-run.
- **Independent check:** with the fix reverted, 5 of 6 new tests fail, including the one the agent had not run against unfixed code. The agent's claims held.
- **Subagents:** architect, tester, implementer and reviewer each ran as separate subagents. The reviewer never saw implementer reasoning.
- **Cost:** about $0.45 for context setup and $1.50 for the ticket including one rework (Sonnet 5.5).
- **Wall time:** about 13 minutes of agent time for the ticket.

## What worked

- Menu, intake, track routing, gates, rejection reasons and resume across separate CLI invocations, all driven only by `status.md`.
- Approval cards were compact and their **Decide** lines raised genuine judgement calls rather than filler.
- Reproduce-first produced a fix verified by construction.
- Agents marked their own uncertainty (`[assumption]`, "not run against reverted code") instead of overclaiming.

## Problems found and fixed in the kit

| # | Problem | Fix |
| --- | --- | --- |
| 1 | Default `verify_module` (`-pl {module} -am`) cannot work on a single-module build. The context agent noticed but did not fix it. | Installer detects single- vs multi-module (Maven `<modules>`, Gradle `include`) and writes package-scoped test commands (`-Dtest='**/{module}/**'`) for single-module builds. Context skill must now check, fix and **run** `verify_module` once. |
| 2 | Formatter present in the build but `format:` left empty. | Installer pre-fills Spring Java Format or Spotless when found in the build file. |
| 3 | Hotspot command used pipes; harness blocked it. | Context skill runs `git log` alone and counts itself, or skips. |
| 4 | Test class named after the ticket id (`Pet7WhitespaceDuplicateNames`). | Tester role and implement skill: name tests after behaviour, never ticket ids. |
| 5 | A test added after the fix was claimed as bug-detecting without being seen failing (it was flagged, not hidden). | Tester role and implement skill: write proving tests before the fix; otherwise call them regression guards. |
| 6 | Compound shell commands hit permission prompts. | Installer writes `.claude/settings.json` (if absent): builds and read-only git allowed; commit, push, branch changes and `rm` ask. |

## Not yet tested

- Feature and refactor tracks
- A multi-module Maven build, and Gradle
- Harnesses other than Claude Code
- Interactive Claude Code (native question UI for menu and gates)
