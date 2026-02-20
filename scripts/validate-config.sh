#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

errors=0

assert_contains() {
  local file="$1"
  local needle="$2"
  if ! rg -q --fixed-strings "$needle" "$file"; then
    printf 'ERROR: %s is missing: %s\n' "$file" "$needle"
    errors=$((errors + 1))
  fi
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  if rg -q --fixed-strings "$needle" "$file"; then
    printf 'ERROR: %s still contains forbidden text: %s\n' "$file" "$needle"
    errors=$((errors + 1))
  fi
}

for file in .claude/commands/review-pr.md .claude/commands/review-security.md .claude/commands/review-architecture.md .claude/commands/review-style.md .claude/commands/review-performance.md .claude/commands/review-errors.md .claude/commands/review-testing.md; do
  assert_contains "$file" 'git diff origin/master...HEAD'
  assert_contains "$file" 'git diff ${BASE_REF}...HEAD --name-only'
  assert_contains "$file" 'git log ${BASE_REF}..HEAD --oneline'
  assert_contains "$file" 'supported base branch was found (`main`, `master`, `origin/main`, `origin/master`)'
  assert_not_contains "$file" 'git log main..HEAD'
  assert_not_contains "$file" 'git diff main...HEAD --name-only'
done

assert_contains ".claude/settings.local.json" '"Bash(date:*)"'
assert_not_contains "README.md" 'current branch vs main'
assert_not_contains "CLAUDE.md" 'current branch vs main'
assert_contains ".claude/commands/review-pr.md" '## Step 3.5: Run tech lead meta-review'
assert_contains ".claude/commands/review-pr.md" 'subagent_type: "review-tech-lead"'
assert_contains "README.md" '/review-tech-lead'
assert_contains "CLAUDE.md" '/review-tech-lead'

for file in agents/tech-lead.md .claude/agents/review-tech-lead.md .claude/commands/review-tech-lead.md; do
  if [[ ! -f "$file" ]]; then
    printf 'ERROR: missing required file: %s\n' "$file"
    errors=$((errors + 1))
  fi
done

reviews_count="$(rg -n '^reviews/$' .gitignore | wc -l | tr -d ' ')"
if [[ "$reviews_count" -ne 1 ]]; then
  printf 'ERROR: .gitignore should contain exactly one reviews/ entry, found %s\n' "$reviews_count"
  errors=$((errors + 1))
fi

if [[ "$errors" -ne 0 ]]; then
  printf '\nValidation failed with %s error(s).\n' "$errors"
  exit 1
fi

printf 'Config validation passed.\n'
