# Changelog

## v0.1.0 (2026-10-12)

First public release.

### Added
- **Orchestrator** (`ai-sdlc` skill): menu, intake, track routing, approval cards, escalations, resume from `status.md`.
- **Three tracks:** defect (reproduce first), feature (spec → design → plan, security review), refactor (characterise first).
- **Five roles** (architect, tester, implementer, reviewer, security) and **twelve stage skills** in Agent Skills format.
- **Feedback loop:** per-ticket retros, **Improve the process** with local changes and anonymised upstream lesson drafts.
- **Team-owned standards** (engineering, testing, security) and `lessons.md`, never overwritten on upgrade.
- **Installer:** Maven/Gradle, single/multi-module and wrapper detection; formatter detection; Claude Code wiring with default permissions; safe upgrades.
- **Self-test** (`tests/run.sh`) and CI; seed regression scenarios; trial reports on Spring PetClinic and Apache Roller.

### Fixed from trials and lessons
- Single-module and wrapper-less builds get working commands.
- Large build modules are split into logical modules by package.
- Gates never carry open choices; cards are always printed in full.
- Timestamps come from the clock; build exit codes must be seen.
- Leaked internal error text is a must-fix; approvals are recorded per ticket.
- Specs list input edge cases with user-visible messages (#2); designs state binder restrictions for cached entities (#1); plans confirm callers by search instead of assuming (#3).
