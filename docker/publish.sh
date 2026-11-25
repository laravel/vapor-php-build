#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <arm|amd64> <layer|all>" >&2
  echo "Example: $0 amd64 php86" >&2
  echo "Example: $0 arm all" >&2
  echo "Example: $0 arm php86-arm" >&2
  exit 1
fi

ARCH="$1"
IMG="$2"

ALL_IMAGES=(
  php83
  php83-arm
  php84
  php84-arm
  php85
  php85-arm
  php86
  php86-arm
)

case "$ARCH" in
  arm|amd64) ;;
  *)
    echo "Invalid architecture: $ARCH (must be 'arm' or 'amd64')" >&2
    exit 1
    ;;
esac

IMAGES=()
for img in "${ALL_IMAGES[@]}"; do
  if [[ "$ARCH" == "arm" && "$img" == *-arm ]]; then
    IMAGES+=("$img")
  elif [[ "$ARCH" == "amd64" && "$img" != *-arm ]]; then
    IMAGES+=("$img")
  fi
done

if [[ "$IMG" == "all" ]]; then
  IMAGES_TO_PUBLISH=("${IMAGES[@]}")
else
  IMAGES_TO_PUBLISH=("$IMG")
fi

for img in "${IMAGES_TO_PUBLISH[@]}"; do
    echo img
done