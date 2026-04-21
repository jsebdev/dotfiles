#!/bin/bash
MESSAGE="$1"
PROJECT=$(basename "$PWD")
osascript -e "display notification \"$MESSAGE\" with title \"Claude Code — $PROJECT\""
