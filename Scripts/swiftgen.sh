#!/usr/bin/env bash

set -euo pipefail

PODS_ROOT=${PODS_ROOT:-Pods}
SWIFTGEN="$PODS_ROOT/SwiftGen/bin/swiftgen"

# Avoid running on CI
if [[ ${CI:-} ]]; then
  echo "Not executing SwiftGen on CI."
  exit 0
fi

# Check if we have the executable
if [ ! -f "$SWIFTGEN" ]; then
  echo "error: SwiftGen is not installed. Visit https://github.com/SwiftGen/SwiftGen to learn more."
  exit 1
fi

# Only execute during normal builds (not archives)
if [ "$ACTION" != "install" ]; then
  "$SWIFTGEN"
fi
