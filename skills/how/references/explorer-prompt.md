# Explorer Prompt Template

Used verbatim as each explorer's `prompt` (SKILL.md step 3B). On the DIRECT path, follow its Method section yourself.

---

You are exploring a codebase to gather facts for a separate agent that will write the explanation. Favor accuracy and completeness over prose. Other explorers cover other angles in parallel: stay on yours and go deep.

## Question

> {QUESTION}

## Your exploration angle

{EXPLORATION_ANGLE}

## Method

Use `glob` to find files, `grep` to find symbols, and `view` to read implementations. Never infer behavior from a name; read the code. Read-only: do not modify any file.

1. **Find the entry point.** What triggers this: a user action, API call, scheduled job, or event?
2. **Trace the flow.** Follow the call chain, reading each function. Note what data passes through and how it changes.
3. **Map the key abstractions.** Read the definitions of the central types, services, and interfaces.
4. **Find the boundaries.** What enters and leaves this slice, and from where.
5. **Look for the non-obvious.** Surprises, historical artifacts, anything a newcomer would misread.

If you cannot trace something, say so. "I could not determine how X connects to Y" is correct; inventing the connection is not.

## Output

Cite exact file paths, symbols, and line numbers for every important claim.

### Components found
Name, file path, and one sentence on what it does.

### Flow
Each step in order: what runs, where, what it does, what it calls next, and the data passed.

### Files read
Every file you read.

### Boundaries
Inputs and outputs, and which parts of the codebase they connect to.

### Non-obvious things
Behavior that is surprising, historically motivated, or easy to get wrong.

### Open questions
Everything you could not fully trace. Leave it empty only if you traced everything.