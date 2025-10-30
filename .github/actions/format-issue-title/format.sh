#!/bin/bash
set -e

ISSUE_NUMBER=$1
OLD_TITLE=$2
PLACEHOLDER=$3
DRY_RUN=$4
PREFIX="TZF"

YEAR=$(date +%y)
PADDED_NUM=$(printf "%04d" "$ISSUE_NUMBER")
IDENTIFIER="${PREFIX}-${YEAR}${PADDED_NUM}"

# Skip if already present
if echo "$OLD_TITLE" | grep -q "$IDENTIFIER"; then
  echo "Identifier already present. Skipping."
  exit 0
fi

# Replace placeholder at start if provided
if [ -n "$PLACEHOLDER" ] && echo "$OLD_TITLE" | grep -q "^$PLACEHOLDER"; then
  NEW_TITLE=$(echo "$OLD_TITLE" | sed "s/^$PLACEHOLDER[[:space:]]*/$IDENTIFIER /")
else
  # Insert after emoji if present
  if [[ "$OLD_TITLE" =~ ^([[:space:]]*[\xF0-\xF7][\x80-\xBF]+[[:space:]]*)(.*) ]]; then
    EMOJI="${BASH_REMATCH[1]}"
    REST="${BASH_REMATCH[2]}"
    NEW_TITLE="${EMOJI}${IDENTIFIER} ${REST}"
  else
    NEW_TITLE="${IDENTIFIER} ${OLD_TITLE}"
  fi
fi

# Normalize spacing
NEW_TITLE=$(echo "$NEW_TITLE" | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')

echo "New title would be: $NEW_TITLE"

if [ "$DRY_RUN" = "true" ]; then
  echo "Dry-run enabled. Not updating title."
  exit 0
fi

gh issue edit "$ISSUE_NUMBER" --title "$NEW_TITLE" --repo "${GITHUB_REPOSITORY}"
echo "Title updated successfully."
