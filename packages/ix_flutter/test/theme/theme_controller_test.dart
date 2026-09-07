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
        expect(events.single.theme, IxThemeName.classic);
        expect(events.single.colorSchema, IxColorSchema.system);

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

  test('icons and density reach both built themes', () {
    final icons = IxIconResolver.material().copyWith(
      icons: {IxIconKey.close: IxIconData.widget((_) => const Text('X'))},
    );
    final c = IxThemeController(icons: icons, density: IxDensity.compact);
    addTearDown(c.dispose);

    expect(c.light.extension<IxIconResolver>(), same(icons));
    expect(c.dark.extension<IxIconResolver>(), same(icons));
    expect(c.light.extension<IxTheme>()!.density, IxDensity.compact);
    expect(c.dark.extension<IxTheme>()!.density, IxDensity.compact);
  });

  test('setting the same theme and schema is a no-op', () async {
    final c = IxThemeController(colorSchema: IxColorSchema.light);
    addTearDown(c.dispose);
    final events = <IxThemeChange>[];
    final sub = c.themeChanged.listen(events.add);
    addTearDown(sub.cancel);
    var notifications = 0;
    c.addListener(() => notifications++);
    final light = c.light;

    c.setColorSchema(IxColorSchema.light);
    c.setTheme(IxThemeName.classic, IxColorSchema.light);
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 0);
    expect(events, isEmpty);
    expect(c.light, same(light));

    // A real schema change still notifies -- but the two ThemeData objects
    // do not depend on the schema, so they are not rebuilt either.
    c.setColorSchema(IxColorSchema.dark);
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 1);
    expect(events.single.colorSchema, IxColorSchema.dark);
    expect(c.light, same(light));
  });

  test('setTheme emits the new theme name and rebuilds both themes', () async {
    final c = IxThemeController(colorSchema: IxColorSchema.light);
    addTearDown(c.dispose);
    final events = <IxThemeChange>[];
    final sub = c.themeChanged.listen(events.add);
    addTearDown(sub.cancel);
    final before = c.light;

    c.setTheme(const IxThemeName('acme'), IxColorSchema.light);
    await Future<void>.delayed(Duration.zero);

    expect(events.single.theme, const IxThemeName('acme'));
    expect(events.single.isMediaChange, isFalse);
    expect(c.light, isNot(same(before)));
    expect(c.light.extension<IxTheme>()!.themeName, const IxThemeName('acme'));
  });

  test(
    'updatePlatformBrightness is silent while the schema is not system',
    () async {
      final c = IxThemeController(
        colorSchema: IxColorSchema.light,
        platformBrightness: Brightness.light,
      );
      addTearDown(c.dispose);
      final events = <IxThemeChange>[];
      final sub = c.themeChanged.listen(events.add);
      addTearDown(sub.cancel);
      var notifications = 0;
      c.addListener(() => notifications++);

      c.updatePlatformBrightness(Brightness.dark);
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0);
      expect(events, isEmpty);
      expect(c.mode, Brightness.light);

      // The new platform brightness was still recorded, so switching to
      // `system` reports it right away.
      c.setColorSchema(IxColorSchema.system);
      expect(c.mode, Brightness.dark);
    },
  );
}
