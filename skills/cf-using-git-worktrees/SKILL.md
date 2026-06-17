---
name: cf-using-git-worktrees
description: Guides optional git worktree usage for sessions that span multiple commits, days, or are likely to be interrupted. Use when work may need isolation, incoming MR review, hotfix handling, or production investigation; soft suggestion only, never forced. Skip for single-commit single-day tweaks.
---

# Using Git Worktrees (Optional)

Worktrees are **optional**. Use them when they pay off; skip them
when they don't. This workflow does not adopt the "always worktree"
hard rule from other systems. You may work in place, on `main`, on a
feature branch — whatever fits the task.

## When To Recommend A Worktree

Soft-suggest a worktree when **any** of these is true:

- The session will span **multiple days** or **multiple commits**
- The work **touches many files** (risky to switch branches in
  place)
- You expect **interruptions** — incoming MRs, hotfixes, urgent
  questions
- You are already **mid-work** when an interrupt arrives

Skip a worktree when:

- The change is a **single-commit, single-day tweak**
- You are certain no interrupt will arrive (rare in practice)
- The user explicitly says to work in place

## Trigger Model: Soft Suggestion

The agent **does not auto-trigger** worktree usage. Pattern:

1. User says "let's work on feature X" (or equivalent)
2. Agent evaluates the context internally
3. If worktree would help, the agent says something like:
   > "This looks like a multi-commit, multi-day change with possible
   > interrupts. Want me to set up a worktree at
   > `../<repo>.worktrees/feature-x/`? [Y/N] Or work in place?"
4. If user says yes → `git worktree add`
5. If user says no → proceed in place, no re-asking later

If user says "use a worktree" or "set up a worktree for X" → execute
immediately, no questions.

## Mainline Work: Soft Warning Only

If you detect the user is working directly in `main` / `master` /
the default branch, give a **soft reminder**, not a hard stop:

> "Heads up — you're on `main`. For non-trivial work, a feature
> branch (in a worktree or in place) is usually safer. Want me to
> create one? [Y/N]

If user declines, proceed on mainline. **Do not refuse the task.**
This workflow explicitly does not adopt the "stop and force worktree"
rule from superpowers or similar systems.

## Naming Convention

Sibling path, suffix `.worktrees`:

```
<root>/<repo>/                          <- mainline
<root>/<repo>.worktrees/<branch>/       <- work
<root>/<repo>.worktrees/<branch2>/      <- parallel work
```

Branch name = directory name suffix. Keep branches short and
descriptive (e.g. `feature-a`, `hotfix-review`, `bug-123`).

Document the convention in the project's `AGENTS.md` (or equivalent)
so the agent knows where to look:

```markdown
# AGENTS.md
Worktrees live at `../<this-repo>.worktrees/<branch>/`
```

## Setup Commands

```sh
# From mainline, create worktree with new branch
git worktree add ../<repo>.worktrees/<branch> -b <branch>

# From mainline, attach worktree to existing branch (e.g. for review)
git worktree add ../<repo>.worktrees/<branch> <branch>

# List all worktrees
git worktree list

# Remove a worktree
git worktree remove ../<repo>.worktrees/<branch>
```

`<repo>` is the directory name of your mainline repo. `<branch>` is
the new or existing branch name. Suffix `.worktrees` is the
convention — change it to match your project's `AGENTS.md` if it
differs.

## Workflow: Feature A Interrupted By Hotfix MR

You are mid-work on **feature A** in worktree A. A hotfix MR arrives.

```
1. Don't leave worktree A. Your work is intact.

2. From mainline (NOT from worktree A), create worktree B:
   cd <path-to-mainline>
   git worktree add ../<repo>.worktrees/hotfix-review <hotfix-branch>

3. Move into worktree B:
   cd ../<repo>.worktrees/hotfix-review

4. Run `glab-mr-review` or `code-review` skill here.
   - The diff comes from the MR, not from this worktree's working
     state
   - Don't read worktree A's files for context

5. Post review notes (only if user asks):
   glab mr note <ID> --message "..."

6. After review is done, choose:
   - Keep worktree B for follow-up
   - Remove it:
     cd <path-to-mainline>
     git worktree remove ../<repo>.worktrees/hotfix-review

7. Return to worktree A and continue feature A.
   cd ../<repo>.worktrees/feature-a
   # pick up exactly where you left off
```

## After Feature Work Is Done

```sh
# In the worktree, push branch and create review request
cd ../<repo>.worktrees/<branch>
git push -u origin <branch>
# GitLab:
glab mr create --source-branch <branch> --target-branch main ...
# GitHub:
gh pr create --head <branch> --base main ...

# In mainline, after MR/PR is approved and merged:
cd <path-to-mainline>
git checkout main
git pull

# Clean up the worktree
git worktree remove ../<repo>.worktrees/<branch>
git branch -d <branch>  # delete local branch
```

## Tool Harness Compatibility

Worktrees work with any standard CLI harness. Tell the agent
explicitly **where** to work — it does not auto-discover.

### Commands That Need `cd` Into The Worktree

Most file-system operations must run **inside** the worktree where
the code lives:

- Test runners (`go test`, `cargo test`, `npm test`, `pytest`, etc.)
- File reads, edits, writes
- Build, lint, format

Pattern:

```sh
cd <path-to-worktree>
<test-command>
```

If your CLI harness supports a `workdir` parameter (opencode does
on its `bash` tool), use it instead of `cd`:

```
workdir: <absolute-path-to-worktree>
```

### Commands That Don't Need `cd`

These read from the remote or git database, not the working tree:

- `glab mr view <ID>` / `glab mr diff <ID>`
- `gh pr view <ID>` / `gh pr diff <ID>`
- `git log`, `git show`, `git diff <commit>`
- `git worktree list`

Run these from any directory.

### Subagent Dispatch

When dispatching a subagent to work in a worktree, include the
**absolute worktree path** in the task description and instruct
the subagent to enter it before any file operation.

Example dispatch:

```markdown
Task: Implement criterion 2 in worktree
`<absolute-path-to-worktree>`.

Before any file operation, cd into the worktree:
  cd <absolute-path-to-worktree>

Read spec at `<absolute-path-to-worktree>/specs/<feature>.md`.
Implement, test, commit, return summary.
```

Do not rely on the subagent discovering the worktree path on its
own.

## Anti-Patterns

- **Don't** hardcode user-specific paths (e.g. `/Users/...`,
  `~/projects/...`) in skill files — use placeholders or relative
  paths so the skill works for any contributor
- **Don't** run file-system tools in the wrong worktree — they
  won't see your changes
- **Don't** assume the agent knows which worktree to use — always
  tell it explicitly
- **Don't** create nested worktrees (worktree inside worktree) —
  confuses git's bookkeeping
- **Don't** run `git checkout <branch>` from a worktree that
  already has that branch checked out — git will reject
- **Don't** keep dead worktrees around — `git worktree list` should
  show only active work
- **Don't** symlink `node_modules` / build cache between worktrees
  unless the toolchain is known to be safe with it
