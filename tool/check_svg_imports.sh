#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bad=$(grep -rln "package:flutter_svg" packages/ix_flutter/lib | grep -v '^packages/ix_flutter/lib/src/ix_icons/' || true)
if [ -n "$bad" ]; then echo "flutter_svg imported outside lib/src/ix_icons:"; echo "$bad"; exit 1; fi
if ! grep -q "package:flutter_svg" packages/ix_flutter/lib/src/ix_icons/ix_icon.dart; then echo "ix_icon.dart must import flutter_svg"; exit 1; fi
echo "flutter_svg imports OK"
