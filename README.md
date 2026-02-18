# PR Review Team

Multi-agent PR review system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Six specialist agents review code changes in parallel and produce a unified report with structured, actionable findings.

## Specialists

| Agent | Focus |
|-------|-------|
| Security | Vulnerabilities, injection risks, auth issues, secrets exposure |
| Architecture | Design decisions, coupling, module boundaries, API design |
| Style | Naming, readability, idioms, dead code, consistency |
| Performance | Algorithmic complexity, N+1 queries, memory leaks, caching |
| Error Handling | Failure modes, error propagation, retry logic, logging |
| Testing | Coverage, assertion quality, edge cases, test isolation |

## Usage

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Run from any project that includes this as a parent config, or from this directory:

```
/review-pr 123          # Full review of GitHub PR #123
/review-pr              # Full review of local diff (current branch vs main)
```

Run a single specialist:

```
/review-security 123
/review-architecture
/review-style 42
/review-performance
/review-errors 99
/review-testing
```

## Output

Findings use three severity levels: **CRITICAL** (must fix), **WARNING** (should fix), **INFO** (suggestion). The orchestrator synthesizes all specialist findings into a single report with a final verdict: APPROVE, REQUEST CHANGES, or COMMENT.

Results are saved to `reviews/` for persistence across context resets.

## Project Structure

```
agents/                 Domain expertise (review checklists, severity criteria)
.claude/agents/         Subagent definitions (tools, model, system prompt)
.claude/commands/       Slash commands (diff fetching, agent orchestration)
reviews/                Review output (gitignored)
```

## Adding a Specialist

1. Create `agents/<domain>.md` with role, checklist, severity criteria, and output format
2. Create `.claude/agents/review-<domain>.md` with frontmatter and system prompt
3. Create `.claude/commands/review-<domain>.md` for the slash command
4. Add the specialist to `.claude/commands/review-pr.md`
