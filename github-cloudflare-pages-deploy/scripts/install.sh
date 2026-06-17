#!/usr/bin/env bash
set -euo pipefail

repo_url="${REPO_URL:-https://github.com/learning-kai/my-skill.git}"
skill_name="github-cloudflare-pages-deploy"
agent="${AGENT:-codex}"

case "$agent" in
  codex)
    target_root="${SKILLS_DIR:-$HOME/.codex/skills}"
    ;;
  claude|claude-code)
    target_root="${SKILLS_DIR:-$HOME/.claude/skills}"
    ;;
  kiro)
    target_root="${SKILLS_DIR:-$HOME/.kiro/skills}"
    ;;
  *)
    echo "Unsupported AGENT '$agent'. Use codex, claude, or kiro." >&2
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

git clone --depth 1 "$repo_url" "$tmp_dir/repo" >/dev/null

mkdir -p "$target_root"
rm -rf "$target_root/$skill_name"
cp -R "$tmp_dir/repo/$skill_name" "$target_root/$skill_name"

echo "Installed $skill_name to $target_root/$skill_name"
