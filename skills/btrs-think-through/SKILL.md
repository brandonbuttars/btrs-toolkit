---
name: btrs-think-through
description: >
  Talk through anything — a problem, idea, decision, feature, or architecture
  question. Through conversation, identify the right artifact type and produce
  it along with a conversation summary. Use when the user wants to think
  something through, brainstorm, talk through an idea, reason about a problem,
  or asks "think through", "let's think about", "btrs think", "help me think",
  "let's talk through", "I'm trying to figure out", "what should we do about".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Write, Grep, Glob
argument-hint: ["topic"]
---

# Think Through Skill

A conversational skill for working through problems, ideas, and decisions. The goal is to help the user clarify their thinking and produce the right artifact at the end.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that the basedir directory exists.

## Step 1: Understand the topic

If `$ARGUMENTS` is provided, use it as the starting topic. Otherwise ask: "What would you like to think through?"

Before diving in, understand what the user is dealing with:
- What's the problem or question?
- What have they already considered?
- What constraints or context should be factored in?
- What would a good outcome look like?

Ask clarifying questions. Don't jump to solutions. The first goal is to help the user articulate the full shape of the problem.

## Step 2: Guided conversation

Work through the topic with the user. Adapt your approach to the type of problem:

**For technical decisions:**
- What are the options?
- What are the tradeoffs for each?
- What are the constraints (timeline, team, existing code)?
- What's reversible vs irreversible?
- What would you need to be true for each option to be the right choice?

**For feature ideas:**
- Who is this for?
- What problem does it solve?
- What's the minimal version?
- What are the edge cases?
- How does it interact with existing features?

**For architecture questions:**
- What are the current pain points?
- What does the system need to support in the near term?
- What are the scaling concerns?
- What patterns does the codebase already use?

**For debugging / investigation:**
- What's the observed behavior vs expected?
- What's been tried?
- What changed recently?
- Where does the data flow through?

**For process / workflow questions:**
- What's working today?
- What's not working?
- What would ideal look like?
- What's the smallest change that would help?

Throughout the conversation:
- Summarize key points periodically so nothing gets lost
- Challenge assumptions when appropriate
- Bring in codebase context by reading relevant files when it would help
- Flag when the conversation is converging on a clear direction

## Step 3: Identify the right artifact

As the conversation progresses, identify what artifact (if any) would capture the outcome. Options:

| Artifact type | When to use | Where it goes |
|---------------|-------------|---------------|
| **ADR** | Architecture or technology decision was made | `<basedir>/decisions/` |
| **Feature spec** | Feature was designed with enough detail to implement | `<basedir>/specs/` |
| **Todo items** | Actionable tasks were identified | `<basedir>/todos/` |
| **Tech debt items** | Technical improvements were identified | `<basedir>/tech-debt/` |
| **Bug report** | A bug was identified and characterized | `<basedir>/bugs/` |
| **Conversation note** | Useful discussion but no single artifact type fits | `<basedir>/notes/` |
| **No artifact** | Quick question answered, no need to persist | None |

Tell the user what you think the right artifact is and ask if they agree. They may want a different type or no artifact at all.

## Step 4: Produce the artifact

Based on the chosen type:

**ADR** — Follow the MADR template format. Read `~/.claude/skills/shared/config.md` for basedir. Scan `<basedir>/decisions/` for existing ADRs to auto-number. Write to `<basedir>/decisions/ADR-<NNNN>-<slug>.md`.

**Feature spec** — Use the feature-spec template structure. Write to `<basedir>/specs/<slug>.md`.

**Todo items** — Read `~/.claude/skills/shared/todo-format.md`. Create detail files and update the master list.

**Tech debt items** — Read `~/.claude/skills/shared/tech-debt-format.md`. Create detail files and update the master list.

**Bug report** — Use the bug-report template structure. Write to `<basedir>/bugs/<slug>-<YYYY-MM-DD>.md`.

**Conversation note** — Write a summary to `<basedir>/notes/<slug>-<YYYY-MM-DD>.md`:

```markdown
---
title: "<Topic>"
date: YYYY-MM-DD
type: think-through
tags:
  - note
  - think-through
---

# <Topic>

## Context

<What prompted this discussion>

## Key Points

<Bulleted summary of the most important points discussed>

## Decisions Made

<Any decisions or conclusions reached, with reasoning>

## Open Questions

<Anything left unresolved>

## Action Items

<Any next steps identified, with wikilinks to todos/tech-debt if created>
```

## Step 5: Present the result

Tell the user:
- What artifact was created and where
- A brief summary of the key conclusions
- Any follow-up actions suggested
- If todos or tech debt items were created, list them with IDs
