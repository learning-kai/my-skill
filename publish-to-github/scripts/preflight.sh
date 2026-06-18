#!/usr/bin/env bash
# preflight.sh - read-only pre-publish checks for projects and skills.
# Usage:
#   ./scripts/preflight.sh --repo-root <path> --mode auto --project-name <path>
#   ./scripts/preflight.sh --repo-root <path> --mode skill --project-name <skill>
#   ./scripts/preflight.sh --repo-root <path> --mode project --project-name .
#   ./scripts/preflight.sh --repo-root <path> --all
#
# This script does NOT stage, commit, push, delete, rename, or move files.

set -euo pipefail

REPO_ROOT="."
PROJECT_NAME=""
SKILL_NAME=""
MODE="auto"
ALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root) REPO_ROOT="$2"; shift 2 ;;
    --project-name) PROJECT_NAME="$2"; shift 2 ;;
    --skill-name) SKILL_NAME="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --all) ALL=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

case "$MODE" in
  auto|project|skill) ;;
  *) echo "ERROR: --mode must be auto, project, or skill" >&2; exit 1 ;;
esac

section() { echo ""; echo "== $1 =="; }
warn() { echo "WARNING: $1" >&2; }

top_level_name() {
  local path="${1//\\//}"
  printf '%s\n' "${path%%/*}"
}

target_path() {
  local repo="$1"
  local target="$2"
  if [[ -z "$target" || "$target" == "." ]]; then
    printf '%s\n' "$repo"
  else
    printf '%s\n' "$repo/$target"
  fi
}

effective_mode() {
  local path="$1"
  if [[ "$MODE" != "auto" ]]; then
    printf '%s\n' "$MODE"
  elif [[ -f "$path/SKILL.md" ]]; then
    printf 'skill\n'
  else
    printf 'project\n'
  fi
}

check_file() {
  local path="$1"
  local file="$2"
  local ok="$3"
  local missing="$4"

  if [[ -f "$path/$file" ]]; then
    echo "[OK] $ok"
  else
    warn "$missing"
  fi
}

check_license() {
  local path="$1"
  local name
  for name in LICENSE LICENSE.md LICENSE.txt; do
    if [[ -f "$path/$name" ]]; then
      echo "[OK] License file exists: $name"
      return
    fi
  done
  warn "License file is missing. Ask the user which license to use before publishing."
}

check_readme_release_signals() {
  local path="$1"
  local readme="$path/README.md"

  if [[ ! -f "$readme" ]]; then
    return
  fi

  if grep -Eq 'img\.shields\.io/github/v/release|/releases/latest' "$readme"; then
    echo "[OK] README.md has a release badge"
  else
    warn "README.md is missing a GitHub release badge or latest-release link."
  fi

  if grep -Eq 'curl[[:space:]]+(-[A-Za-z0-9]+[[:space:]]+)*https?://' "$readme"; then
    echo "[OK] README.md has a curl install command"
  else
    warn "README.md is missing a one-line curl install command."
  fi

  if grep -Eq 'irm[[:space:]]+https?://.+\|[[:space:]]*iex' "$readme"; then
    echo "[OK] README.md has a PowerShell install command"
  else
    warn "README.md is missing a one-line PowerShell install command."
  fi
}

readme_top_block() {
  local file="$1"
  awk 'seen && /^##[[:space:]]+/ { exit } { print; seen=1 }' "$file"
}

check_readme_badges() {
  local path="$1"
  local file name top_block badge_count

  for name in README.md README.zh-CN.md; do
    file="$path/$name"
    if [[ ! -f "$file" ]]; then
      continue
    fi

    top_block="$(readme_top_block "$file")"
    badge_count="$(printf '%s\n' "$top_block" | { grep -Eo '!\[[^]]*\]\([^)]*(shields\.io|badge\.svg|actions/workflows)[^)]*\)' || true; } | wc -l | tr -d '[:space:]')"

    if (( badge_count >= 3 )); then
      echo "[OK] $name has 3+ top badges ($badge_count found)"
    else
      warn "$name should have at least 3 truthful top badges: License, release/version, and platform/tech."
    fi

    if printf '%s\n' "$top_block" | grep -Eiq '!\[[^]]*(license|licence)[^]]*\]\([^)]+\)|badge/(license|licence)-|license[-:]'; then
      echo "[OK] $name has a License badge"
    else
      warn "$name is missing a License badge near the top."
    fi

    if printf '%s\n' "$top_block" | grep -Eiq 'github/v/release|releases/latest|latest[ -]?release|badge/(release|version)-|\bversion\b'; then
      echo "[OK] $name has a release/version badge"
    else
      warn "$name is missing a latest release or version badge near the top."
    fi

    if printf '%s\n' "$top_block" | grep -Eiq 'platform|windows|macos|linux|powershell|bash|github[ -]?cli|python|node\.?js|nodejs|rust|go|react|tauri|vite|docker|npm|pnpm|yarn|bun|cargo'; then
      echo "[OK] $name has a platform/tech badge"
    else
      warn "$name is missing a platform or real tech-stack badge near the top."
    fi
  done
}

check_readme_language_links() {
  local path="$1"
  local readme="$path/README.md"
  local readme_zh="$path/README.zh-CN.md"

  if [[ ! -f "$readme" || ! -f "$readme_zh" ]]; then
    return
  fi

  if grep -Eq '\]\(README\.zh-CN\.md\)' "$readme"; then
    echo "[OK] README.md links to README.zh-CN.md"
  else
    warn "README.md is missing a visible link to README.zh-CN.md."
  fi

  if grep -Eq '\]\(README\.md\)' "$readme_zh"; then
    echo "[OK] README.zh-CN.md links back to README.md"
  else
    warn "README.zh-CN.md is missing a visible link back to README.md."
  fi
}

check_readme_core_sections() {
  local path="$1"
  local readme="$path/README.md"
  local readme_zh="$path/README.zh-CN.md"
  local label pattern

  if [[ -f "$readme" ]]; then
    while IFS='|' read -r label pattern; do
      if grep -Eq "^#{2,3}[[:space:]]+($pattern)([[:space:]]|$|[:：-])" "$readme"; then
        echo "[OK] README.md has $label section"
      else
        warn "README.md is missing a Kaoyan-style README section: $label."
      fi
    done <<'EOF'
Why|Why([[:space:]]|$)|Why This Exists|Why Use
Core Features|Core Features|Features
Screenshots & Demo|Screenshots?[[:space:]]*(&|and)[[:space:]]*Demo|Screenshots?|Demo
Quick Start|Quick Start
Engineering Quality|Engineering Quality|Quality
Project Docs|Project Docs|Documentation|Docs
Privacy & Security|Privacy[[:space:]]*(&|and)[[:space:]]*Security|Security|Privacy
Release & Updates|Release[[:space:]]*(&|and)[[:space:]]*Updates|Releases?|Updates?
Roadmap|Roadmap
Contributing|Contributing|Contribution
Troubleshooting|Troubleshooting|FAQ
License|License
EOF
  fi

  if [[ -f "$readme_zh" ]]; then
    while IFS='|' read -r label pattern; do
      if grep -Eq "^#{2,3}[[:space:]]+($pattern)([[:space:]]|$|[:：-])" "$readme_zh"; then
        echo "[OK] README.zh-CN.md has $label section"
      else
        warn "README.zh-CN.md is missing a Kaoyan-style README section: $label."
      fi
    done <<'EOF'
为什么做|为什么做|为什么|项目动机
核心特性|核心特性|功能|主要功能
截图与演示|截图与演示|截图|演示
快速开始|快速开始
工程质量|工程质量|质量
项目文档|项目文档|文档
隐私与安全边界|隐私与安全边界|隐私与安全|安全边界
发布与更新|发布与更新|发布|更新
路线图|路线图
贡献|贡献
故障排查|故障排查|常见问题|FAQ
License|License|许可证|许可
EOF
  fi
}

check_skill_frontmatter() {
  local path="$1"
  local skill_md="$path/SKILL.md"
  if [[ ! -f "$skill_md" ]]; then
    warn "SKILL.md is missing"
    return
  fi

  local name desc
  name="$(awk 'BEGIN{in_fm=0} /^---$/{in_fm++; next} in_fm==1 && /^name:[[:space:]]*/{sub(/^name:[[:space:]]*/, ""); gsub(/["'\''"]/, ""); print; exit}' "$skill_md")"
  desc="$(awk 'BEGIN{in_fm=0} /^---$/{in_fm++; next} in_fm==1 && /^description:[[:space:]]*/{sub(/^description:[[:space:]]*/, ""); print; exit}' "$skill_md")"

  if [[ -z "$name" ]]; then
    warn "SKILL.md frontmatter name is missing or not kebab-case"
  elif [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
    warn "SKILL.md frontmatter name is missing or not kebab-case"
  elif [[ -z "$desc" ]]; then
    warn "SKILL.md frontmatter description is missing or empty"
  else
    echo "[OK] SKILL.md frontmatter: name=$name"
  fi
}

check_mojibake() {
  local path="$1"
  local hits
  local marker_regex
  marker_regex="$(printf '%b|%b|%b|%b|%b|%b|%b|%b' '\u9225' '\u922E' '\u9239' '\u9242' '\u9241' '\u99C3' '\u6F0F' '\uFFFD')"
  hits="$(grep -RIlE "$marker_regex" "$path" \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=dist \
    --exclude-dir=build \
    --exclude-dir=.cache \
    --exclude-dir=__pycache__ \
    --exclude-dir=.pytest_cache 2>/dev/null \
    | grep -Ev '/scripts/preflight\.(ps1|sh)$' || true)"

  if [[ -z "$hits" ]]; then
    echo "[OK] No obvious mojibake markers found"
  else
    while IFS= read -r file; do
      [[ -n "$file" ]] && warn "Possible mojibake: $file"
    done <<< "$hits"
  fi
}

check_placeholders() {
  local path="$1"
  local hits
  local placeholder_regex
  placeholder_regex="YOUR_""USERNAME|YOUR_""REPO|<model""-name>|<path/to""/skill>"
  hits="$(grep -RInE "$placeholder_regex" "$path" \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=dist \
    --exclude-dir=build \
    --exclude-dir=.cache \
    --exclude-dir=__pycache__ \
    --exclude-dir=.pytest_cache 2>/dev/null \
    | grep -Ev '/scripts/preflight\.(ps1|sh):' || true)"

  if [[ -z "$hits" ]]; then
    echo "[OK] No obvious placeholder literals found"
  else
    while IFS= read -r hit; do
      [[ -n "$hit" ]] && warn "Placeholder literal found: $hit"
    done <<< "$hits"
  fi
}

show_quality_gate() {
  local path="$1"
  local mode="$2"

  section "High-Star Readiness Gate"
  check_file "$path" "README.md" "README.md exists" "README.md is missing"
  check_file "$path" "README.zh-CN.md" "README.zh-CN.md exists" "README.zh-CN.md is missing"
  check_license "$path"
  check_readme_release_signals "$path"
  check_readme_badges "$path"
  check_readme_language_links "$path"
  check_readme_core_sections "$path"
  check_mojibake "$path"
  check_placeholders "$path"

  if [[ "$mode" == "skill" ]]; then
    check_skill_frontmatter "$path"
  fi
}

show_verification_commands() {
  local path="$1"
  local found=false

  section "Suggested Verification Commands"

  if [[ -f "$path/package.json" ]]; then
    if grep -q '"test"[[:space:]]*:' "$path/package.json"; then
      echo "npm test"
      found=true
    fi
    if grep -q '"build"[[:space:]]*:' "$path/package.json"; then
      echo "npm run build"
      found=true
    fi
    if grep -q '"lint"[[:space:]]*:' "$path/package.json"; then
      echo "npm run lint"
      found=true
    fi
  fi

  if [[ -f "$path/pyproject.toml" || -f "$path/pytest.ini" || -d "$path/tests" ]]; then
    echo "python -m pytest"
    found=true
  fi

  if [[ -f "$path/Cargo.toml" ]]; then
    echo "cargo test"
    echo "cargo build"
    found=true
  fi

  if [[ -f "$path/go.mod" ]]; then
    echo "go test ./..."
    found=true
  fi

  if [[ "$found" == "false" ]]; then
    warn "No standard test/build command detected. Mention this explicitly before publishing."
  fi
}

cd "$REPO_ROOT"
REPO_ABS="$(pwd)"

section "Repository"
echo "Root: $REPO_ABS"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not a Git repository." >&2
  exit 1
fi

BRANCH="$(git branch --show-current)"
UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "(none)")"
echo "Branch:   $BRANCH"
echo "Upstream: $UPSTREAM"

section "Remotes"
git remote -v || warn "No Git remotes configured."

section "GitHub CLI"
if command -v gh >/dev/null 2>&1; then
  gh --version | head -1
  gh auth status || warn "GitHub CLI exists but is not authenticated."
else
  warn "GitHub CLI (gh) not found. Push may still work through Git credentials."
fi

section "Git Status"
STATUS="$(git status --porcelain)"
if [[ -z "$STATUS" ]]; then
  echo "Working tree has no pending changes."
else
  echo "$STATUS"
fi

TARGETS=()
if [[ -n "$PROJECT_NAME" ]]; then
  TARGETS=("$PROJECT_NAME")
elif [[ -n "$SKILL_NAME" ]]; then
  warn "--skill-name is kept for compatibility. Prefer --project-name with --mode skill."
  TARGETS=("$SKILL_NAME")
elif [[ "$ALL" == "true" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" && "$line" != .* ]] && TARGETS+=("$line")
  done < <(git status --porcelain | awk '{print $2}' | while IFS= read -r path; do top_level_name "$path"; done | sort -u)
else
  warn "Neither --project-name nor --all provided. Showing all changed top-level directories."
  while IFS= read -r line; do
    [[ -n "$line" && "$line" != .* ]] && TARGETS+=("$line")
  done < <(git status --porcelain | awk '{print $2}' | while IFS= read -r path; do top_level_name "$path"; done | sort -u)
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  warn "No target directories found from current changes."
else
  for target in "${TARGETS[@]}"; do
    path="$(target_path "$REPO_ABS" "$target")"

    section "Target Project"
    echo "Name: $target"
    echo "Path: $path"

    if [[ ! -d "$path" ]]; then
      warn "Target directory not found: $target"
      continue
    fi

    mode="$(effective_mode "$path")"
    echo "Mode: $mode"
    if [[ "$MODE" != "$mode" ]]; then
      echo "Requested mode: $MODE"
    fi

    show_quality_gate "$path" "$mode"
    show_verification_commands "$path"
  done
fi

section "Repository Ignore File"
if [[ -f ".gitignore" ]]; then
  echo "[OK] .gitignore exists"
else
  warn ".gitignore is missing. Review generated files carefully before staging."
fi

section "Risky Pending Paths"
RISKY="$(git status --porcelain | awk '{print $2}' | grep -Ei '(^|/)\.env($|\.)|(^|/)node_modules/|(^|/)dist/|(^|/)build/|(^|/)\.cache/|(^|/)__pycache__/|(^|/)\.pytest_cache/|(^|/)playwright-report/|(^|/)test-results/|\.log$|\.pem$|\.key$|(^|/)id_rsa($|\.)|token|credential|secret' || true)"
if [[ -z "$RISKY" ]]; then
  echo "No obvious secret/cache/build paths found in pending changes."
else
  while IFS= read -r path; do
    warn "$path"
  done <<< "$RISKY"
fi

section "Large Pending Files"
FOUND_LARGE=false
while IFS= read -r path; do
  if [[ -f "$path" ]]; then
    size="$(stat -c%s "$path" 2>/dev/null || stat -f%z "$path" 2>/dev/null || echo 0)"
    if (( size > 5 * 1024 * 1024 )); then
      if command -v bc >/dev/null 2>&1; then
        mb="$(echo "scale=2; $size/1048576" | bc)"
      else
        mb="$(( size / 1048576 ))"
      fi
      warn "Large file: $path (${mb} MB)"
      FOUND_LARGE=true
    fi
  fi
done < <(git status --porcelain | awk '{print $2}')

if [[ "$FOUND_LARGE" == "false" ]]; then
  echo "No pending files larger than 5 MB found."
fi

echo ""
echo "Preflight complete. Review warnings before staging. This script did not change files, stage commits, or push."
