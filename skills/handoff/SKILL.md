---
name: handoff
description: "Create a concise continuation brief for another agent or a future session. Use when pausing work, switching agents, or handing off an unfinished task."
disable-model-invocation: true
---

# Handoff

Create a continuation brief that lets another agent resume safely without rereading the entire session. Keep it factual, concise, and specific to the current workspace.

## Workflow

1. **Inspect**

Gather the current state before writing:

- Read the recent conversation and identify the user's actual goal.
- Inspect the files changed during this session.
- Check repository status and the current branch when version control is available.
- Review relevant test, build, or validation results already reported.
- Identify unfinished work, blockers, assumptions, and risky or destructive next steps.

Do not claim a command, test, file change, or decision unless it is supported by the session or by a tool result. If a check was not run, say so.

2. **Separate**

Classify facts into:

- **Done**: completed and verified work.
- **In progress**: work started but not complete.
- **Not done**: requested work that has not started.
- **Uncertain**: claims or state that need confirmation.

Distinguish workspace state from recommendations. Do not present suggested next steps as completed work.

3. **Write**

Use this exact format:

```markdown
# Handoff

## Goal
<one or two sentences describing the user's goal and the intended outcome>

## Done
- <completed change or verified result>

## Current state
- Workspace: <branch/repository status, or "Not a git repository">
- Changed files: <files and purpose, or "None identified">
- Validation: <tests/checks and results, or "Not run">

## In progress
- <unfinished work, or "None">

## Blockers and risks
- <blocker, uncertainty, or risk, or "None known">

## Next actions
1. <the safest, most useful next action>
2. <additional action if needed>
```

4. **Present**

Return only the handoff brief. Do not edit source files, commit changes, create a tracking document, or perform the next actions unless the user separately asks.

## Quality rules

- Prefer concrete paths, symbols, commands, error messages, and decisions over vague summaries.
- Mention uncommitted changes and generated or temporary files when relevant.
- Preserve the user's terminology and constraints.
- Keep the brief short enough to scan in under a minute.
- If the session is complete, say so explicitly and make the next actions verification or release steps.
