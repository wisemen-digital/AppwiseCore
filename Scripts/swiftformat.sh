#!/usr/bin/env bash

set -euo pipefail

PODS_ROOT=${PODS_ROOT:-Pods}
SWIFTFORMAT="$PODS_ROOT/SwiftFormat/CommandLineTool/swiftformat"

# Avoid running on CI
if [[ ${CI:-} ]]; then
  echo "Not executing SwiftFormat on CI."
  exit 0
fi

# Check if we have the executable
if [ ! -f "$SWIFTFORMAT" ]; then
  echo "error: SwiftFormat is not installed. Visit https://github.com/nicklockwood/SwiftFormat to learn more."
  exit 1
fi

# Only execute during normal builds (not archives)
if [ "$ACTION" != "install" ]; then
  "$SWIFTFORMAT" .
fi
