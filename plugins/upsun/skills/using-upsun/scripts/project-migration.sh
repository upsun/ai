#!/bin/bash
# Migrate configuration from one Upsun project to another
# Usage: SOURCE_PROJECT=old123 TARGET_PROJECT=new456 LOCAL_DIR=~/projects/new-project bash project-migration.sh

SOURCE_PROJECT="${SOURCE_PROJECT:?Set SOURCE_PROJECT}"
TARGET_PROJECT="${TARGET_PROJECT:?Set TARGET_PROJECT}"
LOCAL_DIR="${LOCAL_DIR:?Set LOCAL_DIR}"

echo "Migrating from $SOURCE_PROJECT to $TARGET_PROJECT..."

echo "1. Creating backup of source..."
upsun backup:create -p "$SOURCE_PROJECT" -e production

echo "2. Copying configuration..."
upsun repo:cat .upsun/config.yaml -p "$SOURCE_PROJECT" -e production > /tmp/upsun-config.yaml

cd "$LOCAL_DIR"
cp /tmp/upsun-config.yaml .upsun/config.yaml

git add .upsun/
git commit -m "Import configuration from $SOURCE_PROJECT"
upsun push -p "$TARGET_PROJECT" -e main

echo "3. Data migration (manual steps):"
echo "   - Export databases from $SOURCE_PROJECT"
echo "   - Import to $TARGET_PROJECT"
echo "   - Test thoroughly"

echo "Configuration migrated"
