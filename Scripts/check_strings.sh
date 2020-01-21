#!/usr/bin/env bash

set -euo pipefail

PODS_ROOT=${PODS_ROOT:-Pods}
BARTYCROUCH="$PODS_ROOT/BartyCrouch/bartycrouch"

# Avoid running on CI
if [[ ${CI:-} ]]; then
  echo "Not executing BartyCrouch on CI."
  exit 0
fi

# Check if we have the executable
if [ ! -f "$BARTYCROUCH" ]; then
  echo "error: BartyCrouch is not installed. Visit https://github.com/Flinesoft/BartyCrouch to learn more."
  exit 1
fi

# Only execute during normal builds (not archives)
if [ "$ACTION" != "install" ]; then
  "$BARTYCROUCH" update -x
  "$BARTYCROUCH" lint -x
fi
