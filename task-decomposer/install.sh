#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/learning-kai/my-skill.git"
target_root="${CODEX_HOME:-$HOME/.codex}/skills"
target="$target_root/task-decomposer"
tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to install task-decomposer." >&2
  exit 1
fi

git clone --depth 1 "$repo_url" "$tmp_dir/repo" >/dev/null
mkdir -p "$target_root"

if [ -d "$target" ]; then
  backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  echo "Existing task-decomposer moved to $backup"
fi

cp -R "$tmp_dir/repo/task-decomposer" "$target"
echo "Installed task-decomposer to $target"
