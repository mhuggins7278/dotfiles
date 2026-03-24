#!/usr/bin/env bash

# Golden Principles Checker
# This script mechanically enforces systemic invariants across repositories.
# It should be run before committing or opening a PR.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

echo "🔍 Checking Golden Principles..."

# Principle 1: No merge conflict markers
if git diff --cached -S '<<<<<<<' --name-only | grep -q .; then
    echo -e "${RED}✗ Merge conflict markers found in staged files${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No merge conflict markers${NC}"
fi

# Principle 2: No 'console.log' in production code (JS/TS only, excluding tests)
STAGED_SRC=$(git diff --cached --name-only -- "*.js" "*.ts" "*.tsx" "*.jsx" \
  | grep -v -E "(test|spec|story)" || true)
if [ -n "$STAGED_SRC" ] && echo "$STAGED_SRC" | xargs grep -q 'console\.log' 2>/dev/null; then
    echo -e "${RED}✗ console.log found in staged source files${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No console.log in staged source files${NC}"
fi

# Principle 3: TS Strict Mode
if [ -f "tsconfig.json" ]; then
    if grep -q '"strict":\s*true' tsconfig.json; then
        echo -e "${GREEN}✓ TypeScript strict mode enabled${NC}"
    else
        echo -e "${RED}✗ TypeScript strict mode is missing or disabled in tsconfig.json${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

if [ $ERRORS -gt 0 ]; then
    echo -e "\n${RED}Failed $ERRORS Golden Principle(s). Please fix before proceeding.${NC}"
    exit 1
fi

echo -e "\n${GREEN}All Golden Principles passed!${NC}"
exit 0