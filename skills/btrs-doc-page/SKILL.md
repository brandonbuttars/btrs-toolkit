---
name: btrs-doc-page
description: >
  Write documentation through guided conversation. Helps structure and write
  any kind of documentation: guides, tutorials, architecture overviews,
  onboarding docs, runbooks. Use when the user wants to write docs, create
  a guide, document a process, or asks "write docs for", "btrs doc page",
  "create a guide", "document how to", "write a runbook", "onboarding doc".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <topic or title>
---

# Document Page Skill

Write documentation through guided conversation. Produces a structured doc page on any topic.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Understand what to document

If `$ARGUMENTS` is provided, use it as the topic. Otherwise ask: "What do you want to document?"

Determine the doc type:

| Type | When to use | Examples |
|------|-------------|---------|
| `guide` | Step-by-step instructions | Setup guide, deployment guide |
| `tutorial` | Learning-oriented walkthrough | "Build your first widget" |
| `overview` | High-level architecture or system description | System architecture, data flow |
| `reference` | Lookup-oriented, comprehensive | Config options, CLI flags |
| `runbook` | Operational procedures | Incident response, on-call guide |
| `onboarding` | New team member orientation | "Getting started as a developer" |
| `howto` | Task-oriented, concise | "How to add a new endpoint" |

Ask the user:
- Who is the audience?
- What should they be able to do after reading this?
- What do they already know?

## Step 2: Gather content

Based on the topic, read relevant source material:
- Source code files related to the topic
- Existing docs that overlap or relate
- `<basedir>/tech-stack.md` for project context
- ADRs for architectural decisions relevant to the topic
- Config files for setup/deployment docs

Ask the user for any information that isn't in the code:
- Tribal knowledge
- External dependencies or services
- Environment-specific details
- Common gotchas

## Step 3: Plan the structure

Propose an outline based on the doc type:

### Guide/Tutorial structure
1. Overview — What and why
2. Prerequisites — What you need before starting
3. Steps — Numbered, actionable steps
4. Verification — How to confirm it worked
5. Troubleshooting — Common issues and fixes
6. Next steps — Where to go from here

### Overview/Architecture structure
1. Summary — What this system/component does
2. Diagram — Visual representation (ASCII or description)
3. Components — Key parts and their roles
4. Data flow — How data moves through the system
5. Key decisions — Links to relevant ADRs
6. Constraints — Limitations and boundaries

### Reference structure
1. Overview — What this covers
2. Sections — Organized by category
3. Examples — For each item
4. Related — Links to guides/tutorials

### Runbook structure
1. Trigger — When to use this runbook
2. Prerequisites — Access, tools, permissions needed
3. Steps — Numbered with expected outcomes
4. Rollback — How to undo if something goes wrong
5. Escalation — Who to contact if this doesn't resolve it
6. Post-incident — Follow-up actions

Present the outline and ask for confirmation or adjustments.

## Step 4: Write the documentation

Write to `<basedir>/docs/<slug>.md`:

```markdown
---
title: "<Title>"
type: "<guide | tutorial | overview | reference | runbook | onboarding | howto>"
audience: "<who this is for>"
updated: YYYY-MM-DD
tags:
  - doc
  - "doc/<type>"
---

# <Title>

<Content structured according to the chosen outline.>

## Related

- <Wikilinks to source files, ADRs, specs, other docs>
```

Writing guidelines:
- Lead with the most important information
- Use concrete examples over abstract descriptions
- Include code snippets from the actual codebase (with wikilinks to source)
- Keep paragraphs short (3-5 sentences)
- Use callouts for warnings, tips, and important notes
- Link to source files with wikilinks so readers can navigate in Obsidian

## Step 5: Review with the user

After writing, present:
- The complete document for review
- Ask if anything is missing, incorrect, or unclear
- Iterate based on feedback

## Step 6: Present the result

Tell the user:
- Doc file path
- Document summary and audience
- Suggest: "View in Obsidian at `<basedir>/docs/`"
