---
name: cf-glab-release-note
description: Manage a GitLab release's notes for an existing tag using `glab release create`. Use when the user asks to update, set, rewrite, or generate release notes for a tag; auto-generates a Conventional Commits changelog, previews, and requires explicit confirmation before publishing.
---

Set or update the release notes for an existing Git tag on GitLab using
`glab release create --notes`. This is a notes-only operation: it does
not push code, create tags, or change release metadata other than the
notes field.

Independent skill. Not invoked from `cf-intake`. Triggered
directly by the user when they want a release's notes rewritten.

## Important

- Always preview the generated notes, the exact `glab release create`
  command, and any existing-notes diff before publishing.
- Always ask the user for explicit confirmation before running
  `glab release create`. Do not run it on a guess.
- Do NOT create, push, mutate, or delete tags. The tag must already
  exist locally or on the remote. If it does not, stop and ask.
- Do NOT change release metadata other than the notes field. Do not
  pass `--ref`, `--tag-message`, `--milestone`, `--assets-links`,
  `--released-at`, or asset paths unless the user explicitly asks.
- Do NOT auto-merge, approve, or change MR settings.
- Do NOT include commit hashes from secrets, credentials, internal
  hosts, or unreleased branches without scrubbing.
- Do NOT overwrite an existing release's notes silently. Show the
  current-vs-proposed diff summary and require explicit `y`.
- If the working tree is dirty or the user has unpushed commits that
  should be in the release, stop and warn. The range is computed
  from local refs; the user must decide what is "in" the release.
- Prefer `--notes-file` over `--notes` for any non-trivial body to
  avoid shell quoting issues and to keep the preview faithful.

## When To Use This Skill

Use this skill when the user asks to:

- "prepare release notes for v1.4.0"
- "update the release notes for the v2 tag"
- "regenerate the changelog for the latest release"
- "rewrite release notes from the commits since v1.3.0"
- "set the GitLab release description for tag X"

Do NOT use this skill when:

- The user wants to create a brand-new release with assets. That is
  `glab release create` end-to-end; defer to the user's own command
  or the `glab` docs.
- The user wants to view an existing release. Use
  `glab release view <tag>` directly.
- The user wants to upload release assets. Use `glab release upload`.
- The user wants a markdown changelog file checked into the repo
  (e.g., `CHANGELOG.md`). That is a repo artifact, not a GitLab
  release field. Suggest a different approach.
- The work is a typo fix in an existing release. Just edit and
  re-run with `--notes-file`.

## Core Principles

- **Preview is mandatory** — never publish a release's notes
  without showing the user what will land.
- **Notes-only update** — do not touch tags, refs, assets, or other
  release fields.
- **Group by Conventional Commit type** — readers want a
  Highlights, Features, Bug Fixes, Other, Breaking Changes shape,
  not a flat list.
- **Surface breaking changes loudly** — anything with a `!` after
  the type or a `BREAKING CHANGE:` footer gets its own section.
- **The user owns the diff** — when the release already has notes,
  the user must opt in to overwriting.

## The Process

### 1. Resolve project and target tag

Use only safe read-only commands:

```sh
git rev-parse --abbrev-ref HEAD
git remote -v
git status --short --branch
glab repo view
```

Ask the user for the target tag if not provided. Common forms:
`v1.4.0`, `1.4.0`, `release-2026-06`. Normalize mentally but pass the
exact value to `glab`.

If the tag does not exist locally:

```sh
git fetch --tags
git rev-parse --verify <tag>
```

If still missing, stop and ask. Do not run `glab release create`
with a tag that does not exist locally, because `glab` would create
it from `--ref` (default branch HEAD) which is almost never what
the user wants for a notes-only update.

### 2. Resolve previous tag

Find the previous tag reachable from the current branch's tip, or
the parent tag in semver order. Strategies, in order of preference:

1. The user provides `--from <prev-tag>`.
2. `git describe --tags --abbrev=0 <tag>^` if it returns a tag.
3. The semver-previous tag via `git tag --sort=-version:refname`.
4. The chronologically previous tag via
   `git tag --sort=-creatordate`.

Show the resolved range in the preview so the user can correct it.

### 3. Gather commits in range

```sh
git log --no-merges --pretty=format:'%H%x09%s%n%b' <prev-tag>..<tag>
```

For merge commits use `git log --merges --pretty=format:'%H%x09%s%n%b'`
separately if the project records merge commits as part of the
release history. Default to `--no-merges` unless the project
convention is clearly to include merges.

Capture each commit's:

- `type` from the Conventional Commit prefix (`feat`, `fix`, `docs`,
  `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`,
  `revert`).
- `scope` if present in parentheses.
- `subject` (the part after `type(scope): `).
- `body` for `BREAKING CHANGE:` footers.
- `hash` (short, 7 chars) for traceability.

Skip commits that do not match the Conventional Commits shape; group
them under `### Other` with a warning that no recognized type was
found.

### 4. Build the notes Markdown

Write to a temp file under the system temp dir, e.g.
`/tmp/cf-glab-release-note-<tag>.md`. Never write inside the repo
unless the user asks.

Apply the default template (see "Default Notes Template" below). At
the top, pick a `Highlights` section by taking the top 1–3 items
from `feat` and `fix` combined, preferring those with the most
significant scope or the longest subject. If there are no `feat` or
`fix` items, the Highlights section is omitted.

If the release already has notes, do not diff at the markdown level
— just print a byte-level summary:

````text
Existing notes: 1.2 KB
Generated notes: 2.4 KB
Delta: +1.2 KB / -0.3 KB
````

### 5. Preview

Output the preview block. Do not run `glab` yet.

````markdown
## Release Notes Preview

Tag: `<tag>`
Project: `<namespace>/<repo>`
Previous tag: `<prev-tag>`
Commit count: `<n>`
Existing release: yes / no
File: `<tmpfile>`

> [If existing release]
> Existing notes will be OVERWRITTEN. Delta: +X / -Y bytes.
> Type `Y` to confirm overwrite, `N` to abort, or tell me what to
> change in the generated notes.

### Generated Notes

```markdown
<the full markdown>
```

### Command

```bash
glab release create <tag> \
  --notes-file <tmpfile> \
  --yes
```

Publish these notes to GitLab now? (y/n)
````

### 6. Confirm

Ask: `Publish these notes to GitLab now? (y/n)`

If the user says `y` or otherwise confirms, proceed. If `n`,
abort, keep the temp file (or move it to `./RELEASE_NOTES_<tag>.md`
if the user wants to edit), and report that the release was not
changed.

### 7. Publish

Run exactly the command from the preview. Use `--yes` because we
already confirmed at the skill level — `glab`'s own interactive
confirmation is redundant.

After success, return:

````markdown
## Release Notes Published

Tag: `<tag>`
URL: <release URL if glab prints one, else "not printed">
Notes updated: yes
Assets touched: no
Tag ref changed: no
````

If the command fails, return the exact stderr, the command
attempted, and a one-line hint about likely causes (auth, network,
release already exists with `--no-update` issue, etc.).

### 8. Cleanup

Leave the temp file in place. Some users want to inspect or commit
it. If the user asks, move it to `./RELEASE_NOTES_<tag>.md` or
delete it.

## Default Notes Template

```markdown
## <tag> — <YYYY-MM-DD>

### Highlights
- <feat or fix item, 1-3 bullets>

### Features
- <feat(scope)>: <subject> (<short-hash>)

### Bug Fixes
- <fix(scope)>: <subject> (<short-hash>)

### Other Changes
- **<type>**: <subject> (<short-hash>)

### Breaking Changes
- **<type>(scope)!: <subject>** (<short-hash>) — <BREAKING CHANGE: body>

### Full Changelog
Compare: [<prev>...<tag>](https://<host>/<namespace>/<repo>/-/compare/<prev>...<tag>)
```

Rules:

- Date is the tag's commit date (`git log -1 --format=%cs <tag>`),
  not today.
- Omit empty sections. Do not print `### Features` if there were
  no `feat` commits.
- Do not include merge commit bodies unless the project convention
  is to include merges.
- Do not include commit bodies in non-Breaking sections; subject
  only. The hash is enough for traceability.
- The `Full Changelog` URL requires the project host. Derive it
  from `git remote get-url origin`:
  - `git@<host>:<path>.git` → `https://<host>/<path>/-/compare/<prev>...<tag>`
  - `https://<host>/<path>.git` → same shape, drop the `.git`
- If the host cannot be determined (e.g., no remote), omit the
  Full Changelog line and tell the user.

## Examples

### Example 1: Fresh notes for a new tag

User: "prepare release notes for v1.4.0"

The skill resolves:

- tag: `v1.4.0`
- previous tag: `v1.3.0`
- commits: 17, grouped as `feat`(4), `fix`(3), `refactor`(2),
  `test`(3), `docs`(1), `perf`(1), `build`(1), `ci`(1), `chore`(1)
- one breaking change: `feat(api)!: drop /v1 orders endpoint`

Generated notes:

````markdown
## v1.4.0 — 2026-06-09

### Highlights
- feat(checkout): support apple pay (`a1b2c3d`)
- fix(cart): correct qty overflow (`b2c3d4e`)

### Features
- feat(cart): add bulk add-to-cart (`c3d4e5f`)
- feat(api): paginate order list (`d4e5f6a`)
- feat(checkout): support apple pay (`a1b2c3d`)
- feat(i18n): add id translations (`e5f6a7b`)

### Bug Fixes
- fix(cart): correct qty overflow (`b2c3d4e`)
- fix(checkout): handle 3ds timeout (`f6a7b8c`)
- fix(api): clamp page size (`a7b8c9d`)

### Other Changes
- **docs**: docs(readme): add quickstart (`b8c9d0e`)
- **refactor**: refactor(cart): extract pricing service (`c9d0e1f`); refactor(api): split order handlers (`d0e1f2a`)
- **perf**: perf(cart): index sku lookup (`e1f2a3b`)
- **test**: test(cart): cover bulk add (`f2a3b4c`); test(checkout): 3ds timeout (`a3b4c5d`); test(api): pagination (`b4c5d6e`)
- **build**: build(deps): bump go-redis v9.5 (`c5d6e7f`)
- **ci**: ci(go): add race job to ci (`d6e7f8a`)
- **chore**: chore: bump version to 1.4.0 (`e7f8a9b`)

### Breaking Changes
- **feat(api)!: drop /v1 orders endpoint** (`f8a9b0c`) — `/v1/orders` returns 410. Use `/v2/orders`. Migration deadline: 2026-09-01.

### Full Changelog
Compare: [v1.3.0...v1.4.0](https://gitlab.com/acme/checkout/-/compare/v1.3.0...v1.4.0)
````

Command (previewed, not run):

```bash
glab release create v1.4.0 \
  --notes-file /tmp/cf-glab-release-note-v1.4.0.md \
  --yes
```

### Example 2: Overwrite existing notes

User: "regenerate the release notes for v2.0.0, the current ones
are wrong"

The skill detects an existing release, fetches the current notes
length, generates fresh ones, and shows the diff summary:

````text
Existing notes: 3.1 KB
Generated notes: 2.4 KB
Delta: +1.8 KB / -2.5 KB
````

Then asks for explicit `y` because the user said "regenerate", but
the preview must still make the overwrite visible.

### Example 3: User-supplied file

User: "publish RELEASE_NOTES_v1.5.0.md as the release notes for
v1.5.0"

The skill skips auto-generation, reads the file as-is, and
previews its contents verbatim. Still requires confirmation.

## Anti-patterns

- **Don't publish without a preview** — the user must see exactly
  what will land. No "I'll just push it" moves.
- **Don't pass `--ref` to `glab release create`** — that creates a
  new tag. This skill is notes-only.
- **Don't include asset paths or `--use-package-registry`** — that
  uploads binaries. Out of scope.
- **Don't auto-discover the previous tag and silently use it** —
  always show the resolved range in the preview so the user can
  correct it.
- **Don't fabricate release dates** — use `git log -1 --format=%cs
  <tag>`. Never use today's date.
- **Don't include the full commit body in non-Breaking sections** —
  it clutters the notes. The hash is the traceability hook.
- **Don't run on a tag that does not exist locally** — the user
  probably does not want a fresh tag from default branch HEAD.
- **Don't write the temp notes file inside the repo** unless the
  user asks. The release notes are a GitLab release field, not a
  repo artifact.

## Integration With Other Skills

- **Independent.** Not invoked from `cf-intake`. Users
  trigger it directly when they want to update a release's notes.
- **Pairs with `cf-glab-mr-create`** for projects that link a release
  to a release-prep MR. The MR body may reference the release
  notes preview; the release itself is updated with this skill.
- **Pairs with `cf-commit-create`** for the input commits: this skill
  expects Conventional Commits in `git log` and groups by type.
  If the project does not use Conventional Commits, the auto-
  generation degrades to a flat list and the skill warns the user.
- **Does NOT call `code-review`.** Reviews happen on MRs, not releases.
  Use `code-review` from a separate session if needed.

## Command Reference

The exact command this skill runs:

```bash
glab release create <tag> \
  --notes-file <tmpfile> \
  --yes
```

Flags intentionally NOT used (and why):

- `--ref` — would create or change the tag. Notes-only update.
- `--tag-message` — would change the tag's message. Out of scope.
- `--milestone` / `--released-at` — would change release
  metadata. Out of scope.
- Asset flags, `--use-package-registry`, `--assets-links` —
  release asset operations. Out of scope.
- `--publish-to-catalog` — would publish to CI/CD catalog. Out of
  scope; the user must opt in explicitly.

If the user wants any of the above, they should run a different
command or invoke this skill with explicit confirmation of the
extra flag, and the skill must include that flag in the preview.
