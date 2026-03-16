---
name: btrs-create-adr
description: >
  Create an Architecture Decision Record (ADR) through guided conversation.
  Walks through the MADR format: context, options, tradeoffs, and decision.
  Auto-numbers and saves to the decisions directory. Use when the user wants
  to create an ADR, record a decision, document an architecture choice, or
  asks "create ADR", "btrs create adr", "record a decision", "let's document
  this decision", "we decided to", "ADR for".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Write, Grep, Glob
argument-hint: ["decision topic"]
---

# Create ADR Skill

Create an Architecture Decision Record through guided conversation using the MADR (Markdown Any Decision Records) format.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Scan existing ADRs

Check for existing ADRs to determine the next number:

```bash
ls <basedir>/decisions/ADR-*.md 2>/dev/null | sort -V | tail -5
```

Read the last few to understand the project's ADR conventions and what decisions have already been made. This helps avoid duplicating or contradicting existing decisions.

Determine the next ADR number (zero-padded 4 digits, starting at 0001).

## Step 2: Understand the decision

If `$ARGUMENTS` is provided, use it as the topic. Otherwise ask: "What decision do you need to document?"

Work through the MADR sections conversationally:

### Context and Problem Statement

Ask the user to describe:
- What's the situation that requires a decision?
- What problem are we solving?
- What question are we trying to answer?
- What forces or constraints are at play?

Help them articulate this clearly. Read relevant source files if it would add useful context.

### Decision Drivers

Ask: "What factors are most important in making this decision?"

Prompt for both technical and non-technical drivers:
- Performance, scalability, maintainability
- Team familiarity, learning curve
- Timeline, deadlines
- Existing patterns in the codebase
- Cost, licensing
- User experience impact

### Considered Options

Ask: "What options have you considered?"

For each option, work through:
- Brief description of the approach
- Pros — What makes this attractive?
- Cons — What are the downsides or risks?

If the user has only one option, challenge them to consider at least one alternative. Good decisions require genuine comparison. Common alternatives:
- The status quo (do nothing)
- A simpler approach
- A more established/conventional approach
- A more flexible/future-proof approach

If the user is unsure about options, search the codebase for existing patterns and suggest approaches based on what the project already does.

### Decision Outcome

Ask: "Which option did you choose (or are you leaning toward)?"

Work through:
- Why this option over the others
- How it addresses the decision drivers
- Positive consequences — What improves?
- Negative consequences — What tradeoffs are we accepting?
- Neutral consequences — What changes but isn't clearly better or worse?

### Status

Ask: "Is this decision final (Accepted) or still under discussion (Proposed)?"

## Step 3: Write the ADR

Write to `<basedir>/decisions/ADR-<NNNN>-<slug>.md`:

The slug is derived from the title: lowercase, hyphens for spaces, stripped of special characters, max 50 chars.

```markdown
---
title: "ADR-<NNNN>: <Title>"
date: YYYY-MM-DD
status: "<proposed | accepted>"
deciders: "<who was involved>"
type: adr
tags:
  - adr
  - "adr/<status>"
---

# ADR-<NNNN>: <Title>

## Status

<Proposed | Accepted>

## Context and Problem Statement

<From the conversation>

## Decision Drivers

- <Driver 1>
- <Driver 2>
- <Driver 3>

## Considered Options

### Option 1: <Name>

<Description>

**Pros:**
- <Pro 1>

**Cons:**
- <Con 1>

### Option 2: <Name>

<Description>

**Pros:**
- <Pro 1>

**Cons:**
- <Con 1>

## Decision Outcome

**Chosen option:** "<Option name>"

<Reasoning — reference decision drivers>

### Consequences

**Positive:**
- <What improves>

**Negative:**
- <What tradeoffs we accept>

**Neutral:**
- <What changes without clear valence>

## Links

- <Related ADRs as wikilinks: [[ADR-0002]]>
- <Related tech debt items: [[0005]]>
- <Related source files: [[src/path/to/relevant/file]]>
```

## Step 4: Check for related items

After writing the ADR, check if the decision creates any action items:

- Does it require code changes? → Offer to create todo items
- Does it deprecate a previous ADR? → Update the previous ADR's status to `Superseded by [[ADR-<NNNN>]]`
- Does it affect existing tech debt items? → Note the relationship

## Step 5: Present the result

Tell the user:
- The file path
- ADR number and title
- The chosen option (brief summary)
- Any follow-up items created
- Suggest: "Link to this ADR from relevant code comments: `// See ADR-<NNNN>`"
