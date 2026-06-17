---
name: cf-gh-pr-create
description: Create a GitHub pull request using gh CLI. Use when user asks to create, open, publish, or prepare a GitHub PR from current branch; always previews title/body/command and requires explicit confirmation before publishing.
---

Create a GitHub PR from the current branch with reviewer-ready context.

## Important

- Always preview the PR title, body, base branch, labels, reviewers, assignees, and exact `gh pr create` command before creating the PR.
- Always ask the user for explicit confirmation before running `gh pr create`.
- Do NOT create, publish, post, submit, or open a PR on GitHub without explicit user confirmation after preview.
- Do NOT auto-merge, approve, enable auto-merge, or change merge settings.
- Do NOT push unless the user explicitly asks. If the branch is not pushed or has no upstream, tell the user what command is needed and ask before running it.
- Do NOT create a PR from a default branch such as `main`, `master`, `develop`, or `development` unless the user explicitly confirms that head branch.
- Prefer the repository default branch as base when it can be determined. If unsure, ask the user for base branch.
- If the user provides a project PR template, use it only when it is clearly present in the repository and relevant. Otherwise use the default lead-review template below.
- Always remind the user in the preview to set the reviewer to their lead manually before confirming. Reviewer cannot be inferred from the local environment, so it stays empty by default unless the user explicitly provides a username.

## Steps

1. **Inspect branch and remote state** — Use only safe read-only commands first:
   - `git rev-parse --abbrev-ref HEAD`
   - `git remote -v`
   - `git status --short --branch`
   - `git branch --show-current`
   - `git log --oneline <base>..HEAD` after base branch is known
   - `gh repo view --json defaultBranchRef,nameWithOwner` when needed to infer repository metadata or default branch
2. **Detect current GitHub user** — Run `gh api user` and read the `login` field. This is used as the default PR assignee. If the API call fails (no auth, offline, etc.), fall back to asking the user explicitly for a username or skip assignee. Never guess.
3. **Choose base branch** — Use repository default branch if known. If not known, ask. Common defaults: `main`, `master`.
4. **Check head branch safety** — If current branch is `main`, `master`, `develop`, or `development`, stop and ask explicit confirmation before continuing.
5. **Draft PR title** — Prefer user-provided title. Otherwise synthesize from latest commit or branch name. Keep concise and imperative.
6. **Draft PR body** — Use the default template. Fill what can be inferred from commits/diff. Leave unknown items blank or `Not tested` rather than inventing facts.
7. **Add optional sections only when relevant**:
   - `## Screenshots / Evidence` for UI, frontend, bug proof, logs, API examples, query plans, or benchmarks.
   - `## Migration` for DB schema changes, data backfills, or rollback-limited migrations.
   - `## API Contract` for REST, gRPC, proto, event, or public interface changes.
   - `## Operational Impact` for infra, config, observability, deployment, queues, cron, or runtime behavior changes.
   - `## Alternatives Considered` for large architecture or design changes.
8. **Resolve assignee** — Default to the detected current user. If the user explicitly provides a different username, use that. If the user says "no assignee" or "unassign", omit `--assignee`. Always show the resolved value in the preview.
9. **Prompt for reviewer** — Reviewer is not auto-detected. If the user has not already provided a reviewer username, ask: `Who is your lead to assign as reviewer? (type username, or 'skip' to leave empty)`. Use the answer in `--reviewer`. If the user says "skip" or "none", leave `Reviewers: none` in the preview.
10. **Preview before publish** — Show:
    - Head branch
    - Base branch
    - PR title
    - PR body
    - Labels/reviewers/assignees/draft setting, if any
    - Exact `gh pr create` command to be run
11. **Ask confirmation** — Ask: `Create this GitHub PR now? (y/n)` Continue only if user clearly confirms.
12. **Create PR** — Run `gh pr create ...` only after confirmation. Return PR URL and final title/body used.

## Default PR Body Template

```markdown
## Summary
- 

## Context
Problem:
Approach:

## Changes
- 

## Risk
Level: Low / Medium / High
Risk areas:
- 
Mitigations:
- 

## Validation
Automated:
- 
Manual:
- 
Not tested:
- 

## Rollout
Migration needed: No
Feature flag: No
Deployment order:
Backward compatibility:

## Rollback
Rollback steps:
Data rollback needed: No

## Dependencies
Related PRs/issues:

## Review Focus
- 

## Developer Checklist
- [ ] Code compiles and runs without errors
- [ ] Code formatted + lint passed
- [ ] Unit tests written and passed
- [ ] Edge cases handled (e.g. errors, reconnect, etc.)
- [ ] No hard-coded secrets or sensitive data
- [ ] Docs/comments updated
- [ ] Self-review done

## Breaking Changes
None
```

## Preview Format

Before creating the PR, output this exact structure:

````markdown
## PR Preview

Head branch: `<head>`
Base branch: `<base>`
Draft: Yes / No
Labels: `<labels or none>`
Reviewers: `<reviewers or none>`
Assignees: `<assignees or none>`

> Reminder: confirm the reviewer above is your lead. Add or change it now if needed.

### Title
<title>

### Body
<body>

### Command
```bash
gh pr create ...
```

Create this GitHub PR now? (y/n)
````

Do not proceed unless the user clearly confirms.

## Command Guidance

- Use `--head` and `--base` explicitly.
- Use `--title` and `--body` explicitly.
- Use `--draft` only when the user asks for draft or the PR is clearly not ready.
- Add `--label` only when the user requests it or project convention is known.
- Add `--reviewer` from the answer to the lead-reviewer prompt. If the user says "skip" or "none", omit `--reviewer`. Always include a `Reminder:` line in the preview telling the user to double-check the reviewer is their lead.
- Add `--assignee` by default using the current GitHub user detected via `gh api user`. Override only when the user explicitly requests a different username or asks to leave the PR unassigned.
- Quote shell arguments safely. If body is long, prefer a temp file only if the CLI supports it in the current environment; otherwise pass the body safely as an argument.

Example command shape:

```bash
gh pr create --head "feature/example" --base "main" --title "Add example flow" --body "<body>" --assignee "<current-user>"
```

## Output After Creation

After `gh pr create` succeeds, return:

```markdown
## PR Created

URL: <url>
Head branch: `<head>`
Base branch: `<base>`
Title: <title>
```

If creation fails, return the exact error and the command attempted, with secrets redacted if any are present.
