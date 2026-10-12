# Troubleshooting and FAQ

## Setup

**`/ai-sdlc` is not recognised.**
Claude Code: check `.claude/skills/ai-sdlc/SKILL.md` exists (install with `--harness claude`) and restart the session. Other harnesses: check `.agents/skills/ai-sdlc/SKILL.md` exists and that skills are enabled in your CLI; you can also type "start ai-sdlc".

**Claude Code keeps asking permission for every build.**
Project permissions in `.claude/settings.json` apply only after you trust the folder. Run `claude` interactively in the repo once and accept the trust prompt.

**The build commands in `config.yaml` are wrong.**
Run context setup (`/ai-sdlc set up project context`): it checks and corrects them. Or edit `build:` by hand. `{module}` is a module name from `modules:` (or a Maven/Gradle module), and `{tests}` is that module's `tests:` pattern.

**My repo has no Maven/Gradle wrapper.**
The installer uses `mvn` / `gradle` from your PATH instead. Make sure the right version is on the PATH.

**I already have an `AGENTS.md` / `CLAUDE.md`.**
The installer appends a marked block to `AGENTS.md` and replaces only that block on upgrade. It adds `@AGENTS.md` to an existing `CLAUDE.md` if missing. Your own text is kept.

**Will it break my build or CI?**
It adds markdown and YAML files only, outside `src/`. If your build runs a licence-header check over all files (for example Apache RAT), exclude `.ai-sdlc/**`, `.agents/**` and `specs/**`.

## During a ticket

**It asked me something with no y/n card on screen.**
Ask "show the card". Cards must always be printed in full; report it as a bug if it happens.

**It says a test "was not run".**
Usually an environment limit (no Docker for Testcontainers, no external system). That is deliberate honesty, not a failure. Run those tests yourself before merging, or provide the environment.

**The scoped build passed but the full build failed.**
Some tests (cross-cutting or root-package) are outside every module's pattern. The agent fixes full-build failures automatically within the retry budget. If it keeps happening, "Improve the process" will propose a lesson (for example "run the i18n test after template changes").

**It stopped with "NEEDS YOU".**
An escalation: retry budget used up, or a change that always needs a human (new dependency, new library, schema change, protected path, high-severity security finding). Pick a numbered option.

**I want to change something it decided at an earlier gate.**
Answer `n` at the current gate with reason `4` and say what to change; it goes back to the right stage. Or edit the earlier artifact and say so.

**Can I switch harness mid-ticket?**
Yes. All state is in `specs/<id>/status.md`. Open the other CLI and choose **Resume**.

## Cost and speed

**How much does a ticket cost?**
In the trials (Claude Sonnet 5.5): about $1.50 for a small defect, $2 for a medium refactor, $4.50 for a cross-module feature with a schema change. Context setup was $0.50–$1.60 per repo.

**How long does it take?**
Small defect: about 10–15 minutes of agent time. Cross-module feature: about 40 minutes. Your time is the gates: typically 3–7 answers per ticket.

## Safety

**Can it push code or merge?**
No. Every role is told never to commit, push, merge or change branch, and the default Claude Code permissions make those commands ask first.

**Does anything leave my repo?**
Only what your agent CLI sends to its model provider as part of normal use. The kit adds no telemetry. Upstream lesson drafts are local files that you choose whether to send.

**What stops it editing migrations or other sensitive files?**
`protect:` in `config.yaml`. An edit there needs an approval recorded for that ticket; an unapproved one is a must-fix in review.

## Reporting problems

- A bug in the kit: open an issue with your harness, kit version (`.ai-sdlc/VERSION`) and the relevant `status.md` log lines.
- A lesson from your own retros: use **Improve the process**, which drafts an anonymised `[lesson]` issue for you.
