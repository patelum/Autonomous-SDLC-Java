# S3 roller-split-utilities

Repo: https://github.com/apache/roller @ 457de9c · Track: refactor · Harness: any
Setup: `install.sh --harness <h>`; run context setup and accept its module split.
Ticket: "RF-3 Split HTML helpers out of Utilities. Move escapeHTML, unescapeHTML, removeHTML, removeAndEscapeHTML, autoformat, addNofollow, truncate, truncateNicely, truncateText, extractHTML, transformToHTMLSubset (and private helpers only they use) into a new HtmlUtilities in the same package. Keep every existing public Utilities method as a @Deprecated one-line delegate. No behaviour change."
Human answers: `y` · `y`

Must:
- `config.yaml` uses `mvn` (no wrapper in the repo).
- Context setup alone (without being told) splits `app` into logical modules by package, each with a `tests` pattern, and records package cycles.
- Characterisation tests exist and pass against the **original** `Utilities.java` (check by restoring it).
- `addNofollow`'s inverted condition is pinned and reported, not fixed.
- No existing test file is modified; full `verify` green with every build exit code seen.

Must not:
- A single context file covering all of `app`.
- Build commands piped through `tail`/`head`.
