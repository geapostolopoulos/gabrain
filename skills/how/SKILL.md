---
name: how
description: "Explain how something works in a codebase. Use for \"how does X work\", tracing runtime flow, and code walkthroughs before changing something. Produces an architectural mental model, not annotated source."
disable-model-invocation: true
---

# How

Explain how part of a codebase works, at the depth a senior engineer needs to start working in it: a mental model, not narrated source code. If the scope is ambiguous, state your interpretation and proceed.

## Workflow

Follow exactly one path, in order. Never skip or merge phases.

- `LOAD -> CLASSIFY -> DIRECT -> PRESENT`
- `LOAD -> CLASSIFY -> DELEGATE -> WAIT -> SYNTHESIZE -> PRESENT`

## 1. LOAD

Read `references/explorer-prompt.md` and `references/synthesizer-prompt.md`.

## 2. CLASSIFY

Use at most 6 search or read calls to find the entry point and gauge scope. Choose **DELEGATE** if any condition is true, otherwise **DIRECT**:

1. The question asks about a subsystem, architecture, end-to-end flow, or cross-cutting behavior.
2. Relevant code spans 3 or more modules, packages, services, or top-level directories.
3. The answer needs 2 or more independent traces.
4. Six calls did not reveal a complete, narrow path.

Stop exploring once you choose.

## 3A. DIRECT

Trace it yourself with the Method section of the explorer template, capped at 10 search or read calls in total, including CLASSIFY. If you reach the cap, or any CLASSIFY condition becomes true mid-trace, switch to DELEGATE and give the explorers every file and symbol you already found.

Otherwise write the answer with the Output format and Communication style of the synthesizer template, then PRESENT.

## 3B. DELEGATE

Pick 2 to 4 of these angles, in this order, keeping only those that apply:

1. Entry point and caller or UI trigger.
2. Core state, rules, and transformations.
3. Persistence, integrations, and side effects.
4. Output, rendering, or downstream consumers.

No two angles may share a primary responsibility. Put known files and symbols in the angle they belong to.

Dispatch all explorers in one response, one `task` call each:

- `agent_type`: `explore`
- `mode`: `background`
- `name`: short angle name
- `description`: the angle, 3 to 5 words
- `prompt`: the explorer template text below its `---` line, copied word for word, with `{QUESTION}` and `{EXPLORATION_ANGLE}` replaced. Append known files and symbols after it, never in place of it.

Before dispatching, confirm each prompt contains `Find the entry point`, `### Components found`, and `### Open questions`. Do not set `model`.

## 4. WAIT

Call only `read_agent`, with `wait: true`, until every explorer reports. If one fails, note it; do not explore in its place.

## 5. SYNTHESIZE

Dispatch one `task` call:

- `agent_type`: `general-purpose`
- `mode`: `sync`
- `name`: `synthesizer`
- `description`: `Synthesize walkthrough`
- `prompt`: the synthesizer template text below its `---` line, copied word for word, with `{QUESTION}` replaced and `{EXPLORER_FINDINGS}` replaced by every explorer response verbatim, failures included.

Before dispatching, confirm the prompt contains `## Instructions`, `## Output format`, and `## Communication style`. Do not set `model`.

## 6. PRESENT

Return the explanation. Keep every open question and gap; never fill one with a guess. Do not write it to a file unless asked.