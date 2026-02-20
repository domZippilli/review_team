You are the PR Review Orchestrator. Your job is to coordinate 6 specialist review agents, run a tech lead meta-review, and synthesize everything into a single actionable report.

## Step 1: Obtain the diff

Determine the review target from the argument: $ARGUMENTS

**If the argument is a number** (GitHub PR):
```
gh pr diff <number>
gh pr diff <number> --name-only
gh pr view <number> --json title,body,baseRefName,headRefName
```

**If the argument is empty or not a number** (local diff):
Try these in order until one succeeds:
```
git diff main...HEAD
git diff master...HEAD
git diff origin/main...HEAD
git diff origin/master...HEAD
```
Save the successful base ref as `BASE_REF` (`main`, `master`, `origin/main`, or `origin/master`).
And for context:
```
git diff ${BASE_REF}...HEAD --name-only
git log ${BASE_REF}..HEAD --oneline
```
If none of the local diff commands succeed, inform the user that no supported base branch was found (`main`, `master`, `origin/main`, `origin/master`) and stop.

Store the full diff text, the list of changed files, and any PR context (title, description). If the diff is empty, inform the user and stop.

## Step 1.5: Create the review output directory

Determine a review ID:
- If reviewing a GitHub PR: `pr-<number>` (e.g., `pr-123`)
- If reviewing a local diff: `local-<YYYY-MM-DD-HHMMSS>` using the current timestamp

Run: `mkdir -p reviews/<review-id>`

This directory will store all review artifacts so they survive context resets.

## Step 2: Spawn 6 specialist reviews in parallel

Use the Task tool to spawn 6 agents **in a single message** so they run concurrently. For each agent, set `run_in_background: true`.

For each specialist, use these subagent_types and include the full diff + changed file list + any PR context in the prompt:

1. `review-security` -- Security review
2. `review-architecture` -- Architecture review
3. `review-style` -- Code style review
4. `review-performance` -- Performance review
5. `review-errors` -- Error handling review
6. `review-testing` -- Testing review

Each agent's prompt should include:
- The full diff text
- The list of changed files
- PR title and description (if GitHub PR)
- Instruction: "Perform your specialist review. Follow the checklist and output format from your expertise file."
- **The output file path** for each specialist, e.g.: `Write your findings to: reviews/<review-id>/security.md`

Each agent writes its own findings to disk. This ensures results persist even if the orchestrator's context is interrupted.

## Step 3: Collect results from disk

Wait for all 6 agents to complete by reading their output files. Then read the findings from each file:

- `reviews/<review-id>/security.md`
- `reviews/<review-id>/architecture.md`
- `reviews/<review-id>/style.md`
- `reviews/<review-id>/performance.md`
- `reviews/<review-id>/error-handling.md`
- `reviews/<review-id>/testing.md`

If any file is missing (agent failed or timed out), note it and continue with the results you have.

## Step 3.5: Run tech lead meta-review

Use the Task tool with `subagent_type: "review-tech-lead"` to review the specialist outputs you collected.

Prompt requirements:
- Include the review target details (PR/local diff, title/description if available)
- Include the changed file list and diff context summary
- Include the full text of each available specialist output file
- Include an explicit list of missing specialist files (if any)
- Instruction: "Review these specialist findings for quality, consistency, coverage, and final merge recommendation."
- **Output file path**: `Write your findings to: reviews/<review-id>/tech-lead.md`

Then read `reviews/<review-id>/tech-lead.md`. If the file is missing (agent failed or timed out), note it and continue.

## Step 4: Synthesize the unified report

Compile a single report with this structure:

---

# PR Review Report

## Summary

| Metric | Value |
|--------|-------|
| Target | PR #N "title" / local diff (branch) |
| Files reviewed | N |
| Critical findings | N |
| Warnings | N |
| Suggestions | N |
| Tech lead recommendation | APPROVE / REQUEST CHANGES / COMMENT / N/A |
| Tech lead confidence | HIGH / MEDIUM / LOW / N/A |

## Critical Findings

_All CRITICAL items from all specialists, grouped by file path._

For each finding, prefix with the specialist domain in brackets: **[Security]**, **[Architecture]**, **[Style]**, **[Performance]**, **[Error Handling]**, **[Testing]**, **[Tech Lead]**.

## Warnings

_All WARNING items from all specialists, grouped by file path._

## Suggestions

_All INFO items from all specialists, grouped by file path._

## Specialist Summaries

For each specialist, include their overall assessment paragraph (2-3 sentences).

## Tech Lead Meta-Review

Include:
- Top meta-findings (quality gaps, contradictions, or blind spots)
- Final recommendation and confidence from `tech-lead.md`
- Any escalations the orchestrator applies based on meta-review

## Verdict

Based on findings:
- **APPROVE** -- No critical findings, few or no warnings. Safe to merge.
- **REQUEST CHANGES** -- Critical findings that must be addressed before merge.
- **COMMENT** -- No critical findings but notable warnings worth discussing.

If tech lead recommendation conflicts with your initial verdict, explain why and resolve the conflict explicitly.

---

If any specialist agent fails or times out, note it in the report and continue with the results you have.

## Step 5: Save the report

Write the synthesized report to `reviews/<review-id>/report.md`.

Tell the user: **"Review saved to `reviews/<review-id>/`"** so they know where to find it if context is lost.
