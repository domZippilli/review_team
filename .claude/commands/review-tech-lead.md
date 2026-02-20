You are running a focused **tech lead meta-review**.

This command reviews previously generated specialist review artifacts and audits their quality and consistency.

## Step 1: Determine target review directory

Determine the review target from: $ARGUMENTS

- If the argument matches a review ID (for example `pr-123` or `local-2026-02-10-143022`), use `reviews/<review-id>/`.
- If the argument is a number, use `reviews/pr-<number>/`.
- If the argument is empty, run `ls reviews` and ask the user to re-run with a specific review ID.

If the target directory does not exist, inform the user and stop.

## Step 2: Collect specialist artifacts

Read these files if present:

- `reviews/<review-id>/security.md`
- `reviews/<review-id>/architecture.md`
- `reviews/<review-id>/style.md`
- `reviews/<review-id>/performance.md`
- `reviews/<review-id>/error-handling.md`
- `reviews/<review-id>/testing.md`
- `reviews/<review-id>/report.md` (optional context)

Track any missing specialist files and include that in the meta-review prompt.

If none of the six specialist files exist, inform the user and stop.

## Step 3: Run the tech lead reviewer

Use the `review-tech-lead` agent (via the Task tool with `subagent_type: "review-tech-lead"`). In the prompt, include:

- The review ID and target directory
- The contents of all available specialist files
- The list of missing specialist files (if any)
- Instruction to follow its expertise file
- **The output file path**: `Write your findings to: reviews/<review-id>/tech-lead.md`

The agent will write findings directly to disk.

## Step 4: Present findings

Read `reviews/<review-id>/tech-lead.md` and present findings grouped by severity (CRITICAL first, then WARNING, then INFO). Include the final recommendation and confidence.

Tell the user: **"Review saved to `reviews/<review-id>/tech-lead.md`"**
