#!/bin/bash
# Rotate SSH key: generate new key, add to Upsun, test, remove old key
# Usage: OLD_KEY_ID=123 bash ssh-key-rotate.sh

OLD_KEY_ID="${OLD_KEY_ID:?Set OLD_KEY_ID}"
KEY_PATH="${KEY_PATH:-$HOME/.ssh/upsun_key}"
NEW_KEY_PATH="${KEY_PATH}_new"

echo "Generating new SSH key..."
ssh-keygen -t ed25519 -f "$NEW_KEY_PATH" -N ""

echo "Adding new key to Upsun..."
upsun ssh-key:add "${NEW_KEY_PATH}.pub" --title "Rotated $(date +%Y-%m)"

echo "Verify new key works before removing old key."
echo "Current keys:"
upsun ssh-keys

read -p "Remove old key $OLD_KEY_ID and replace local key? [y/N] " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
  upsun ssh-key:delete "$OLD_KEY_ID"
  mv "$NEW_KEY_PATH" "$KEY_PATH"
  mv "${NEW_KEY_PATH}.pub" "${KEY_PATH}.pub"
  echo "Key rotation complete"
else
  echo "Old key kept. New key at: $NEW_KEY_PATH"
fi
