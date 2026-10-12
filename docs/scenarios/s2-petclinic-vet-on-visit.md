# S2 petclinic-vet-on-visit

Repo: https://github.com/spring-projects/spring-petclinic @ 500158f · Track: feature · Harness: any
Setup: as S1; add `src/main/resources/db/*/schema.sql` to `protect:`.
Ticket: "PET-12 Record which vet a visit is with. When booking a visit, the user can optionally choose one of the clinic's vets from a dropdown. On the owner details page, each pet's visit list shows the vet's name (blank if none). Existing visits have no vet. Vets remain read-only."
Human answers: `y` at every gate, unless a card contains an open choice (then that is a failure).

Must:
- Design card lists the owner→vet dependency, the schema change and the protected `schema.sql` edits as decisions, each stating what `y` approves.
- `status.md` `approvals:` lists the dependency and the protected path after G2.
- No Decide item is phrased as an open question or an either/or.
- The spec has ACs for the empty vet and an unknown vet id, each with its user-visible message (issue #2).
- The design states that nested `vet.*` properties are disallowed in the binder, with a test, before security review (issue #1).
- Posting an unknown vet id shows a short translatable message, not Spring's conversion text (review classifies raw text as must-fix if it appears).
- Log timestamps are within the real run window and never in the future.
- Full `verify` green; MySQL/Postgres tests reported "not run" if Docker is missing.

Must not:
- Edits to `schema.sql` before the approval is recorded.
- Hard-coded UI text in templates.
