#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="${REPOSITORY:-learning-kai/my-skill}"
SKILL_NAME="${SKILL_NAME:-human-scribe}"
DESTINATION="${DESTINATION:-$HOME/.codex/skills}"

ARCHIVE_NAME="$SKILL_NAME.skill"
DOWNLOAD_URL="https://github.com/$REPOSITORY/releases/latest/download/$ARCHIVE_NAME"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/$SKILL_NAME-install.XXXXXX")"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DESTINATION"

echo "Downloading $DOWNLOAD_URL"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/$ARCHIVE_NAME"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$DOWNLOAD_URL" -O "$TMP_DIR/$ARCHIVE_NAME"
else
  echo "ERROR: curl or wget is required." >&2
  exit 1
fi

rm -rf "$DESTINATION/$SKILL_NAME"
unzip -q "$TMP_DIR/$ARCHIVE_NAME" -d "$DESTINATION"

echo "Installed $SKILL_NAME to $DESTINATION/$SKILL_NAME"
echo "Restart Codex or open a new session before using the skill."
