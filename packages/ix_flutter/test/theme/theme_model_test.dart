// Both the equivalence test and the alias test deliberately drive the
// deprecated `family`/`mode` builder path -- that is exactly what they
// guard -- so the deprecation infos are suppressed for the whole file.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';
// IxClassicLightColors is not part of the public barrel (only the tokens and
// the family enum are), so the classic palette is imported from src, the same
// way palette_parity_test.dart reads it.
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_light_colors.dart';

import '../helpers/upstream.dart';

/// Captures `debugPrint` so the one-time `IxThemeFamily.brand` notice never
/// leaks into the suite log, and returns the captured lines plus the callback
/// that puts `debugPrint` back (same helper as
/// `test/scaffold/ix_menu_flyout_test.dart`).
///
/// The tear-down is only the guard for a body that throws first, latched so
/// it can never clobber a later override; the body restores it itself.
({List<String> logs, VoidCallback restore}) _captureDebugPrint() {
  final logs = <String>[];
  final previous = debugPrint;
  var restored = false;
  void restore() {
    if (restored) {
      return;
    }
    restored = true;
    debugPrint = previous;
  }

  addTearDown(restore);
  debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
  return (logs: logs, restore: restore);
}

/// Covers spec finding TM-1 (the v5-style theme model next to the deprecated
/// `family`/`mode` API). Apart from the `@Upstream`-tagged equivalence test,
/// the tests here guard our own 1.x API shape (`IxCustomPalette`, the
/// `copyWith`/`lerp` plumbing) and deprecation policy, for which there is no
/// upstream Siemens iX counterpart to cite, so they are covered by this
/// file-level doc-comment instead of `@Upstream`.
void main() {
  // Metadata can only precede a declaration, not a bare `test(...)`
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // that is invoked immediately below it (same convention as
  // palette_parity_test.dart).
  @Upstream(
    'theme-switcher.ts:90-120 theme name and color schema are independent',
  )
  void newBuilderApiProducesTheSameThemeData() {
    test(
      'new builder API produces the same ThemeData as the deprecated one',
      () {
        final old = const IxThemeBuilder(
          family: IxThemeFamily.classic,
          mode: ThemeMode.dark,
        ).build();
        final neu = const IxThemeBuilder.dark().build();
        final oldIx = old.extension<IxTheme>()!;
        final neuIx = neu.extension<IxTheme>()!;
        for (final t in IxThemeColorToken.values) {
          expect(neuIx.color(t), oldIx.color(t), reason: t.name);
        }
        expect(neu.brightness, Brightness.dark);
        expect(neuIx.themeName, IxThemeName.classic);
        expect(neuIx.colorSchema, IxColorSchema.dark);
      },
    );
  }

  newBuilderApiProducesTheSameThemeData();

  test('partial custom palette fills missing tokens from classic', () {
    final p = IxCustomPalette.partial(
      light: {IxThemeColorToken.primary: const Color(0xFF123456)},
    );
    final light = p.resolve(Brightness.light);
    expect(light.length, IxThemeColorToken.values.length);
    expect(light[IxThemeColorToken.primary], const Color(0xFF123456));
    expect(
      light[IxThemeColorToken.color1],
      IxClassicLightColors.palette[IxThemeColorToken.color1],
    );
  });

  test('custom palette copyWith merges token by token', () {
    final base = IxCustomPalette.partial(
      light: {IxThemeColorToken.primary: const Color(0xFF123456)},
    );
    final patched = base.copyWith(
      light: {IxThemeColorToken.dynamic: const Color(0xFF654321)},
    );
    final light = patched.resolve(Brightness.light);

    expect(light[IxThemeColorToken.primary], const Color(0xFF123456));
    expect(light[IxThemeColorToken.dynamic], const Color(0xFF654321));
    expect(light.length, IxThemeColorToken.values.length);
    expect(
      patched.resolve(Brightness.dark)[IxThemeColorToken.primary],
      base.resolve(Brightness.dark)[IxThemeColorToken.primary],
    );
    // The receiver is untouched.
    expect(
      base.resolve(Brightness.light)[IxThemeColorToken.dynamic],
      IxClassicLightColors.palette[IxThemeColorToken.dynamic],
    );
  });

  test('IxTheme.copyWith and lerp carry themeName and colorSchema', () {
    final light = const IxThemeBuilder.light().build().extension<IxTheme>()!;
    final dark = const IxThemeBuilder.dark().build().extension<IxTheme>()!;

    final renamed = light.copyWith(themeName: const IxThemeName('acme'));
    expect(renamed.themeName, const IxThemeName('acme'));
    expect(renamed.colorSchema, IxColorSchema.light);
    expect(renamed.brightness, Brightness.light);

    // A new brightness re-derives the schema, unless one is passed too.
    expect(
      light.copyWith(brightness: Brightness.dark).colorSchema,
      IxColorSchema.dark,
    );
    expect(
      dark.copyWith(brightness: Brightness.light).colorSchema,
      IxColorSchema.light,
    );
    expect(
      light
          .copyWith(
            brightness: Brightness.dark,
            colorSchema: IxColorSchema.light,
          )
          .colorSchema,
      IxColorSchema.light,
    );

    expect(light.lerp(dark, 0.4).colorSchema, IxColorSchema.light);
    expect(light.lerp(dark, 0.6).colorSchema, IxColorSchema.dark);
    expect(light.lerp(dark, 0.6).themeName, IxThemeName.classic);
  });

  test('IxThemeName compares and hashes by value', () {
    // Built at runtime, so this is a distinct instance rather than the
    // canonicalized `const IxThemeName('classic')`.
    final sameValue = IxThemeName(IxThemeName.classic.value);

    expect(sameValue, IxThemeName.classic);
    expect(sameValue.hashCode, IxThemeName.classic.hashCode);
    expect(const IxThemeName('acme'), isNot(IxThemeName.classic));
    expect(<IxThemeName>{
      IxThemeName.classic,
      sameValue,
      const IxThemeName('acme'),
    }, hasLength(2));
    expect(IxThemeName.classic.value, 'classic');
    expect(IxThemeName.classic.toString(), contains('classic'));
  });

  test('IxThemeBuilder.copyWith carries theme and brightness', () {
    const base = IxThemeBuilder.light();

    expect(
      base.copyWith(brightness: Brightness.dark).build().brightness,
      Brightness.dark,
    );
    expect(
      base
          .copyWith(theme: const IxThemeName('acme'))
          .build()
          .extension<IxTheme>()!
          .themeName,
      const IxThemeName('acme'),
    );
  });

  test('IxThemeFamily.brand is a deprecated classic alias', () {
    // Building with `brand` logs the one-time deprecation notice; capture it
    // so it never reaches the suite log.
    final capture = _captureDebugPrint();
    addTearDown(IxThemeBuilder.debugResetBrandNotice);

    final brand = const IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    ).build();
    final classic = const IxThemeBuilder.light().build();
    expect(brand.colorScheme.primary, classic.colorScheme.primary);
    // brand is an alias, so it reports the classic theme name as well.
    expect(brand.extension<IxTheme>()!.themeName, IxThemeName.classic);

    capture.restore();
  });

  test('the custom family keeps its own theme name', () {
    final custom = IxThemeBuilder(
      family: IxThemeFamily.custom,
      mode: ThemeMode.light,
      customPalette: IxCustomPalette.partial(),
    ).build();

    expect(custom.extension<IxTheme>()!.themeName, const IxThemeName('custom'));
  });

  test('brand logs one deprecation notice per process in debug builds', () {
    final capture = _captureDebugPrint();
    addTearDown(IxThemeBuilder.debugResetBrandNotice);
    IxThemeBuilder.debugResetBrandNotice();

    const IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    ).build();
    const IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.dark,
    ).build();
    final notices = capture.logs.where(
      (l) => l.contains('IxThemeFamily.brand'),
    );
    expect(notices, hasLength(1));
    expect(notices.single, contains('classic'));

    // Not logged for the non-deprecated families...
    const IxThemeBuilder.light().build();
    expect(
      capture.logs.where((l) => l.contains('IxThemeFamily.brand')),
      hasLength(1),
    );

    // ...and the reset re-arms it for the next test.
    IxThemeBuilder.debugResetBrandNotice();
    const IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    ).build();
    expect(
      capture.logs.where((l) => l.contains('IxThemeFamily.brand')),
      hasLength(2),
    );

    capture.restore();
  });
}
