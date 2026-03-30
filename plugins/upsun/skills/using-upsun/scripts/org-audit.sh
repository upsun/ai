#!/bin/bash
# Audit an organization: list projects, users, teams, subscriptions
# Usage: ORG=my-company bash org-audit.sh

ORG="${ORG:?Set ORG}"

echo "=== Organization Audit: $ORG ==="
echo "Date: $(date)"

echo ""
echo "--- Projects ---"
upsun projects --org "$ORG"

echo ""
echo "--- Users ---"
upsun org:users --org "$ORG"

echo ""
echo "--- Teams ---"
upsun teams --org "$ORG"

echo ""
echo "--- Subscriptions ---"
upsun org:subs "$ORG"

echo ""
echo "--- Summary ---"
echo "Projects: $(upsun projects --org "$ORG" --pipe | wc -l)"
echo "Users: $(upsun org:users --org "$ORG" --pipe | wc -l)"
echo "Teams: $(upsun teams --org "$ORG" --pipe | wc -l)"
