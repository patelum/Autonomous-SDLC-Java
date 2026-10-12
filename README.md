# Autonomous-SDLC-Java

An open-source, harness-agnostic agentic SDLC for Java monoliths.

Install it into an existing Maven or Gradle monolith, start your agent CLI, and type `/ai-sdlc` (or "start ai-sdlc"). An orchestrator asks what you want to do, takes the work through each stage with specialist agents, and stops only to ask you **yes or no** at the steps that matter.

```text
ai-sdlc · billing-monolith · 1 ticket in progress

What do you want to do?
  1  Fix a defect
  2  Build a feature
  3  Refactor
  4  Resume JIRA-118 (waiting at G2 · Design)
```

- **Harness-agnostic.** Content is plain markdown in the [Agent Skills](https://agentskills.io) format plus `AGENTS.md`, read natively by Codex CLI, Copilot CLI, Gemini CLI and OpenCode. The installer adds the Claude Code wiring.
- **Built for monoliths.** Context is split per module so agents only load what a task touches. Builds are scoped to the affected module.
- **Files are the state.** Every ticket lives in `specs/<id>/`. Stop, resume tomorrow, or switch harness mid-ticket.
- **Your controls stay in charge.** The agent never commits, pushes or merges. Your build, CI and code review remain authoritative.

> Status: **v0.1, early.** The orchestrator, tracks, roles and templates work today. The deterministic Java analyser (`ai-sdlc init`), hooks and multi-harness `render` command are on the [roadmap](#roadmap).

## The 15-minute path

**1. Install into your app (2 min)**

```bash
git clone https://github.com/patelum/Autonomous-SDLC-Java.git
cd Autonomous-SDLC-Java
./install.sh /path/to/your-monolith          # add --harness claude for Claude Code wiring
```

This adds `AGENTS.md`, `.agents/skills/`, `.ai-sdlc/` and `specs/` to your repo. Nothing in `src/` is touched.

**2. Set your build commands (2 min)**

Edit `.ai-sdlc/config.yaml` and check the `build:` commands match your project (Maven wrapper by default).

**3. Generate the engineering context (5–10 min)**

Start your agent CLI in the app repo and run:

```text
/ai-sdlc            then choose "Set up project context"
```

The context skill maps your modules, entry points, data model and tests into `.ai-sdlc/context/`. Every claim is tagged `[verified: path:line]` or `[inferred]`. Review the **Open questions** in each file, fix anything wrong, and commit.

**4. Deliver something**

```text
/ai-sdlc            then choose "Fix a defect", "Build a feature" or "Refactor"
```

Answer `y` or `n` at each approval card. When it finishes, the change is in your working tree with a `review.md`; you commit and open the PR.

## How it works

| Track | Stages | You approve |
| --- | --- | --- |
| Fix a defect | reproduce → plan → implement → verify → review | plan, final diff |
| Build a feature | spec → design → plan → implement → test → verify → review → security | spec, design, plan, final diff |
| Refactor | characterise → plan → refactor in steps → verify → review | plan, final diff |

Every approval shows the same card:

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

`n` asks for a one-key reason and the stage is redone. Build failures and review findings are fixed automatically (up to 3 tries per step) before anything reaches you.

## What gets installed

```text
your-monolith/
├── AGENTS.md                    # short project instructions every harness reads
├── .agents/skills/              # orchestrator + stage skills (Agent Skills format)
├── .ai-sdlc/
│   ├── config.yaml              # build commands, gates, protected paths
│   ├── workflows/               # defect, feature, refactor
│   ├── roles/                   # architect, implementer, tester, reviewer, security
│   ├── templates/               # spec, design, plan, review, status, PR description
│   └── context/                 # generated: index.md + modules/*.md
└── specs/<ticket>/              # one folder per change: artifacts + status.md
```

With `--harness claude` the installer also writes `CLAUDE.md` (importing `AGENTS.md`), copies skills to `.claude/skills/` and renders roles as `.claude/agents/` subagents.

## Harness support

| Harness | v0.1 status |
| --- | --- |
| Claude Code | Supported via `--harness claude`: skills, subagents |
| Codex CLI | Reads `AGENTS.md` and `.agents/skills/` natively; roles run as skills in the main session |
| Copilot CLI, Gemini CLI, OpenCode | Should work via `AGENTS.md` + skills; untested, reports welcome |

Where a harness has no subagents, the orchestrator runs each role's skill itself and reviews from the diff and spec only.

## Roadmap

- **v0.2** `ai-sdlc init`: Java analyser (Maven/Gradle, JavaParser, git hotspots) producing `codemap.json` and an ArchUnit baseline
- **v0.3** `ai-sdlc render` for Codex, Copilot and Gemini agent formats; neutral hooks (format, protected paths, verify on finish)
- **v0.4** `verify`, `doctor` (context drift), `upgrade`; demo monolith; Gradle parity
- Later: external driver (`ai-sdlc run`) for parallel tickets and async approvals

Design doc: [docs/design.md](docs/design.md)

## Contributing

Issues and PRs welcome, especially reports from harnesses other than Claude Code and Codex. Content changes go in `content/`; never edit installed copies in an app and expect them upstream.

## Licence

[Apache-2.0](LICENSE)
