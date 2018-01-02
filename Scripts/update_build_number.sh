#!/usr/bin/env bash

git rev-parse 2> /dev/null > /dev/null || { echo >&2 "Git repository required. Aborting build number update script."; exit 0; }

# Create version
count=`git log --oneline | wc -l  | awk '{gsub(/^ +| +$/,"")} {print $0}'`
date=$(((`date "+%s"` - 1514764800) / (15 * 60)))
version="$count.$date"
echo "Build number is $version"

# Main app info.plist
filepath="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
echo "Updating $filepath"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${filepath}"

# Extensions info.plist
echo "Searching in '${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/*.app/Info.plist'"
for subplist in "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"/*.app/Info.plist; do
	echo "Updating $subplist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${subplist}"
done

echo "Searching in '${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PlugIns/*.appex/Info.plist'"
for subplist in "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"/PlugIns/*.appex/Info.plist; do
	echo "Updating $subplist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${subplist}"
done

# Dsym info.plist
filepath="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
echo "Updating dSYM at ${filepath}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${version}" "${filepath}"
