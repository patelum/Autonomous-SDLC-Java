# Getting started

From zero to your first agent-delivered change in about 15 minutes. No new platform, server or account: just your repo, your build and the agent CLI you already use.

## Before you start (check, 2 minutes)

| You need | Check with |
| --- | --- |
| A Java monolith in git, building with Maven or Gradle | `git status` in the repo; `./mvnw -v`, `mvn -v`, `./gradlew -v` or `gradle -v` |
| The build passes on your machine | `./mvnw verify` (or your usual command) |
| bash and git | macOS and Linux have them; on Windows use WSL or Git Bash |
| An agent CLI, installed and logged in | Claude Code (`claude`), Codex CLI (`codex`), Copilot CLI, Gemini CLI or OpenCode |

Start from a clean working tree (`git status` shows nothing to commit). Reviews compare against the commit where a ticket starts.

## 1. Install into your repo (2 minutes)

```bash
git clone https://github.com/patelum/Autonomous-SDLC-Java.git
cd Autonomous-SDLC-Java
./install.sh /path/to/your-monolith --harness claude      # Claude Code users
./install.sh /path/to/your-monolith                       # Codex, Copilot, Gemini, OpenCode
```

The installer detects Maven or Gradle, single- or multi-module, the wrapper and a formatter, and writes matching commands. It adds files next to your code and never touches `src/`:

```text
AGENTS.md            .agents/skills/        .ai-sdlc/        specs/
CLAUDE.md, .claude/  (only with --harness claude)
```

Use `--dry-run` first if you want to see exactly what it will do.

## 2. Check the build commands (2 minutes)

Open `.ai-sdlc/config.yaml` and look at `build:`.

```yaml
build:
  verify: ./mvnw -q verify                     # full build, run once at the end
  verify_module: ./mvnw -q -pl {module} -am verify   # fast build for one module
  test_one: ./mvnw -q -Dtest={test} -Dsurefire.failIfNoSpecifiedTests=false test
  format: ""                                   # your formatter, if any
```

The defaults match your build layout. Leave them if unsure: the next step checks and corrects them.

**Claude Code only:** run `claude` once in the repo interactively and accept the folder trust prompt, so the installed permissions (builds allowed; commit and push ask first) take effect.

## 3. Map your codebase (5–10 minutes, mostly waiting)

Start your agent CLI in the repo and type:

```text
/ai-sdlc set up project context
```

(Or `/ai-sdlc` and choose **Set up project context**. In harnesses without slash commands, type "start ai-sdlc".)

The agent:

- reads the build files and confirms the build commands work, by running one scoped build
- splits the code into modules of a manageable size (large modules are split by package)
- writes `.ai-sdlc/context/index.md` and one file per module, with every claim cited (`[verified: path:line]`) or marked `[inferred]`
- lists **open questions** for you

Skim the files, answer the open questions (reply in the chat, or edit the files), then commit:

```bash
git add AGENTS.md .agents .ai-sdlc specs CLAUDE.md .claude 2>/dev/null; git commit -m "Add ai-sdlc"
```

## 4. Deliver your first change (the rest of your 15 minutes, then the agent works)

```text
/ai-sdlc
```

```text
What do you want to do?
  1  Fix a defect
  2  Build a feature
  3  Refactor
```

Pick one and paste the ticket. Or skip the menu:

```text
/ai-sdlc fix BUG-42: invoice totals ignore discounts when the cart has one item
```

Pick something small for your first ticket: a bug with clear steps to reproduce is ideal.

### Answering the agent

You will only be asked at **gates** (and rare escalations). A gate looks like this:

```text
GATE 1/2 · Plan · BUG-42 Discount ignored for single-item carts
What:     Apply discount before rounding in CartTotals.compute (3 lines)
Why:      Reproduction test shows discount skipped when items.size()==1
Touches:  billing · no new module dependency
Evidence: 1 failing reproduction test; module build otherwise green
Decide:   Rounding stays HALF_EVEN (y = keep current rounding)
Full:     specs/BUG-42/plan.md

Approve? [y / n]
```

- **y**: carry on.
- **n**: pick a reason (`1 wrong scope`, `2 wrong approach`, `3 missing case`, `4 other`) and add a sentence if you like. The agent redoes that stage and asks again.
- Want more detail? Open the file on the `Full:` line. Edit it before answering if you want; the agent works from your edited version.

Between gates the agent works on its own: it writes tests, implements step by step, runs the scoped build after each step, fixes its own failures, runs the full build, and has an independent reviewer check the result.

### When it finishes

- The change is in your working tree, **uncommitted**. The agent never commits, pushes or opens PRs.
- `specs/<id>/` holds the request, spec or reproduction, plan, review, retro and a ready PR description (`pr.md`).
- Review the diff as you normally would, run anything you like, then commit and open your PR. Your CI and code review stay in charge.

## Day-to-day use

| You want to | Do this |
| --- | --- |
| Continue a ticket tomorrow | `/ai-sdlc` → **Resume <id>**. State is in `specs/<id>/status.md`, so any session or harness can continue |
| Change which steps need your approval | Edit `gates:` in `.ai-sdlc/config.yaml` |
| Stop agents touching certain files | Add globs to `protect:` |
| Teach it a rule for your team | Add to `.ai-sdlc/standards/*.md`, or approve an improvement proposal |
| Make it learn from past tickets | `/ai-sdlc` → **Improve the process** (appears once tickets have finished) |
| Upgrade the kit | `git pull` in the kit, re-run `./install.sh /path/to/your-monolith`. Your config, standards, lessons, context and specs are kept |
| Remove it | Delete `.agents/`, `.ai-sdlc/`, `specs/`, the `ai-sdlc` block in `AGENTS.md`, and `CLAUDE.md` / `.claude/` if added |

## Tips from the trials

- **First ticket: a small defect.** It exercises the whole loop in about 10–15 minutes of agent time.
- **Run the app before the final yes**, if it is cheap. In one trial the only problem left after all automated checks was an ugly error message a user would see.
- **Read the Decide line first.** It lists exactly the judgement calls that need you.
- **Say no early.** Rejecting a spec or design is cheap; rejecting a finished diff costs another implementation round.
- **Use "Improve the process" every few tickets.** It turns your rejections into team rules, so the same correction is not needed twice.

Next: [How it is designed](solution-design.md) · [Troubleshooting](troubleshooting.md) · [Feedback loop](feedback-loop.md)
