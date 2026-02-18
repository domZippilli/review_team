# PR Review Team

Multi-agent PR review system for Claude Code. Six specialist agents review code changes in parallel and produce structured, actionable findings.

## Usage

From any project that includes this as a parent config, or from this directory:

```
/review-pr 123          # Review GitHub PR #123 with all 6 specialists
/review-pr              # Review local diff (current branch vs main) with all 6 specialists
/review-security 123    # Security review only
/review-architecture    # Architecture review of local diff
/review-style 42        # Code style review of PR #42
/review-performance     # Performance review of local diff
/review-errors 99       # Error handling review of PR #99
/review-testing         # Testing review of local diff
```

## Architecture

```
agents/                     Domain expertise (review checklists, severity criteria)
  security.md
  architecture.md
  style.md
  performance.md
  error-handling.md
  testing.md
.claude/agents/             Subagent definitions (tool access, model, system prompt)
  review-security.md
  review-architecture.md
  review-style.md
  review-performance.md
  review-errors.md
  review-testing.md
.claude/commands/           Slash commands (diff fetching, agent invocation, output)
  review-pr.md              Orchestrator -- fans out to all 6 in parallel
  review-security.md        Individual specialist commands
  review-architecture.md
  review-style.md
  review-performance.md
  review-errors.md
  review-testing.md
```

**Three layers, separated by concern:**
- `agents/*.md` -- Pure domain knowledge. Edit these to refine what each specialist checks.
- `.claude/agents/*.md` -- Claude Code integration. Controls tools, model, and system prompt per specialist.
- `.claude/commands/*.md` -- User-facing commands. Handles diff fetching and output formatting.

## Adding a New Specialist

1. Create `agents/<domain>.md` following the structure of existing expertise files (Role, Checklist, Severity Classification, Output Format)
2. Create `.claude/agents/review-<domain>.md` with YAML frontmatter (name, description, tools, model) and a system prompt that references the expertise file
3. Create `.claude/commands/review-<domain>.md` following the pattern of existing individual commands
4. Add the new specialist to the orchestrator in `.claude/commands/review-pr.md` (Step 2)

## Output Format

All specialists produce findings in a consistent format:
- **Severity**: CRITICAL (must fix) | WARNING (should fix) | INFO (suggestion)
- **File**: path:line_number
- **Finding**: one-line description
- **Evidence**: code snippet
- **Recommendation**: specific fix with code
- **Rationale**: why it matters

The orchestrator (`/review-pr`) synthesizes all findings into a unified report grouped by severity, then by file, with a final verdict: APPROVE, REQUEST CHANGES, or COMMENT.

## Review Persistence

All review outputs are saved to `reviews/` (gitignored). Each review gets its own directory:

- `reviews/pr-123/` for GitHub PR reviews
- `reviews/local-2026-02-10-143022/` for local diff reviews

Contents:
- `security.md`, `architecture.md`, `style.md`, `performance.md`, `error-handling.md`, `testing.md` -- individual specialist findings
- `report.md` -- synthesized report (orchestrator only)

This ensures results survive context resets. If a review is interrupted, check `reviews/` for partial results.
