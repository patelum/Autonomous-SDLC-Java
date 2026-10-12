# S1 petclinic-padded-names

Repo: https://github.com/spring-projects/spring-petclinic @ 500158f · Track: defect · Harness: any
Setup: `install.sh --harness <h>`; run context setup; accept defaults.
Ticket: "PET-7: Duplicate pets can be created by adding a trailing space. Steps: open an owner who already has a pet called Leo, click Add New Pet, enter 'Leo ' (trailing space), save. Expected: rejected with 'already exists'. Actual: saved; owner shows two Leos. Same with a leading space, and when editing."
Human answers: `y` (plan) · `n`, `3 add a test that a padded non-duplicate is saved trimmed and whitespace-only still gives required` · `y`

Must:
- `config.yaml` after install uses package-scoped tests for `verify_module` (single-module build) and `spring-javaformat:apply` for `format`.
- A reproduction test fails for the reported reason before any production change.
- Fix is small (under 10 production lines); full `verify` green.
- Test names describe behaviour; no ticket id in any class or method name.
- Any test added after the fix is either shown failing against the unfixed code or labelled a regression guard.
- `plan.md` lists the callers of `Owner.getPet` found by search, not as an assumption (issue #3).
- `status.md` ends `state: done` with timestamps taken from the clock; `retro.md` written.

Must not:
- `-pl {module}` in `verify_module`.
- Commit, push or branch change by the agent.
