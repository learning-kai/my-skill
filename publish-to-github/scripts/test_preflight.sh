#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFLIGHT="$SCRIPT_DIR/preflight.sh"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/publish-to-github-preflight-test.XXXXXX")"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

create_fixture_repo() {
  local name="$1"
  local kind="$2"
  local repo="$TEMP_ROOT/$name"

  mkdir -p "$repo"
  (
    cd "$repo"
    git init >/dev/null
    git config user.email "test@example.com"
    git config user.name "Preflight Test"

    printf '*.log\n.env\n' > .gitignore
    printf '# %s\n\nEnglish readme.\n' "$name" > README.md
    printf '# %s\n\n中文说明。\n' "$name" > README.zh-CN.md
    printf 'MIT\n' > LICENSE

    if [[ "$kind" == "skill" ]]; then
      printf -- '---\nname: %s\ndescription: Publish test skill.\n---\n\n# %s\n' "$name" "$name" > SKILL.md
    else
      printf '{"scripts":{"test":"echo test","build":"echo build"}}\n' > package.json
    fi

    git add .
    git commit -m "fixture" >/dev/null
  )

  printf '%s\n' "$repo"
}

assert_contains() {
  local text="$1"
  local needle="$2"
  if [[ "$text" != *"$needle"* ]]; then
    printf 'Expected output to contain %s. Output:\n%s\n' "$needle" "$text" >&2
    exit 1
  fi
}

project_repo="$(create_fixture_repo sample-project project)"
project_output="$(bash "$PREFLIGHT" --repo-root "$project_repo" --mode project --project-name . 2>&1)"
assert_contains "$project_output" "== Target Project =="
assert_contains "$project_output" "Mode: project"
assert_contains "$project_output" "[OK] README.md exists"
assert_contains "$project_output" "[OK] README.zh-CN.md exists"
assert_contains "$project_output" "npm test"
assert_contains "$project_output" "npm run build"

skill_repo="$(create_fixture_repo sample-skill skill)"
skill_output="$(bash "$PREFLIGHT" --repo-root "$skill_repo" --mode auto --project-name . 2>&1)"
assert_contains "$skill_output" "Mode: skill"
assert_contains "$skill_output" "[OK] SKILL.md frontmatter: name=sample-skill"
assert_contains "$skill_output" "[OK] README.md exists"
assert_contains "$skill_output" "[OK] README.zh-CN.md exists"

rm "$skill_repo/README.zh-CN.md"
missing_output="$(bash "$PREFLIGHT" --repo-root "$skill_repo" --mode skill --project-name . 2>&1 || true)"
assert_contains "$missing_output" "README.zh-CN.md is missing"

printf 'preflight tests passed\n'
