# Goldens

Names: `<component>-<state>-<theme>.png`, mirroring the upstream
`testing/visual-testing/__screenshots__/tests/<component>/<component>.e2e.ts/<state>-1-chromium---classic-<theme>-linux.png`.
Generation: `flutter test --update-goldens test/golden`, only in a dedicated PR
with review; CI runs on a pinned Flutter 3.44.6 (DPR 1, bundled fonts from
`test/flutter_test_config.dart`).
