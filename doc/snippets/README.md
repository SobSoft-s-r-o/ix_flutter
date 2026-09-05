# Documentation snippets

Every ```dart block in `doc/*.md`, `README.md`, `packages/ix_flutter/README.md`,
`GETTING_STARTED.md` and `FAQ.md` is a verbatim copy of a declaration in this
package, so the documentation cannot drift away from the API it documents.

```bash
cd doc/snippets
flutter pub get
flutter analyze   # must report "No issues found!"
```

One file per documentation page, named after it (`doc/ix_blind.md` →
`lib/ix_blind_snippets.dart`). The package is never published (`publish_to:
none`) and its `pubspec.lock` is git-ignored; it depends on `ix_flutter`
through a path dependency, so it always compiles against the sources in this
repository.

`lib/generated_icons_stub.dart` stands in for the `lib/ix_icons.dart` that
`ix_icons_generator` writes into a consuming app — the only thing in here that
is not real API, since the generated catalogue does not exist until the tool is
run. Documentation blocks show it as `package:your_app/ix_icons.dart`.
