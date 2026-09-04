#!/usr/bin/env bash
# Forbidden claims/commands in documentation and published code.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
check() { # $1 = regex, $2 = description
  if grep -rn -E "$1" --include='*.md' --include='*.dart' --include='*.yaml' \
       --exclude-dir=wiki --exclude-dir=.git --exclude-dir=docs --exclude-dir=build --exclude-dir=.dart_tool \
       --exclude-dir=.superpowers --exclude-dir=.claude --exclude-dir=.worktrees . \
       | grep -v 'CHANGELOG.md' ; then
    echo "FORBIDDEN: $2"; fail=1
  fi
}
check 'licensing restrictions|distribution restrictions|cannot be bundled' 'unsubstantiated icon licensing claim (see UPSTREAM.md)'
check 'ix_flutter:generate_icons' 'stale generator command (use dart run ix_icons_generator:generate_icons)'
exit $fail
