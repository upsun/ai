#!/bin/bash
# Offboard a user: list their projects, then remove from organization
# Usage: USER_EMAIL=departing@example.com ORG=my-company bash offboard-user.sh

USER_EMAIL="${USER_EMAIL:?Set USER_EMAIL}"
ORG="${ORG:?Set ORG}"

echo "Offboarding user: $USER_EMAIL"

echo ""
echo "1. User's projects:"
upsun oups "$USER_EMAIL" --org "$ORG"

echo ""
echo "2. Remove from individual projects manually (user:delete per project)"
echo "3. Remove from teams manually (team:user:delete per team)"

echo ""
read -p "Remove $USER_EMAIL from organization $ORG? [y/N] " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
  upsun organization:user:delete "$USER_EMAIL" --org "$ORG"
  echo "Offboarding complete"
else
  echo "Aborted"
fi
