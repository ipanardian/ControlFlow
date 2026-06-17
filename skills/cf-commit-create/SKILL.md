---
name: cf-commit-create
description: Create git commits using Conventional Commits format. Use when user asks to commit, create a commit, write a commit message, or prepare a conventional commit; previews files/message/command and requires explicit confirmation before committing.
---

Create a git commit with a Conventional Commits message.

## Important

- Always inspect current git status and diff before drafting a commit.
- Never stage, unstage, revert, reset, or modify files unless the user explicitly asks.
- Never include unrelated files in a commit. If unrelated changes exist, ask which files to include.
- Never commit secrets, credentials, tokens, private keys, or sensitive data. If suspected, stop and report exact file/path concern.
- Always preview selected files, commit message, and exact command before running `git commit`.
- Always ask the user for explicit confirmation before running `git commit`.
- Do NOT run `git commit` unless the user clearly confirms after preview.
- Do NOT amend, squash, rebase, tag, push, or force-push unless the user explicitly asks.

## Steps

1. **Inspect repository state** — Run:
   - `git status --short`
   - `git diff --stat`
   - `git diff --cached --stat`
   - `git diff`
   - `git diff --cached`
2. **Detect staged files** — If files are already staged, prefer committing only staged files. Do not change staging unless user asks.
3. **Handle unstaged files** — If no files are staged, ask which files to stage/commit unless the user already specified files.
4. **Check for unrelated changes** — If changes appear unrelated, split commit proposal by logical group and ask user which group to commit.
5. **Check for sensitive data** — Look for obvious secrets in diff: API keys, tokens, passwords, private keys, `.env` values, credentials, certificates. Stop if found.
6. **Draft Conventional Commit message** — Use format below. Keep subject concise, imperative, lowercase after type where natural, no trailing period.
7. **Preview before commit** — Show selected files, message, and exact command.
8. **Ask confirmation** — Ask: `Create this commit now? (y/n)` Continue only if user clearly confirms.
9. **Commit** — Run `git commit` only after confirmation. Return commit hash and final message.

## Conventional Commit Format

```text
<type>(<scope>): <subject>

<body>

<footer>
```

Use this compact form when body/footer are not needed:

```text
<type>(<scope>): <subject>
```

## Types

- `feat`: new user-facing behavior or capability.
- `fix`: bug fix.
- `docs`: documentation-only change.
- `style`: formatting-only change, no behavior change.
- `refactor`: code restructuring without behavior change.
- `perf`: performance improvement.
- `test`: tests added or changed.
- `build`: build system or dependency change.
- `ci`: CI/CD config or workflow change.
- `chore`: maintenance task with no product behavior change.
- `revert`: revert previous commit.

## Scope Guidance

- Use a short package, service, module, or feature name: `api`, `auth`, `worker`, `db`, `config`, `skills`.
- Omit scope if unclear or too broad.
- Do not invent overly specific scopes.

## Subject Guidance

- Use imperative mood: `add`, `fix`, `update`, `remove`, `rename`.
- Keep under 72 characters when practical.
- Do not end with period.
- Mention what changed, not implementation trivia.

Good examples:

```text
feat(auth): add refresh token rotation
fix(worker): handle reconnect after nats disconnect
docs(api): document pagination parameters
test(order): cover checkout failure paths
chore(skills): add gitlab mr creation workflow
```

Bad examples:

```text
fixed bug
updates
WIP
feat: stuff
chore: changes
```

## Body Guidance

Add body when the reason, tradeoff, migration, or behavior impact is not obvious.

Body should answer:

- Why change was needed.
- What high-level approach changed.
- Any behavior, migration, config, or compatibility impact.

Avoid repeating the diff line-by-line.

## Footer Guidance

Use footer for:

- Breaking changes: `BREAKING CHANGE: <details>`
- Issue links: `Closes #123`, `Refs #456`
- Co-authors: `Co-authored-by: Name <email>`

## Preview Format

Before committing, output this exact structure:

````markdown
## Commit Preview

Files:
- `<file>`

### Message
```text
<commit message>
```

### Command
```bash
git commit -m "<subject>"
```

Create this commit now? (y/n)
````

If using a multi-line message, preview command shape as:

```bash
git commit -m "<subject>" -m "<body>" -m "<footer>"
```

Do not proceed unless the user clearly confirms.

## Staging Guidance

- If files are already staged, do not run `git add` unless user asks.
- If user says `commit all`, preview all changed files first, including untracked files.
- If user specifies paths, stage only those paths after preview and confirmation.
- If generated files or lockfiles changed, mention them explicitly in preview.
- If there are untracked files, never include them silently.

## Output After Commit

After `git commit` succeeds, return:

```markdown
## Commit Created

Hash: `<hash>`
Message: `<subject>`
Files committed:
- `<file>`
```

If commit fails, return exact error and the command attempted.
