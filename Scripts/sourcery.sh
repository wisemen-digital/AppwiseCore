#!/usr/bin/env bash

set -euo pipefail

PODS_ROOT=${PODS_ROOT:-Pods}
SOURCERY="$PODS_ROOT/Sourcery/bin/sourcery"

# Avoid running on CI
if [[ ${CI:-} ]]; then
  echo "Not executing Sourcery on CI."
  exit 0
fi

# Check if we have the executable
if [ ! -f "$SOURCERY" ]; then
  echo "error: Sourcery is not installed. Visit https://github.com/krzysztofzablocki/Sourcery to learn more."
  exit 1
fi

# Only execute during normal builds (not archives)
if [ "$ACTION" != "install" ]; then
  "$SOURCERY"
fi
