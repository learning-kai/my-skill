#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFLIGHT="$SCRIPT_DIR/preflight.sh"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/publish-to-github-preflight-test.XXXXXX")"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

readme_content() {
  local name="$1"
  local language="$2"
  local language_line intro why features screenshots quick_start install usage quality docs privacy release roadmap contributing troubleshooting

  if [[ "$language" == "zh" ]]; then
    language_line='[English](README.md) | 简体中文'
    intro='用于验证发布准备度的测试项目。'
    why='为什么做'
    features='核心特性'
    screenshots='截图与演示'
    quick_start='快速开始'
    install='安装'
    usage='使用'
    quality='工程质量'
    docs='项目文档'
    privacy='隐私与安全边界'
    release='发布与更新'
    roadmap='路线图'
    contributing='贡献'
    troubleshooting='故障排查'
  else
    language_line='English | [简体中文](README.zh-CN.md)'
    intro='A test project used to verify publish readiness.'
    why='Why'
    features='Core Features'
    screenshots='Screenshots & Demo'
    quick_start='Quick Start'
    install='Installation'
    usage='Usage'
    quality='Engineering Quality'
    docs='Project Docs'
    privacy='Privacy & Security'
    release='Release & Updates'
    roadmap='Roadmap'
    contributing='Contributing'
    troubleshooting='Troubleshooting'
  fi

  cat <<EOF
# $name

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/example/$name)](https://github.com/example/$name/releases/latest)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![Bash](https://img.shields.io/badge/shell-Bash-4EAA25)

$language_line

$intro

## $why

This fixture exists to verify README quality gates.

## $features

- Bilingual README checks.
- Release install checks.
- Badge checks.

## $screenshots

Command-line and skill fixtures use command output instead of screenshots.

## $quick_start

Run the preflight script.

## $install

\`\`\`bash
curl -fsSL https://github.com/example/$name/releases/latest/download/install.sh | bash
\`\`\`

\`\`\`powershell
irm https://github.com/example/$name/releases/latest/download/install.ps1 | iex
\`\`\`

## $usage

Run the tool.

## $quality

The fixture exposes deterministic sections for preflight tests.

## $docs

Read the README pair.

## $privacy

Do not publish secrets.

## $release

Follow the release flow and attach install assets.

## $roadmap

- Keep the fixture aligned with README gates.

## $contributing

Keep tests focused and readable.

## $troubleshooting

Check authentication and paths.

## License

MIT.
EOF
}

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
    readme_content "$name" en > README.md
    readme_content "$name" zh > README.zh-CN.md
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
assert_contains "$project_output" "[OK] README.md has 3+ top badges"
assert_contains "$project_output" "[OK] README.md has a License badge"
assert_contains "$project_output" "[OK] README.md has a release/version badge"
assert_contains "$project_output" "[OK] README.md has a platform/tech badge"
assert_contains "$project_output" "[OK] README.zh-CN.md has 3+ top badges"
assert_contains "$project_output" "[OK] README.md links to README.zh-CN.md"
assert_contains "$project_output" "[OK] README.zh-CN.md links back to README.md"
assert_contains "$project_output" "[OK] README.md has Why section"
assert_contains "$project_output" "[OK] README.md has Core Features section"
assert_contains "$project_output" "[OK] README.md has Screenshots & Demo section"
assert_contains "$project_output" "[OK] README.md has Engineering Quality section"
assert_contains "$project_output" "[OK] README.md has Release & Updates section"
assert_contains "$project_output" "[OK] README.zh-CN.md has 为什么做 section"
assert_contains "$project_output" "[OK] README.zh-CN.md has 核心特性 section"
assert_contains "$project_output" "[OK] README.zh-CN.md has 截图与演示 section"
assert_contains "$project_output" "[OK] README.zh-CN.md has 工程质量 section"
assert_contains "$project_output" "[OK] README.zh-CN.md has 发布与更新 section"
assert_contains "$project_output" "npm test"
assert_contains "$project_output" "npm run build"

skill_repo="$(create_fixture_repo sample-skill skill)"
skill_output="$(bash "$PREFLIGHT" --repo-root "$skill_repo" --mode auto --project-name . 2>&1)"
assert_contains "$skill_output" "Mode: skill"
assert_contains "$skill_output" "[OK] SKILL.md frontmatter: name=sample-skill"
assert_contains "$skill_output" "[OK] README.md exists"
assert_contains "$skill_output" "[OK] README.zh-CN.md exists"
assert_contains "$skill_output" "[OK] README.md has 3+ top badges"
assert_contains "$skill_output" "[OK] README.md has a License badge"
assert_contains "$skill_output" "[OK] README.md has a release/version badge"
assert_contains "$skill_output" "[OK] README.md has a platform/tech badge"
assert_contains "$skill_output" "[OK] README.md has Troubleshooting section"
assert_contains "$skill_output" "[OK] README.zh-CN.md has 故障排查 section"
assert_contains "$skill_output" "[OK] README.md has Project Docs section"
assert_contains "$skill_output" "[OK] README.md has Privacy & Security section"
assert_contains "$skill_output" "[OK] README.md has Roadmap section"
assert_contains "$skill_output" "[OK] README.md has Contributing section"
assert_contains "$skill_output" "[OK] README.zh-CN.md has 项目文档 section"
assert_contains "$skill_output" "[OK] README.zh-CN.md has 隐私与安全边界 section"
assert_contains "$skill_output" "[OK] README.zh-CN.md has 路线图 section"
assert_contains "$skill_output" "[OK] README.zh-CN.md has 贡献 section"

rm "$skill_repo/README.zh-CN.md"
missing_output="$(bash "$PREFLIGHT" --repo-root "$skill_repo" --mode skill --project-name . 2>&1 || true)"
assert_contains "$missing_output" "README.zh-CN.md is missing"

printf 'preflight tests passed\n'
