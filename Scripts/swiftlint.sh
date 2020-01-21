#!/usr/bin/env bash

set -euo pipefail

PODS_ROOT=${PODS_ROOT:-Pods}
SWIFTLINT="$PODS_ROOT/SwiftLint/swiftlint"

# Avoid running on CI
if [[ ${CI:-} ]]; then
  echo "Not executing SwiftLint on CI."
  exit 0
fi

# Check if we have the executable
if [ ! -f "$SWIFTLINT" ]; then
  echo "error: SwiftLint is not installed. Visit https://github.com/realm/SwiftLint to learn more."
  exit 1
fi

# Only execute during normal builds (not archives)
if [ "$ACTION" != "install" ]; then
  "$SWIFTLINT" autocorrect --quiet
  "$SWIFTLINT" lint --quiet
fi
