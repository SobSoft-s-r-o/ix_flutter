# ix_flutter example

Showcase app for [`ix_flutter`](../packages/ix_flutter): every page under
`lib/screen/` demonstrates one area of the Siemens iX design system (themes,
buttons, chips, forms, navigation, ...) against the library's classic light
and dark themes.

## Run it

```bash
flutter pub get
flutter run -d chrome
```

Any other configured device/target works too (`flutter run -d macos`,
`flutter run -d <device-id>`, ...); Chrome is just the fastest way to try it
without extra platform tooling.

## Regenerate the bundled icons

The app vendors a generated subset of `@siemens/ix-icons` under
`lib/ix_icons.dart` and `assets/ix_icons/`, built by
[`ix_icons_generator`](../packages/ix_icons_generator):

```bash
dart run ix_icons_generator:generate_icons
```

Re-run it after upgrading the generator or changing which icons the app
references.

## Regenerate the pub.dev screenshots

`packages/ix_flutter/screenshots/*.png` (referenced from
`packages/ix_flutter/pubspec.yaml`'s `screenshots:` metadata) are captured by
`test/screenshots_test.dart`, which renders `HomePage` and `ButtonsPage`
against the light and dark classic themes at 1440x900 and writes the PNGs
straight into the library's `screenshots/` directory:

```bash
flutter test --dart-define=IX_CAPTURE_SCREENSHOTS=true test/screenshots_test.dart
```

Without the `IX_CAPTURE_SCREENSHOTS` define the same test still runs (as part
of the regular `flutter test`) but only pumps and asserts the pages render;
it does not touch the PNGs. After regenerating, validate them from the
library package:

```bash
cd ../packages/ix_flutter && dart run tool/check_screenshots.dart
```
