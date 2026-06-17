#!/usr/bin/env bash
# preflight.sh — pre-publish checks for macOS and Linux
# Usage: bash preflight.sh <project-root>
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <project-root>" >&2
  exit 1
fi

PROJECT_ROOT="$1"
cd "$PROJECT_ROOT"

section() {
  echo ""
  echo "== $1 =="
}

section "Project"
echo "Root: $(pwd)"

section "GitHub CLI"
if command -v gh &>/dev/null; then
  gh --version | head -1
  gh auth status || echo "WARNING: GitHub CLI not authenticated. Run: gh auth login"
else
  echo "WARNING: GitHub CLI is missing. Install from https://cli.github.com/"
fi

section "Git"
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git status -sb
  echo ""
  git remote -v
else
  echo "WARNING: This directory is not a Git repository yet."
fi

section "Ignored generated files"
if [ -f ".gitignore" ]; then
  cat .gitignore
else
  echo "WARNING: .gitignore is missing. Add one before committing."
fi

section "Package scripts"
if [ -f "package.json" ]; then
  if command -v node &>/dev/null; then
    node -e "
      const p = require('./package.json');
      if (p.scripts && Object.keys(p.scripts).length > 0) {
        Object.entries(p.scripts).forEach(([k, v]) => console.log(k + ': ' + v));
      } else {
        console.log('WARNING: package.json has no scripts.');
      }
    "
  else
    echo "WARNING: node not found. Cannot parse package.json scripts."
  fi
else
  echo "WARNING: package.json not found."
fi

section "Large tracked candidates"
# List tracked and untracked (non-ignored) files larger than 5 MB
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git ls-files --others --cached --exclude-standard 2>/dev/null | while IFS= read -r f; do
    [ -f "$f" ] || continue
    # stat syntax differs between macOS (-f%z) and Linux (-c%s)
    size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo 0)
    if [ "$size" -gt 5242880 ]; then
      mb=$(awk "BEGIN { printf \"%.2f\", $size/1048576 }")
      echo "$f  ${mb} MB"
    fi
  done
fi

echo ""
echo "Preflight complete. Review warnings before publishing."
