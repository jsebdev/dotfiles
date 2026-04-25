#!/bin/bash
MESSAGE="$1"
PROJECT=$(basename "$PWD")

if [ -n "$ITERM_SESSION_ID" ] || [ "$LC_TERMINAL" = "iTerm2" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  TERMINAL_BUNDLE="com.googlecode.iterm2"
else
  TERMINAL_BUNDLE="com.apple.Terminal"
fi

if command -v terminal-notifier > /dev/null 2>&1; then
  terminal-notifier -message "$MESSAGE" -title "Claude Code — $PROJECT" -activate "$TERMINAL_BUNDLE"
else
  osascript -e "display notification \"$MESSAGE\" with title \"Claude Code — $PROJECT\""
fi
