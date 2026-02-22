#!/bin/bash
# Sets GitHub repository topics on the newly created JPGBMR destination repo.
# GH_TOKEN must be available as an environment variable (inherited from the workflow step).
#
# Args: $1=PROJECT  $2=STACK
#
# IMPORTANT: each topic requires its own --add-topic flag. Passing a space-separated
# string to a single flag (e.g. --add-topic "html css javascript") sets a single topic
# whose name is literally "html css javascript" — which is not what we want.

set -e

PROJECT="$1"
STACK="$2"

echo "Setting topics on JPGBMR/$PROJECT (stack: $STACK)..."

case "$STACK" in
  python)
    gh repo edit "JPGBMR/$PROJECT" \
      --add-topic python \
      --add-topic open-source \
      --add-topic cli \
      --add-topic tool
    ;;

  html)
    gh repo edit "JPGBMR/$PROJECT" \
      --add-topic html \
      --add-topic css \
      --add-topic javascript \
      --add-topic web-app \
      --add-topic open-source
    ;;

  powershell)
    gh repo edit "JPGBMR/$PROJECT" \
      --add-topic powershell \
      --add-topic windows \
      --add-topic system-monitor \
      --add-topic open-source
    ;;

  *)
    # Unknown stack — log a warning and exit cleanly rather than failing the workflow
    echo "Warning: unknown stack '$STACK' — no topics set for $PROJECT"
    exit 0
    ;;
esac

echo "Topics set for JPGBMR/$PROJECT"
