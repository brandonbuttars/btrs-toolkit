---
name: btrs-capture
description: >
  Quickly capture context, knowledge, or a decision as a structured note.
  Lighter than think-through — for when you just need to write something down.
  Use when the user wants to capture a note, save context, write something
  down, or asks "capture this", "btrs capture", "note this down", "save this
  context", "write a note about", "jot this down", "record this".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Write, Grep, Glob
argument-hint: <topic or content>
---

# Capture Skill

Quickly capture context, knowledge, or decisions as a structured note.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Determine what to capture

If `$ARGUMENTS` is provided, use it as the content to capture. Otherwise ask: "What do you want to capture?"

Determine the note type based on content:

| Content | Type | Tag |
|---------|------|-----|
| A decision or conclusion | `decision` | note/decision |
| Research findings | `research` | note/research |
| Meeting notes or discussion summary | `meeting` | note/meeting |
| How-to or process documentation | `howto` | note/howto |
| General context or observation | `context` | note/context |
| Investigation or debugging session | `investigation` | note/investigation |

Ask the user for any additional context:
- What's the topic/title?
- Is there any related code, items, or ADRs to link?
- Any action items that came out of this?

## Step 2: Write the note

Write to `<basedir>/notes/<slug>-<YYYY-MM-DD>.md`:

The slug is derived from the title: lowercase, hyphens for spaces, stripped of special characters, max 50 chars.

If a file with that name exists, append a counter: `-2`, `-3`, etc.

```markdown
---
title: "<Title>"
date: YYYY-MM-DD
type: <note-type>
tags:
  - note
  - "note/<type>"
---

# <Title>

<The captured content, structured appropriately for the type:>

## Context
<Why this was worth capturing — what prompted it>

## Key Points
<Bulleted summary of the important information>

## Action Items
<Any next steps, with wikilinks to todos/tech-debt if applicable.
Omit if none.>

## Related
<Wikilinks to relevant files, ADRs, specs, or other notes.
Omit if none.>
```

Keep it concise. The value of capture is speed — don't over-structure or pad the content. If the user gave a few sentences, a few sentences is fine.

## Step 3: Extract action items

If the captured content includes action items or things that need doing:
- Offer to create todo items for each one
- If the user agrees, read `~/.claude/skills/shared/todo-format.md` and create them
- Link the todos back to this note

## Step 4: Present the result

Tell the user:
- Note file path
- Brief confirmation of what was captured
- Any action items created
- Suggest: "Find this note in Obsidian under `<basedir>/notes/`"
