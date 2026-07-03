# ADR 0001 — AI-assisted development with Claude Code

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
The assessment permits connecting to public APIs and does not forbid AI tooling. Building AI-assisted is faster, but AI-generated infrastructure code risks looking like a prompt dump — no traceable decisions, inconsistent conventions, no proof of engineering discipline. The goal is to demonstrate *both*: modern AI-assisted delivery **and** a clear DevOps process.

## Decision
Use Claude Code as a pair-programming assistant, transparently. Keep discipline through:
1. **CLAUDE.md** as the single source of conventions the assistant must follow (naming, tagging, module anatomy, guardrails).
2. **One Conventional Commit per build phase** — the git history reads as the process.
3. **ADRs** for every significant decision (this folder).
4. **`terraform-docs`** to auto-generate module documentation, so docs never drift from code.
5. **Plan-before-apply** and **deploy → capture evidence → destroy** for any live infrastructure.

## Alternatives considered
- **Hide AI usage** — dishonest, and forfeits the chance to show a modern workflow.
- **AI with no guardrails** — fast but produces untraceable, inconsistent output; fails the "clear process" bar.

## Consequences
- Positive: transparent, reviewable, reproducible; the repo itself demonstrates process.
- Negative / trade-offs: must maintain CLAUDE.md and ADRs; generated output must be reviewed against conventions, not merged blind.
- Mitigation: conventions are enforced in code (`default_tags`, `name_prefix`) so the assistant cannot silently drift.
