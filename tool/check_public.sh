#!/bin/sh
# Pre-commit guard for a PUBLIC repository. Blocks staged lines that look
# like secrets or private details. Mark a deliberate fake value with the
# text "public-ok" on the same line.
# Install once per clone: git config core.hooksPath tool/hooks
patterns='eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.|[Bb]earer [A-Za-z0-9._-]{24,}|/Volumes/|/Users/|/home/[a-z]|[A-Za-z0-9._%+-]+@(gmail|yahoo|hotmail|outlook|icloud)\.com|BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|tech_?92|technology_?ninety|technology92'
hits=$(git diff --cached -U0 --no-color -- . ':(exclude)tool/check_public.sh' \
  | grep '^+' | grep -v '^+++' | grep -v 'public-ok' | grep -Ei "$patterns")
if [ -n "$hits" ]; then
  echo "Blocked: this repository is public and the staged changes look private:" >&2
  echo "$hits" | cut -c1-160 >&2
  echo "Remove it, or add 'public-ok' on the line if it is a deliberate fake." >&2
  exit 1
fi
