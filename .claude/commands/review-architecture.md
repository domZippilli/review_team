You are running a focused **architecture** review.

## Step 1: Obtain the diff

Determine the review target from: $ARGUMENTS

**If the argument is a number** (GitHub PR):
```
gh pr diff <number>
gh pr diff <number> --name-only
gh pr view <number> --json title,body,baseRefName,headRefName
```

**If the argument is empty or not a number** (local diff):
Try in order: `git diff main...HEAD`, `git diff master...HEAD`, `git diff origin/main...HEAD`, `git diff origin/master...HEAD`
Save the successful base ref as `BASE_REF` (`main`, `master`, `origin/main`, or `origin/master`), then run:
`git diff ${BASE_REF}...HEAD --name-only` and `git log ${BASE_REF}..HEAD --oneline`
If none succeed, inform the user that no supported base branch was found (`main`, `master`, `origin/main`, `origin/master`) and stop.

If the diff is empty, inform the user and stop.

**Create the review output directory:**
- If the argument is a PR number: review ID is `pr-<number>`
- Otherwise: review ID is `local-<YYYY-MM-DD-HHMMSS>` using the current timestamp
- Run: `mkdir -p reviews/<review-id>`

## Step 2: Review

Use the `review-architecture` agent (via the Task tool with `subagent_type: "review-architecture"`) to perform the review. In the prompt, include:
- The full diff, changed file list, and any PR context
- Instruction to follow its expertise file
- **The output file path**: `Write your findings to: reviews/<review-id>/architecture.md`

The agent will write its findings directly to disk.

## Step 3: Present findings

Read the findings from `reviews/<review-id>/architecture.md` and present them to the user. Group by severity (CRITICAL first, then WARNING, then INFO).

Tell the user: **"Review saved to `reviews/<review-id>/architecture.md`"**
