# PR Review Team

Multi-agent PR review system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Six specialist agents review code changes in parallel, then a tech lead agent reviews the reviews and produces final merge guidance.

## Specialists

| Agent | Focus |
|-------|-------|
| Security | Vulnerabilities, injection risks, auth issues, secrets exposure |
| Architecture | Design decisions, coupling, module boundaries, API design |
| Style | Naming, readability, idioms, dead code, consistency |
| Performance | Algorithmic complexity, N+1 queries, memory leaks, caching |
| Error Handling | Failure modes, error propagation, retry logic, logging |
| Testing | Coverage, assertion quality, edge cases, test isolation |
| Tech Lead | Reviews specialist findings for quality, consistency, blind spots, and final recommendation |

## Usage

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Run from any project that includes this as a parent config, or from this directory:

```
/review-pr 123          # Full review of GitHub PR #123
/review-pr              # Full review of local diff (current branch vs default base branch)
/review-tech-lead pr-123
```

Run a single specialist:

```
/review-security 123
/review-architecture
/review-style 42
/review-performance
/review-errors 99
/review-testing
/review-tech-lead pr-123
```

## Output

Findings use three severity levels: **CRITICAL** (must fix), **WARNING** (should fix), **INFO** (suggestion). The orchestrator synthesizes specialist findings and the tech lead meta-review into a single report with a final verdict: APPROVE, REQUEST CHANGES, or COMMENT.

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
