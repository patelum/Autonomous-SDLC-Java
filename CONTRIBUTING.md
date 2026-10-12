# Contributing

Thanks for helping. The most valuable contributions right now are **reports from real use**: other harnesses (Codex, Copilot, Gemini, OpenCode), other monoliths, and lessons from your retros.

## Ways to contribute

| Contribution | How |
| --- | --- |
| A lesson from your retros | Use **Improve the process** in your repo; file the anonymised draft from `.ai-sdlc/improvements/upstream/` with the **Lesson** issue template |
| A bug in the kit | **Bug** issue template: harness, kit version (`.ai-sdlc/VERSION`), and the relevant `status.md` log lines |
| A trial on a new repo or harness | Run a ticket, write it up like the reports in `docs/trials/`, open a PR |
| A fix or feature | PR, following the rules below |

## Rules for changes

1. **Content lives in `content/`.** Never fix things by editing an installed copy in an app.
2. **Every fixed problem gets a regression scenario.** Add or extend one in `docs/scenarios/` with the must and must-not checks that would catch it.
3. **Keep skills short and procedural.** Rules buried at the end of a long skill get skipped; put critical behaviour in the numbered step where it applies (we learned this the hard way with timestamps).
4. **Harness-neutral first.** Write content in Agent Skills / `AGENTS.md` terms. Harness-specific behaviour belongs in the installer.
5. **Run the self-test:** `./tests/run.sh` must pass. CI runs it on every PR.
6. **Update the docs** that describe what you changed (`docs/solution-design.md`, `docs/getting-started.md`) and add a `CHANGELOG.md` entry.

## Repository layout

```text
content/        everything installed into an app (skills, roles, workflows, templates, standards, config)
install.sh      installer and upgrader
tests/run.sh    self-test (content lint, cross-references, installer across layouts, upgrade guarantees)
docs/           guides, solution design, feedback loop, trials, scenarios
```

## Triage of lesson issues (maintainers)

1. Reproduce or reason through it; check it is not already fixed in `main`.
2. Fix the skill, role, template or default standard it names.
3. Extend a scenario in `docs/scenarios/`.
4. Reference the issue in the commit (`Fixes #n`) and note it in `CHANGELOG.md`.
