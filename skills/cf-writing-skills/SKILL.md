---
name: cf-writing-skills
description: Use when creating a new skill for this workspace or substantially modifying an existing skill. Enforces frontmatter format, body structure, cf-testing methodology, and integration conventions so new skills are consistent, discoverable, and actually work when loaded by the coding agent.
---

# Writing Skills

A skill in this workspace is a directory under `skills/<skill-name>/`
with a `SKILL.md` file that has YAML frontmatter and a body the
coding agent loads when triggered.

Skills are how we encode repeatable engineering knowledge. A skill
that is vague, untested, or mis-triggers is worse than no skill — it
makes the agent confidently wrong.

## When To Use This Skill

Use this skill when:

- Creating a new skill directory in this repository
- Substantially modifying an existing skill (new section, new
  protocol, new prompt template)
- Reviewing a skill PR for adherence to workspace conventions

Do NOT use this skill when:

- The change is a typo, wording fix, or one-line clarification (just
  edit and commit)
- The change adds an example to an existing section (no protocol
  change)
- The skill is in a different workspace's convention (out of scope
  here)

## Skill Anatomy

Every skill in this workspace has this structure:

```
skills/<skill-name>/
├── SKILL.md              # required: frontmatter + body
├── <prompt-name>.md      # optional: prompt templates for subagents
└── <example>.md          # optional: worked examples
```

Conventions:

- Directory name: lowercase, hyphens for multi-word, no underscores
- `SKILL.md` filename is fixed — agents look for it
- Prompt templates for subagent dispatch are at the skill root, not
  nested deeper
- Examples are at the skill root, named with `.md`

## Frontmatter

`SKILL.md` starts with YAML frontmatter that the agent uses to decide
when to load the skill:

```yaml
---
name: <skill-name>
description: <one or two sentences describing when to load this
  skill. Include the trigger conditions and what kind of task it
  applies to. Be specific so the agent does not mis-trigger.>
---
```

### Name Field

- Must match the directory name exactly
- Lowercase, hyphens for multi-word (`cf-subagent-orchestration`,
  not `SubagentOrchestration` or `subagent_orchestration`)
- Verb-noun or noun-noun form preferred
  (`code-review`, `cf-commit-create`, `cf-integration-testing`,
  `cf-subagent-orchestration`)

### Description Field

The description is the **only trigger signal** the agent has. Be
specific:

- ✅ Good: `Use when executing an approved spec with multiple
  independent acceptance criteria, after the visible execution plan and
  before Gate 2, for Lane A or Lane B without heavy trigger.`
- ❌ Bad: `Helps with subagent stuff.`

Include:

- When to load (trigger conditions)
- What kind of task it applies to
- Any lane or workflow stage constraints

Do NOT include:

- Marketing language ("powerful", "comprehensive", "flexible")
- Vague claims ("various scenarios", "many use cases")
- Redundant restatement of the name

Aim for 1-3 sentences. Frontmatter is a contract — be precise.

## Body Structure

The body is markdown. ControlFlow workflow skills should use these
sections in this order. Peer skills may adapt the shape, but should keep
the same intent.

### 1. Overview

One or two paragraphs explaining what the skill does, where it sits in
ControlFlow, and why it exists. This is not marketing copy; it is context
for the agent.

### 2. When To Use This Skill

Trigger conditions. When should the agent load this skill? When
should it NOT? Be explicit about both. Include lane constraints,
workflow stage constraints, and any prerequisites.

This section is the most important. If the agent cannot decide when
to load the skill, the rest does not matter.

### 3. When NOT To Use This Skill

Explicit exclusions. List cases where the skill is tempting but wrong.
For ControlFlow workflow skills, this usually includes missing gates,
wrong workflow stage, wrong lane, or direct-edit cases.

### 4. Core Principles (Optional)

If the skill enforces non-obvious principles or rules of thumb,
list them. Each principle is a short statement with a one-line
explanation. Examples from existing skills:

- `Observe before acting` (cf-debugging)
- `One spec compliance check is not enough` (cf-subagent-orchestration)
- `Test the test` (verification-before-completion)

Skip this section if the principles are obvious from the protocol.

### 5. Process

The actual instructions. This is usually the largest section.

Use:

- Numbered steps for sequential processes
- Bullet points for parallel options
- Code blocks for commands, templates, and examples
- Tables for comparing options (e.g., per-lane behavior)
- Flow diagrams (mermaid or `dot`) for branching logic

Avoid:

- Walls of text
- "Etc." or "and so on"
- Vague verbs ("handle appropriately", "process correctly")

### 6. Common Rationalizations

Table of excuses agents use to skip steps, with the factual rebuttal.
Format:

```md
| Rationalization | Reality |
|---|---|
| "This is small enough to skip tests." | If behavior changes, evidence is required. |
```

### 7. Red Flags

Observable signs that the skill is being misused. Red flags should help
the agent stop before damage, not just describe bad style.

### 8. Verification

Evidence checklist before leaving the skill. Every item should be
verifiable by file path, command output, approval, or written handoff.

### 9. Examples (Optional But Recommended)

Worked examples showing the skill in action. One short example is
worth more than a page of explanation. The example should be:

- Realistic (a scenario the workspace actually encounters)
- Complete (show the input, the process, the output)
- Annotated (call out which step is which)

### 10. Anti-patterns

Things the agent should NOT do. This is the negative space of the
skill. If the skill has rules, the anti-patterns section is where
you enforce them.

Format: `- **Don't <bad thing>** — <why>`

### 11. Integration With Other Skills

If the skill is part of a larger workflow (e.g., it is called from
`cf-intake`), say so explicitly. List the skills it
interacts with and how. This prevents the agent from loading the
skill in the wrong context.

## Subagent Prompt Files

If the skill dispatches subagents, the prompt templates live at the
skill root, not nested:

```
skills/cf-subagent-orchestration/
├── SKILL.md
├── implementer-prompt.md
├── spec-reviewer-prompt.md
└── code-reviewer-prompt.md
```

Each prompt file is a template with `<placeholder>` slots the
orchestrator fills in. The convention used in this workspace:

- The file is the exact prompt the orchestrator sends, with
  placeholders inline
- Placeholders use `<angle brackets>` and are named
  (`<criterion-text>`, not `<X>`)
- The orchestrator copies the file, fills placeholders, and
  dispatches

Each prompt file has this structure:

1. **Role statement** — what kind of subagent this is, what
   context it has (none of the orchestrator's prior context)
2. **Inputs** — the placeholder slots with comments about what
   goes in each
3. **The job** — what the subagent must do
4. **Constraints** — what the subagent must NOT do
5. **Output format** — exact report format the orchestrator parses

## Testing The Skill

A skill without cf-testing is a guess. Before merging a new skill:

### 1. Trigger Test

Does the description field cause the agent to load the skill at the
right time?

- Run a prompt that should trigger the skill. Verify it loads.
- Run a prompt that should NOT trigger. Verify it does not load.
- Run a prompt in a similar but different context. Verify the
  agent does not mis-trigger.

If the description is too broad, the skill loads too often and
adds noise. If too narrow, it does not load when it should.

### 2. Output Test

For skills that produce structured output (templates, handoff
messages, prompts), run a representative input through the skill
and verify the output is:

- Correct (matches the spec)
- Complete (no missing sections)
- Formatted (matches the conventions)

If the skill produces a subagent prompt, run a small test by
dispatching that subagent and checking the result.

### 3. Integration Test

If the skill is part of a workflow (e.g., called from
`cf-intake`), test the full flow with the new skill:

- Spec approved → skill loads → protocol executes → handoff correct
- Edge case: skill should not load → agent proceeds without it
- Edge case: skill partially applies → agent escalates correctly

### 4. Adversarial Test

Try to make the skill fail:

- Vague input (does the skill ask for clarification or guess?)
- Conflicting constraints (does the skill prioritize correctly?)
- Missing information (does the skill use NEEDS_CONTEXT or guess?)
- Lane mismatch (does the skill refuse work outside its scope?)

If the skill guesses when it should ask, fix the body. If the skill
is silent about a constraint, add it to the anti-patterns section.

## Style Conventions

Follow these for consistency with existing skills:

- **Voice**: imperative for instructions ("Run the test"), descriptive
  for context ("The orchestrator fills the placeholders")
- **Sentence length**: short for rules, longer for explanations
- **Code blocks**: fenced with language hints (` ```sh `, ` ```go `,
  ` ```md `, ` ```text `)
- **Emphasis**: bold for critical rules, backticks for file paths and
  commands
- **Lists**: numbered for sequences, bulleted for non-sequences
- **No emojis** in skill bodies (workspace convention)
- **No marketing language** — describe what the skill does, not
  why it's great

## Self-Review Checklist

Before committing a new or modified skill, run this checklist:

**Frontmatter:**

- [ ] `name` matches directory name
- [ ] `description` is specific about when to load
- [ ] `description` includes trigger conditions, not just purpose
- [ ] No marketing language in `description`

**Body:**

- [ ] "When To Use" section is explicit (load / not load)
- [ ] "When To Use" includes lane or workflow constraints if any
- [ ] Process is concrete (commands, file paths, code blocks)
- [ ] No "etc." or "and so on" — every instruction is complete
- [ ] Anti-patterns section exists if the skill has rules
- [ ] Integration section exists if the skill is part of a workflow
- [ ] No emojis, no marketing language
- [ ] Code blocks have language hints
- [ ] Cross-references to other skills use exact names

**Prompt templates (if any):**

- [ ] One prompt per file
- [ ] Placeholders use `<angle-bracket>` syntax
- [ ] Each prompt has Role / Inputs / Job / Constraints / Output
- [ ] No placeholder is left without a comment explaining it

**Testing:**

- [ ] Trigger test passed
- [ ] Output test passed (if applicable)
- [ ] Integration test passed (if part of a workflow)
- [ ] Adversarial test passed

**Integration:**

- [ ] Directory added under `skills/` so `install.sh` discovers it
- [ ] Integrated with `skills/cf-state-machine/SKILL.md` if it changes agent workflow
- [ ] Listed in `README.md` if user-facing
- [ ] Existing skills that reference the new one are updated

## Common Mistakes

### Description Too Broad

```yaml
# BAD: loads for almost everything
description: Helps with Go development tasks.

# GOOD: specific trigger
description: Use when implementing Go code changes that touch
  gORM, gRPC, NATS JetStream, or MySQL. Enforces clean
  architecture boundaries and safe concurrency.
```

### Vague Protocol

```markdown
# BAD
Handle errors appropriately. Then continue.

# GOOD
On error from `db.Query`, log with `slog.Error` including the
query and the error, return wrapped error:
`fmt.Errorf("query prices: %w", err)`. Do not return partial
results.
```

### Missing Anti-patterns

If the skill has rules but no anti-patterns section, the agent will
eventually violate the rules. Every rule in the protocol should have
a corresponding anti-pattern. If you cannot write an anti-pattern,
the rule may not be a real rule.

### Skill Body Is Just An Outline

```markdown
# BAD: outline only
## Process
1. Analyze
2. Plan
3. Implement
4. Test

# GOOD: actionable
## Process
1. Read `internal/prices/prices.go` end-to-end.
2. Identify the function(s) that need to change for the criterion.
3. Write a failing test in `internal/prices/prices_test.go`.
4. Run `go test ./internal/prices -run TestNew -v` and confirm fail.
5. Implement the smallest change to make the test pass.
6. Run `go test ./internal/prices -run TestNew -v` and confirm pass.
7. Run `go test ./internal/prices -count=1 -race` for the full
   package.
```

### No Integration Section

A skill that does not say how it fits with other skills will be
loaded in the wrong context or not at all. Always include
"Integration With Other Skills" if the skill is part of the
workspace's workflow.

## Adapting A Skill From Another Source

When porting a skill from Superpowers, Anthropic's guides, or
elsewhere:

1. **Keep the protocol, change the examples** — workspace-specific
   examples (Go, GORM, NATS, our domain) replace generic ones
2. **Add our frontmatter conventions** — name and description in our
   style
3. **Add lane and workflow constraints** — explicit reference to
   Lane A / B and `cf-intake` stages
4. **Test the trigger** — the original description may not match
   our agent's trigger behavior
5. **Cite the source** — note in commit message that this is
   adapted from X, so future maintainers know the lineage
6. **Do not just translate** — if the original skill has parts that
   do not fit our workflow, drop them or rewrite. Do not import
   the whole thing verbatim.

## Language-Peer Skills

The workflow itself is language-agnostic. The implementation step
(implementation stage in `cf-intake`) is implemented by a peer skill
per language. This repo currently ships:

- `cf-golang-engineer` — Go implementations

To add a peer skill for another language:

1. **Create the directory** at `skills/<language>-engineer/` with a
   `SKILL.md` that follows all the conventions in this guide.
2. **Set the frontmatter description** to trigger on the language
   keywords: e.g., "Use when implementing, fixing, or refactoring
   Rust code." The agent loads the right peer skill by trigger
   matching.
3. **Cover the same TDD and clean-architecture protocol** as
   `cf-golang-engineer` — the principles (tests first, clean
   boundaries, safe concurrency, error handling) are universal.
   Replace Go-specific tools, commands, and idioms with the
   language equivalents.
4. **Cross-reference `cf-intake`** in the Integration
   section so the agent knows where this skill sits in the
   workflow.
5. **Add the skill directory under `skills/`** and cross-reference it from
   `cf-intake` or `cf-state-machine` if it changes the workflow.
6. **Test the trigger** — verify the agent loads this skill on
   the right language-specific requests and not on others.

**Do not create a single mega-skill that handles all languages.**
The trigger is much more reliable when the description explicitly
mentions the language. The user should not have to say "load the
Rust skill"; the agent should infer it from "implement this in
Rust."

**Do not duplicate protocol content across peer skills.** Each
language skill can reference the universal protocol in
`cf-intake` and add only the language-specific tooling
and idioms.

Examples of peer skills to add later (when needed):

- `cf-rust-engineer` — Rust implementations (ownership, lifetimes,
  async/await, tokio)
- `cf-python-engineer` — Python implementations (pytest, type hints,
  asyncio)
- `typescript-engineer` — TypeScript implementations (Jest, type
  narrowing, async)
- `elixir-engineer` — Elixir implementations (ExUnit, OTP
  patterns, GenServer)

## Pull Request Template

When opening a PR for a new or modified skill:

```markdown
## Skill: <name>

### What

<one-line description of what the skill does>

### Why

<why we need it — what gap it fills>

### Trigger

<when should the agent load this skill?>

### Tested

- [ ] Trigger test
- [ ] Output test (if applicable)
- [ ] Integration test (if part of workflow)
- [ ] Adversarial test

### Integration

<which other skills does this interact with?>

### Source

<if adapted from elsewhere: link to source and note adaptations>

### Checklist

- [ ] Self-review checklist completed
- [ ] Skill directory lives under `skills/` for installer discovery
- [ ] Cross-references in `cf-intake`, `cf-state-machine`, and other
      affected skills updated
- [ ] `README.md` updated if user-facing
```
