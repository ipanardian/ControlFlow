# ControlFlow

ControlFlow is a human-gated workflow for AI coding agents. It keeps
AI-assisted software delivery moving through one auditable lifecycle:
request → risk classification → spec → test plan → execution plan → TDD
implementation → verification → review → MR/PR → production readiness →
launch → lessons learned.

It is not a generic skill pack. ControlFlow defines how agent work should move
from idea to production while keeping humans in control of risky transitions.
It is **language-agnostic** and **architecture-agnostic**.

## What It Provides

- **Human gates** before risky transitions: spec/test plan, execution plan,
  reviewed diff, MR/PR creation, and production action.
- **Risk-based lanes** so small safe work stays light and risky work gets
  stronger evidence and review.
- **TDD-first implementation** unless the task is docs, formatting,
  config-only, or TDD is explicitly skipped.
- **Reusable templates** for specs, test plans, MR/PR summaries, and launch
  handoffs.
- **Agent skills** for intake, spec design, build, review, MR/PR prep,
  production readiness, testing, debugging, and peer language implementation.
- **Installer support** for shared agent skill directories.

## Core Skills

Use `cf-intake` as the default entry point. It routes work to the right stage
and keeps the lifecycle moving.

- `cf-intake` - request routing and end-to-end orchestration.
- `cf-spec` - spec design with lane and verifiability classification.
- `cf-build` - approved-plan implementation with TDD and subagent rules.
- `cf-review` - Gate 2 review handling and feedback fixes.
- `cf-mr` - GitLab MR or GitHub PR summary and creation handoff.
- `cf-ship` - production-readiness and launch handoff.
- `cf-state-machine` - canonical agent execution protocol.

Language peer skills such as `cf-golang-engineer`, `cf-python-engineer`, and
`cf-rust-engineer` handle implementation details without changing the core
workflow.

## Repository Layout

- `skills/` - agent skill definitions for the ControlFlow workflow.
- `templates/` - spec, test plan, MR/PR, and launch handoff templates.
- `references/` - reusable lane, testing, review, security, production, and
  subagent checklists.
- `agents/` - reviewer personas for security, tests, API contracts,
  performance, and production readiness.
- `docs/state-machine.md` - human-readable workflow reference with diagrams,
  state tables, and gate explanations.
- `scripts/skill-lint.sh` - local validation for skill metadata and path
  references.
- `install.sh` - installer for copying or symlinking skills and templates.
- `install-targets.conf` - built-in install target mappings.

## Quick Start

Install to the shared Agent Skills target:

```bash
./install.sh --target agents
```

Install to Claude Code's personal skills path:

```bash
./install.sh --target claude
```

Preview install actions without changing files:

```bash
./install.sh --target agents --dry-run
```

Replace existing managed ControlFlow skills/templates:

```bash
./install.sh --target agents --force
```

By default, install mode is `copy`. Use `--mode symlink` only when you want the
installed files to stay live-linked to this repository.

## Install Targets

Built-in targets are configured in `install-targets.conf`:

- `agents` installs skills to `~/.agents/skills` and templates to
  `~/.agents/controlflow`.
- `claude` installs skills to `~/.claude/skills` and templates to
  `~/.agents/controlflow`.

The `agents` target is intended for tools that discover shared Agent Skills,
including OpenCode, Codex, Cursor, Devin Desktop/Windsurf, and Antigravity.
Hermes can use it through `skills.external_dirs`.

GitHub Copilot is not an install target here. Use repository instruction files
such as `AGENTS.md`, `.github/copilot-instructions.md`, or provider-specific
instruction files, and point them at `cf-intake` and
`skills/cf-state-machine/SKILL.md`.

## Using ControlFlow

After installation, ask your coding agent to use `cf-intake` for work that
needs ControlFlow rigor.

Example:

```text
Use cf-intake. I want to build <feature or fix>. First create the spec and test plan, then stop for approval before implementation.
```

Use ControlFlow when the change has risk, ambiguity, or multiple moving parts:

- New feature with unclear behavior.
- Major refactor touching many files or modules.
- Bug fix where the root cause is unclear.
- API, schema, proto, or database contract change.
- Security, auth, billing, permissions, or data-integrity change.
- Cross-service or external integration.
- Change that needs reviewer alignment before coding.

Skip the full workflow for tiny, obvious, low-risk edits such as typos,
single-value config changes, small copy tweaks, or mechanical renames.

Practical rule: if two engineers could build different valid versions, use at
least a mini-spec. If wrong behavior could hurt users, data, security, or
public contracts, use the full workflow.

## Development

Run skill validation before publishing or opening a change:

```bash
./scripts/skill-lint.sh
```

The human-readable workflow overview lives in `docs/state-machine.md`. Agent
execution rules live in `skills/cf-state-machine/SKILL.md`.
