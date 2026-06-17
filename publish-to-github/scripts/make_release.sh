#!/usr/bin/env bash
# make_release.sh - package skills and create a versioned GitHub Release.
# This helper is intentionally skill-specific. Ordinary project releases should
# create tags/releases directly and should not produce .skill packages.
#
# Requires: git, gh CLI, zip when package_skill.py is unavailable.
#
# Usage:
#   ./scripts/make_release.sh --repo-root <repo> --version v1.0.0 --skill-name my-skill
#   ./scripts/make_release.sh --repo-root <repo> --version v1.0.0 --all
#   ./scripts/make_release.sh --repo-root <repo> --version v1.0.0 --all --notes "What changed"

set -euo pipefail

VERSION=""
SKILL_NAME=""
ALL=false
NOTES=""
REPO_ROOT="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    --skill-name) SKILL_NAME="$2"; shift 2 ;;
    --all) ALL=true; shift ;;
    --notes) NOTES="$2"; shift 2 ;;
    --repo-root) REPO_ROOT="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  echo "ERROR: --version is required, for example --version v1.0.0" >&2
  exit 1
fi

cd "$REPO_ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: --repo-root must point inside a Git repository." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI (gh) is required. Install it from https://cli.github.com/" >&2
  exit 1
fi

if [[ -n "$SKILL_NAME" ]]; then
  SKILLS=("$SKILL_NAME")
elif [[ "$ALL" == "true" ]]; then
  mapfile -t SKILLS < <(
    find . -maxdepth 2 -name "SKILL.md" \
      | xargs -I{} dirname {} \
      | sed 's|^\./||' \
      | grep -v '^\.' \
      | sort
  )
else
  echo "ERROR: specify --skill-name <name> or --all" >&2
  exit 1
fi

ASSETS=()
PACKAGER="skill-creator/scripts/package_skill.py"

for skill in "${SKILLS[@]}"; do
  if [[ ! -f "$skill/SKILL.md" ]]; then
    echo "WARNING: $skill has no SKILL.md, skipping" >&2
    continue
  fi

  skill_basename="$(basename "$skill")"

  if [[ -f "$PACKAGER" ]]; then
    echo "Packaging $skill with package_skill.py..."
    (
      cd skill-creator
      PYTHONIOENCODING=utf-8 python -m scripts.package_skill "../$skill" ..
    )
    asset="${skill_basename}.skill"
  else
    echo "Packaging $skill as zip because package_skill.py was not found..."
    asset="${skill_basename}.zip"
    zip -r "$asset" "$skill" \
      -x "*.pyc" \
      -x "*/__pycache__/*" \
      -x "*/.pytest_cache/*" \
      -x "*/.git/*"
  fi

  ASSETS+=("$asset")
  echo "  -> $asset"
done

for installer in publish-to-github/scripts/install.sh publish-to-github/scripts/install.ps1; do
  if [[ -f "$installer" ]]; then
    ASSETS+=("$installer")
    echo "  -> $installer"
  fi
done

if [[ ${#ASSETS[@]} -eq 0 ]]; then
  echo "ERROR: No skills packaged." >&2
  exit 1
fi

echo ""
echo "Tagging $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

GH_ARGS=("release" "create" "$VERSION" "--title" "Release $VERSION")
if [[ -n "$NOTES" ]]; then
  GH_ARGS+=("--notes" "$NOTES")
else
  GH_ARGS+=("--generate-notes")
fi
for asset in "${ASSETS[@]}"; do
  GH_ARGS+=("$asset")
done

echo "Creating GitHub Release $VERSION..."
gh "${GH_ARGS[@]}"

echo ""
echo "Done. Release $VERSION published with:"
for asset in "${ASSETS[@]}"; do
  echo "  $asset"
done
