#!/usr/bin/env bash

# Automated Repository Checks
# This script mechanically enforces systemic invariants across repositories.
# It should be run before committing or opening a PR.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

if [ "$#" -gt 1 ]; then
    echo "Usage: $0 [git-diff-range]" >&2
    exit 2
fi

DIFF_SCOPE=(--cached)
if [ "$#" -eq 1 ]; then
    DIFF_SCOPE=("$1")
fi

echo "Checking automated repository rules..."

# Check 1: No merge conflict markers
if git diff "${DIFF_SCOPE[@]}" --check | grep -q 'leftover conflict marker'; then
    echo -e "${RED}✗ Merge conflict markers found in changed files${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No merge conflict markers${NC}"
fi

# Check 2: No 'console.log' in production code (JS/TS only, excluding tests)
CHANGED_SRC=$(git diff "${DIFF_SCOPE[@]}" --name-only --diff-filter=ACMR \
  -- "*.js" "*.ts" "*.tsx" "*.jsx" \
  | grep -v -E "(test|spec|story)" || true)

HAS_CONSOLE_LOG=false
if [ -n "$CHANGED_SRC" ]; then
    while IFS= read -r file; do
        if grep -q 'console\.log' "$file"; then
            HAS_CONSOLE_LOG=true
            break
        fi
    done <<< "$CHANGED_SRC"
fi

if [ "$HAS_CONSOLE_LOG" = true ]; then
    echo -e "${RED}✗ console.log found in changed source files${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No console.log in changed source files${NC}"
fi

if [ $ERRORS -gt 0 ]; then
    echo -e "\n${RED}Failed $ERRORS automated repository rule(s). Please fix before proceeding.${NC}"
    exit 1
fi

echo -e "\n${GREEN}All automated repository rules passed!${NC}"
exit 0
