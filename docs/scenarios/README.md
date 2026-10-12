# Regression scenarios

Each scenario is a small, real ticket on a pinned public repository, with what a correct run **must** and **must not** do. Every problem fixed in the kit (from a trial or an upstream `[lesson]` issue) should add or extend a scenario, so later changes cannot quietly reintroduce it.

v0.1 scenarios are run by hand (or with the headless driver used in the trials) before a kit release. An automated replay harness is on the roadmap.

| Scenario | Track | Guards against |
| --- | --- | --- |
| [S1 petclinic-padded-names](s1-petclinic-padded-names.md) | defect | single-module build commands, ticket ids in test names, unproven "bug detector" tests |
| [S2 petclinic-vet-on-visit](s2-petclinic-vet-on-visit.md) | feature | open choices at gates, invented timestamps, unrecorded approvals, leaked error text rated "consider" |
| [S3 roller-split-utilities](s3-roller-split-utilities.md) | refactor | no Maven wrapper, giant build module as one context file, hidden build exit codes, bugs "fixed" inside a refactor |

## Format

```markdown
# S<n> <name>
Repo: <url> @ <commit> · Track: <track> · Harness: any
Setup: <install flags, config answers>
Ticket: <exact text>
Human answers: <the y/n/number sequence, with the reason text for any n>
Must: <observable checks on files, status.md, cards and build>
Must not: <things that would show a regression>
```
