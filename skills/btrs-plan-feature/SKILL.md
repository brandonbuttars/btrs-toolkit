---
name: btrs-plan-feature
description: >
  Plan a feature through guided conversation. Produces a feature spec with
  requirements, scope, component breakdown, data model, and implementation
  plan, plus actionable todo items. Use when the user wants to plan a feature,
  spec out functionality, design a workflow, or asks "plan a feature",
  "btrs plan feature", "spec out user management", "let's plan the search",
  "how should we build this feature", "feature spec for".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <feature-name or description>
---

# Plan Feature Skill

Plan a feature through conversation and produce a spec with actionable todo items.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Understand the feature

If `$ARGUMENTS` is provided, use it as the starting point. Otherwise ask: "What feature do you want to plan?"

Work through these areas conversationally:

### Problem & motivation
- What problem does this solve?
- Who needs it? (user roles, personas)
- How urgent is it? What's driving the timeline?
- What happens if we don't build it?

### Requirements
- What must it do? (must-have)
- What would be nice? (nice-to-have)
- What is explicitly out of scope?
- Are there constraints (performance, compatibility, accessibility)?

### User stories
Help the user articulate 3-5 key user stories:
- "As a [role], I want to [action] so that [outcome]"
- Identify the happy path and key edge cases for each

## Step 2: Understand existing context

Read relevant codebase context:
- Check `<basedir>/tech-stack.md` for framework and patterns
- Search for existing code related to this feature
- Check `<basedir>/decisions/` for relevant ADRs
- Check `<basedir>/todos.md` and `<basedir>/tech-debt.md` for related items

Present what you find: "Here's what already exists that's relevant..."

## Step 3: Design the scope

### Component breakdown
Map the feature to components using Atomic Design:
- What new components are needed?
- What existing components can be reused?
- What existing components need modification?

### Data model
- What data entities are involved?
- New database tables/collections needed?
- Changes to existing schemas?
- API endpoints needed (new or modified)?

### Pages & routes
- What new pages/routes are needed?
- Changes to existing pages?
- Navigation changes?

### State management
- What new state is needed?
- Where does it live (component, page, global)?
- Real-time requirements?

## Step 4: Define the implementation plan

Break the feature into phases if it's large. For each phase:

### Task breakdown
Create an ordered list of implementation tasks:
1. Data model / schema changes
2. API endpoints
3. Core components
4. Page assembly
5. State management / data flow
6. Error handling & edge cases
7. Tests
8. Polish & accessibility

For each task, estimate effort (Small/Medium/Large) and identify dependencies.

### Risk assessment
- What's the hardest part?
- What might we discover during implementation that changes the plan?
- What are the integration risks?
- Are there performance concerns?

### Testing strategy
- Unit test coverage targets
- Integration test scenarios
- E2E test scenarios for critical paths

## Step 5: Write the feature spec

Write to `<basedir>/specs/<feature-slug>.md`:

```markdown
---
title: "Feature Spec: <Feature Name>"
date: YYYY-MM-DD
type: feature-spec
status: "planned"
priority: "<high | medium | low>"
effort: "<small | medium | large>"
tags:
  - spec
  - spec/feature
  - "priority/<level>"
---

# Feature Spec: <Feature Name>

## Overview

**Problem:** <what problem this solves>
**Users:** <who needs it>
**Priority:** <High/Medium/Low> — <reasoning>
**Estimated effort:** <Small/Medium/Large>

## Requirements

### Must have
- <requirement 1>
- <requirement 2>

### Nice to have
- <requirement>

### Out of scope
- <explicitly excluded>

## User Stories

1. **<Story title>** — As a <role>, I want to <action> so that <outcome>
   - Happy path: <description>
   - Edge cases: <list>

## Design

### Component breakdown

| Component | Level | Exists? | Changes needed |
|-----------|-------|---------|----------------|
| ... | atom | ✓ | none |
| ... | molecule | ✗ | create new |
| ... | organism | ✓ | add prop |

### Data model

<Schema changes, new entities, relationships>

### API endpoints

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | /api/... | ... | required |
| POST | /api/... | ... | required |

### Pages & routes

| Route | Purpose | New? |
|-------|---------|------|
| /... | ... | yes |

### State management

| State | Scope | Type | Purpose |
|-------|-------|------|---------|
| ... | page | reactive | ... |

## Implementation Plan

### Phase 1: <name>
1. <task> _(effort, depends on: nothing)_
2. <task> _(effort, depends on: #1)_

### Phase 2: <name> (if applicable)
...

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| ... | medium | high | ... |

## Testing Strategy

- **Unit:** <what to test>
- **Integration:** <what to test>
- **E2E:** <critical paths>

## Related

- <ADRs: [[ADR-0003]]>
- <Tech debt: [[0005]]>
- <Other specs: [[spec-name]]>

## Open Questions

- <unresolved items>
```

## Step 6: Create todo items

Read `~/.claude/skills/shared/todo-format.md`.

For each task in the implementation plan, create a todo item:
- Set source to `plan-feature/<feature-slug> (YYYY-MM-DD)`
- Set blocked_by relationships based on task dependencies
- Link to the feature spec in the Context section

## Step 7: Present the result

Tell the user:
- Spec file path
- Feature summary: scope, effort, phases
- Todo items created (list with IDs)
- Key risks and open questions
- Suggest: "Start implementing with `/btrs-implement <todo-id>` or design components with `/btrs-design-component`"
