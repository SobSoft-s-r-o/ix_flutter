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
check 'IxButton\b|IxTheme\.lightTheme|\bToastType\b|\bBreadcrumbItem\b|\bDataColumn\b' 'stale API name in docs'
check 'ix_flutter: \^1\.0\.|ix_icons_generator: \^1\.0\.|\*\*Version\*\*: 1\.0\.0' 'stale version reference'

# Language rule (CLAUDE.md#Language): everything committed must be English.
# Letters unique to the Slovak alphabet (not shared with other Latin-script
# languages) have no legitimate reason to appear outside translation files,
# so any hit here means Slovak text slipped in. The wider set of letters
# Slovak shares with other languages (a-acute, e-acute, ...) is deliberately
# left out -- this repo's docs/tests legitimately quote other languages
# (e.g. a French/German string exercising an `Ix*Strings` localization
# override) that use those same letters, and only the Slovak-exclusive set
# can be checked without flagging them.
check_no_slovak() {
  # --exclude=check_docs.sh: this file's own source has to spell out the
  # character class below, which would otherwise match itself.
  if grep -rn -E '[ľťďňôĺŕĽŤĎŇÔ]' \
       --include='*.dart' --include='*.md' --include='*.sh' \
       --include='*.yml' --include='*.yaml' --include='*.txt' \
       --exclude='*.arb' --exclude='*.po' --exclude='check_docs.sh' \
       --exclude-dir=wiki --exclude-dir=.git --exclude-dir=docs --exclude-dir=build --exclude-dir=.dart_tool \
       --exclude-dir=.superpowers --exclude-dir=.claude --exclude-dir=.worktrees \
       --exclude-dir=l10n --exclude-dir=translations --exclude-dir=assets \
       . ; then
    echo "FORBIDDEN: Slovak text -- everything committed must be English (see CLAUDE.md#Language); only translation files (*.arb, *.po, a l10n/ or translations/ directory) may carry another language"
    fail=1
  fi
}
check_no_slovak
exit $fail
