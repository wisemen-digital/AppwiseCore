#!/usr/bin/env bash

set -euo pipefail

if ! git rev-parse 2> /dev/null > /dev/null; then
  echo >&2 "error: Git repository required. Aborting build number update script."
  exit 1
fi

# Create version
commitCount=$(git log --oneline | wc -l | awk '{gsub(/^ +| +$/,"")} {print $0}')
commitTimestamp=$(git log -1 --format=%ct | awk '{gsub(/^ +| +$/,"")} {print $0}')
dateRelativeToCommit=$(((($(date "+%s") - commitTimestamp) / (15 * 60)) + 1))
version="$commitCount.$dateRelativeToCommit"
echo "Build number is $version"

# Main app info.plist
filepath="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
echo "Updating '$filepath'"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${filepath}"

# Only update version numbers for extensions during archive
if [ "$ACTION" = "install" ]; then
  APP_PATH="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"

  # Extensions info.plist
  echo "Searching in '${APP_PATH}/*.app/Info.plist'"
  find "$APP_PATH" -name '*.app' -type d | while read -r subapp; do
    if [ -f "$subapp/Info.plist" ]; then
      echo "Updating $subapp/Info.plist"
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${subapp}/Info.plist"
    fi
  done

  echo "Searching in '${APP_PATH}/PlugIns/*.appex/Info.plist'"
  if [ -d "$APP_PATH/PlugIns" ]; then
    find "$APP_PATH/PlugIns" -name '*.appex' -type d | while read -r subapp; do
      if [ -f "$subapp/Info.plist" ]; then
        echo "Updating $subapp/Info.plist"
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${subapp}/Info.plist"
      fi
    done
  fi

  echo "Searching in '${APP_PATH}/AppClips/*.app/Info.plist'"
  if [ -d "$APP_PATH/AppClips" ]; then
    find "$APP_PATH/AppClips" -name '*.app' -type d | while read -r subapp; do
      if [ -f "$subapp/Info.plist" ]; then
        echo "Updating $subapp/Info.plist"
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${subapp}/Info.plist"
      fi
    done
  fi
fi

# Dsym info.plist
filepath="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
if [ -f "$filepath" ]; then
  echo "Updating dSYM at '${filepath}'"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${filepath}" || true
fi
