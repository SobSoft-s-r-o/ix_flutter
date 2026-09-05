import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/upstream.dart';

/// Covers spec finding TM-1: `IxThemeController` is the Flutter counterpart
/// of the upstream `themeSwitcher` singleton -- it holds the configured theme
/// name and color schema, resolves `system` against the platform brightness
/// and emits `themeChanged` events with the same payload.
void main() {
  // Metadata can only precede a declaration, not a bare `test(...)`
  // statement, so every @Upstream-tagged test is wrapped in a local function
  // that is invoked immediately below it (same convention as
  // palette_parity_test.dart).
  @Upstream(
    'theme-switcher.ts:12-19 themeChanged {theme, colorSchema, mode, isMediaChange}',
  )
  void systemSchemaFollowsPlatformBrightness() {
    test(
      'system schema follows platform brightness and emits themeChanged',
      () async {
        final c = IxThemeController(platformBrightness: Brightness.light);
        final events = <IxThemeChange>[];
        final sub = c.themeChanged.listen(events.add);

        expect(c.colorSchema, IxColorSchema.system);
        expect(c.mode, Brightness.light);
        expect(c.themeMode, ThemeMode.system);

        c.updatePlatformBrightness(Brightness.dark);
        await Future<void>.delayed(Duration.zero);
        expect(c.mode, Brightness.dark);
        expect(events.single.isMediaChange, isTrue);
        expect(events.single.mode, Brightness.dark);

        c.setColorSchema(IxColorSchema.light);
        await Future<void>.delayed(Duration.zero);
        expect(c.mode, Brightness.light);
        expect(events.last.isMediaChange, isFalse);
        expect(events.last.colorSchema, IxColorSchema.light);

        await sub.cancel();
        c.dispose();
      },
    );
  }

  systemSchemaFollowsPlatformBrightness();

  @Upstream(
    'theme-switcher.ts:146-147 prefers-color-scheme listener emits a media change',
  )
  void followsTheBindingsPlatformBrightness() {
    testWidgets('follows the binding platform brightness while on system', (
      tester,
    ) async {
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;

      final c = IxThemeController();
      addTearDown(c.dispose);
      var notifications = 0;
      c.addListener(() => notifications++);
      expect(c.mode, Brightness.light);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pump();

      expect(c.mode, Brightness.dark);
      expect(notifications, 1);
    });
  }

  followsTheBindingsPlatformBrightness();

  @Upstream('theme-switcher.ts:106-117 getTheme() reports the configured theme')
  void themeDataCarriesTheConfiguredThemeName() {
    test('light and dark ThemeData carry the configured theme name', () {
      final c = IxThemeController(theme: const IxThemeName('classic'));
      expect(c.light.extension<IxTheme>()!.themeName, IxThemeName.classic);
      expect(c.dark.brightness, Brightness.dark);
      c.dispose();
    });
  }

  themeDataCarriesTheConfiguredThemeName();
}
