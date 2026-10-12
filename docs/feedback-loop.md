# Feedback loop

How the kit improves its agents, skills, standards and policies from real tickets and human feedback, in each team's repo and upstream for everyone.

```text
 ticket finishes ──► retro.md (findings tagged with component + scope)
                          │
 "Improve the process" ───┤  groups recurring findings, one y/n card per proposal
                          │
           ┌──────────────┴──────────────┐
           ▼                             ▼
   LOCAL (applied on y)           UPSTREAM (drafted on y)
   .ai-sdlc/lessons.md            .ai-sdlc/improvements/upstream/*.md
   .ai-sdlc/standards/*.md          → human sends / files as a [lesson] issue
   .ai-sdlc/context/                → maintainer changes the skill + adds a
   .ai-sdlc/config.yaml               regression scenario → next kit release
           │                             │
           └──── every agent reads ◄─────┘  (install.sh upgrade keeps local files)
```

## In a team's repo

1. **Capture, automatically.** When a ticket finishes, the orchestrator asks one optional question ("Anything about how this run went that should change?") and writes `specs/<id>/retro.md`. Findings come from gate rejections (with the human's words), human edits to artifacts before approval (diffed against `history/` snapshots), escalations, retries, must-fix findings, things a later stage caught that an earlier one missed, and unverified claims.
2. **Attribute.** Each finding names the responsible component (`skill:sdlc-review`, `standard:testing`, `policy:gates`, `context:…`, `lessons`) and a scope: `repo`, `kit` or `both`.
3. **Improve, with approval.** "Improve the process" appears in the menu when new retros exist. It groups findings across tickets, ranks them, and shows up to five proposals, each with evidence and the exact text it will add. `y` applies it; `n` records it so it is not proposed again without new evidence.
4. **Keep it.** Lessons, standards and the improvement log are team-owned files. `install.sh` creates them once and never overwrites them, so upgrades keep everything the team has learned. Installed skills are never edited locally, since upgrades would erase the change; skill-level fixes go upstream.

## Upstream, for every team

1. **Drafts, not posts.** Approved proposals with a `kit` or `both` scope become issue drafts in `.ai-sdlc/improvements/upstream/`, anonymised (no code, internal names or ticket text) and tagged with the installed kit version. They are only posted if `feedback.upstream: file` is set and the human says `y` again.
2. **Maintainer triage.** Issues labelled `lesson` are reviewed like any change request: reproduce, change the skill, role, template or default, and **add or extend a regression scenario** in `docs/scenarios/`.
3. **Release.** Teams pick up the fix with `install.sh` (upgrade). Their local lessons and standards are untouched; a local workaround made redundant by the kit fix shows up as "already handled" in the next improvement session and can be removed.

## What is not automatic (yet)

- Replaying scenarios is manual in v0.1; an automated replay harness is on the roadmap.
- Upstream drafts are never sent without a human.
- No telemetry: nothing leaves the repository except what a human chooses to send.
