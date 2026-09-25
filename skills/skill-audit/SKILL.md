---
name: skill-audit
description: "Audit whether skills were used properly in a Copilot session: invoked when needed, followed, effective, and cost-efficient. Pass a session ID, or no argument to audit the current session."
disable-model-invocation: true
---

# Skill audit

Read-only. No subagents. Do not edit any file.

## 1. Get the digest

Session ID: the one the user gave. With no argument, use the current session: the `<id>` in your session folder path `session-state/<id>`.

Run `scripts/digest.ps1` from this skill's folder:

`& "<this skill folder>\scripts\digest.ps1" -SessionId <id>`

It prints the main-agent timeline with numbered tool calls, subagent costs, each invoked skill exactly as it ran, the reference files it read, and the final answer. Subagent tool calls are already excluded from the timeline; never count them as the main agent's.

To see one call's full arguments, such as a subagent prompt, rerun with `-Show <n>`.

If the script fails, reply `**Skills:** audit inconclusive — <reason>.` and stop.

## 2. Judge

Judge against the skill text in the digest, not the file on disk. The skill may have changed since.

For each invoked skill:

- **Followed**: required steps happened, in order, with the required tools and prompts.
- **Effective**: the final answer delivers what the skill promises.
- **Cost-efficient**: no large duplicated work, and no delegation clearly out of proportion to the question.

Also check for a skill that was needed but not invoked: only when a user message plainly matches a skill in your available skills list.

**Severe** means the outcome was wrong, unsupported, or incomplete, or the cost was clearly disproportionate. **Not severe**: bent or skipped steps that still produced a correct answer at reasonable cost, a sensible cheaper path, cosmetic differences. When unsure, it is not severe.

## 3. Report

Reply with one short message and nothing else.

No severe issue: `**Skills:** <skill-a> ✅, <skill-b> ✅`, listing every invoked skill by its real name — or `**Skills:** none ✅` when none were invoked or needed. Stop there.

Severe issue, for each affected skill:

`**Skills:** <skill> ⚠️ — <what went wrong, one sentence, citing call numbers or counts>.`
`**Fix:** <skill file> — <the specific change, one or two sentences>.`

Propose only a fix that would have prevented this failure. Do not apply it.
