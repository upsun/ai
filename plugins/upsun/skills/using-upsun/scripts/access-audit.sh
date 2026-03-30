#!/bin/bash
# Audit access for a project and its parent organization
# Usage: PROJECT=abc123 ORG=my-company bash access-audit.sh

PROJECT="${PROJECT:?Set PROJECT}"
ORG="${ORG:?Set ORG}"

echo "=== Access Audit: $(date) ==="

echo ""
echo "--- Project Users ($PROJECT) ---"
upsun users -p "$PROJECT"

echo ""
echo "--- Organization Users ($ORG) ---"
upsun org:users --org "$ORG"

echo ""
echo "--- Teams ($ORG) ---"
upsun teams --org "$ORG"

echo ""
echo "Review completed. Update access as needed."
