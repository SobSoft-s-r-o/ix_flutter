#!/bin/bash
# Regenerate icons for the main library (with package reference)

cd "$(dirname "$0")/.."

echo "Regenerating icons for ix_flutter library..."

dart run tool/bin/generate_icons.dart \
  --project-root . \
  --output lib/src/ix_icons \
  --assets assets/svg \
  --package ix_flutter

echo "Done!"
