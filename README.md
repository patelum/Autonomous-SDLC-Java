# Autonomous-SDLC-Java

**An open-source, gated, self-improving agentic SDLC for Java monoliths. It works with the agent CLI you already use.**

Install it into an existing Maven or Gradle monolith, start your agent CLI and type `/ai-sdlc`. An orchestrator asks what you want to do, takes the ticket through spec, design, plan, test-first implementation, build verification, independent code review and security review, and stops only to ask you **yes or no** at the steps that matter. Every finished ticket feeds a retro, and the process improves from your corrections.

```text
ai-sdlc · billing-monolith · 1 ticket in progress

What do you want to do?
  1  Fix a defect
  2  Build a feature
  3  Refactor
  4  Resume JIRA-118 (awaiting approval at G2 · design)
  5  Improve the process (2 new retros)
```

[![ci](https://github.com/patelum/Autonomous-SDLC-Java/actions/workflows/ci.yml/badge.svg)](https://github.com/patelum/Autonomous-SDLC-Java/actions/workflows/ci.yml) · Apache-2.0 · v0.1

## Why not just let the agent code?

| Unguided agent ("vibe coding") | Autonomous-SDLC-Java |
| --- | --- |
| Starts coding from a one-line prompt | Agrees **what** (spec) and **how** (design) with you first |
| Loses track of a 500k-line monolith | Splits the codebase into small, cited per-module context; loads only what the task touches |
| Says "done" while the build is red | Done means scoped and full builds are green; it fixes its own failures |
| Marks its own homework | Independent reviewer and security agents in separate contexts |
| Quietly adds a library or changes the schema | Weighty changes stop for your approval and are recorded |
| Forgets your corrections next session | Retros turn rejections into team standards and upstream fixes |
| Lives in a chat transcript | Lives in `specs/<id>/` in git: reviewable, resumable, auditable |

## Up and running in 15 minutes

```bash
git clone https://github.com/patelum/Autonomous-SDLC-Java.git
cd Autonomous-SDLC-Java
./install.sh /path/to/your-monolith --harness claude   # omit --harness for Codex, Copilot, Gemini, OpenCode
```

Then, in your agent CLI inside your monolith:

```text
/ai-sdlc set up project context      # 5–10 min: maps modules, checks build commands; review and commit
/ai-sdlc fix BUG-42: <ticket text>    # or /ai-sdlc and pick from the menu
```

Answer `y` or `n` at each approval card. When it finishes, the change is in your working tree with a review and a PR description; you commit and open the PR.

**Full walkthrough:** [docs/getting-started.md](docs/getting-started.md)

## How it works

```text
 ticket ──► intake ──► track (defect | feature | refactor)
                          │
      spec ─► design ─► plan ─► implement step ⇄ scoped build ─► full build ─► review ─► security ─► final
       G1       G2       G3         (fixes its own failures)                   (fresh contexts)        G4
                          │
              status.md records every step ── resume anywhere, any harness
                          │
 finished ──► retro.md ──► "Improve the process" ──► team standards (local) + lesson issues (upstream)
```

| Track | Stages | You approve |
| --- | --- | --- |
| Fix a defect | reproduce (failing test first) → plan → implement → verify → review | plan, final diff |
| Build a feature | spec → design → plan → implement → test → verify → review → security | spec, design, plan, final diff |
| Refactor | characterise (pin current behaviour) → plan → refactor in steps → verify → review | plan, final diff |

Every gate shows the same card, so you always know where to look:

```text
GATE 2/4 · Design · JIRA-123 Add invoice PDF export
What:     New PdfExportService in billing; endpoint GET /invoices/{id}/pdf
Why:      Spec AC-1..AC-3; reuses existing InvoiceRepository
Touches:  billing (new code), web (1 controller) · no new module dependency
Evidence: entry points checked · module build green
Decide:   PDF library: OpenPDF (LGPL) chosen over iText (AGPL)
Full:     specs/JIRA-123/design.md

Approve? [y / n]
```

`n` asks for a one-key reason and the stage is redone. The **Decide** line lists only the judgement calls that belong to you, each with the choice already made.

### It improves itself

Every finished ticket gets a `retro.md`: each rejection (with your words), each edit you made before approving, each retry, escalation and miss, tagged with the skill, standard or policy responsible. **Improve the process** groups recurring problems and proposes concrete changes, one y/n card each:

- **Locally**, applied on `y`: your team's `standards/`, `lessons.md`, context and config, never overwritten by upgrades.
- **Upstream**, drafted on `y`: anonymised `[lesson]` issues so the kit improves for every team. [Real examples](https://github.com/patelum/Autonomous-SDLC-Java/issues?q=label%3Alesson).

Fixed problems become [regression scenarios](docs/scenarios/).

## Tested on real code

| App | Track | Result |
| --- | --- | --- |
| [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) | defect | Real bug reproduced with failing tests, 2-line fix, reviewed; one rejection and rework. [Report](docs/trials/2026-10-12-spring-petclinic.md) |
| Spring PetClinic | feature | Vet on visits across modules with a schema change; security review caught a mass-assignment bug; 103 tests green. [Report](docs/trials/2026-10-12-spring-petclinic-feature.md) |
| [Apache Roller](https://github.com/apache/roller) | refactor | Split a 1,114-line utility class behind 48 characterisation tests; found 3 latent bugs, including an inverted spam-protection check. [Report](docs/trials/2026-10-12-apache-roller-refactor.md) |
| Spring PetClinic | improve | Retros over two tickets → 4 team standards, 3 upstream lessons filed and fixed. [Report](docs/trials/2026-10-12-feedback-loop.md) |

Human input per ticket: 3–7 answers. Agent cost per ticket: about $1.50–$4.50 (Claude Sonnet 5.5). Results branches: [PetClinic](https://github.com/patelum/spring-petclinic/tree/ai-sdlc-trial) · [Roller](https://github.com/patelum/roller/tree/ai-sdlc-trial).

## Harness support

| Harness | v0.1 status |
| --- | --- |
| Claude Code | `--harness claude`: skills, subagents, permissions. **Tested end to end** (defect, feature, refactor, improve) |
| Codex CLI | Reads `AGENTS.md` and `.agents/skills/` natively; roles run inline. Untested |
| Copilot CLI, Gemini CLI, OpenCode | Via `AGENTS.md` + Agent Skills; untested. Reports welcome |

## What it never does

Commit, push, merge or change branches · edit protected paths without a recorded approval · add a library, cross-module dependency or schema change without asking · report unverified work as passing.

## Documentation

| Read | For |
| --- | --- |
| [Getting started](docs/getting-started.md) | Step-by-step setup, first ticket, day-to-day use |
| [Solution design](docs/solution-design.md) | Architecture, components, state model, gates, context strategy, safety, extending |
| [Feedback loop](docs/feedback-loop.md) | How retros and improvements work, locally and upstream |
| [Troubleshooting and FAQ](docs/troubleshooting.md) | Common problems, cost, safety questions |
| [Trials](docs/trials/) and [scenarios](docs/scenarios/) | Evidence and regression cases |
| [Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md) | Working on the kit |

## Status and roadmap

v0.1 is early but works end to end. Next: a deterministic Java analyser (`codemap.json` + ArchUnit boundary rules), role rendering and tested runs for Codex, Copilot and Gemini, hooks, and automated scenario replay. See [solution design §14](docs/solution-design.md#14-known-limitations-and-roadmap).

## Licence

[Apache-2.0](LICENSE)
