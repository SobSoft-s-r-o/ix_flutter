import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Traceability: [IxDensity.resolve]/[IxDensity.effectiveOf] implement a
/// Flutter-specific adaptive policy -- connected-mouse and
/// `NavigationMode.directional` detection via `RendererBinding`/
/// `MediaQuery`, plus the `IxDensityScope` > `IxThemeBuilder(density:)` >
/// adaptive precedence -- that has no single upstream `.scss`/`.tsx`
/// counterpart of its own: the upstream web components simply render at a
/// fixed density. None of the tests below carry an `@Upstream` tag for that
/// reason. One test guards a Flutter-specific robustness requirement --
/// [IxDensityScope] must not crash when the ambient [ThemeData] was not
/// built by [IxThemeBuilder] -- and the final test only reconfirms that
/// the nine invented (non-iX) button variants stay usable, unchanged,
/// while newly deprecated in 1.x.
Future<IxDensity> _effective(
  WidgetTester tester, {
  Size size = const Size(1024, 768),
  IxDensity? scope,
  IxDensity? themed,
}) async {
  late IxDensity result;
  Widget child = Builder(
    builder: (c) {
      result = IxDensity.effectiveOf(c);
      return const SizedBox();
    },
  );
  if (scope != null) child = IxDensityScope(density: scope, child: child);
  await pumpIx(
    tester,
    child,
    size: size,
    theme: themed == null
        ? null
        : IxThemeBuilder(mode: ThemeMode.light, density: themed).build(),
  );
  return result;
}

void main() {
  testWidgets('touch without pointer resolves to comfortable', (tester) async {
    expect(await _effective(tester), IxDensity.comfortable);
  });

  testWidgets('connected mouse resolves to compact', (tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    expect(await _effective(tester), IxDensity.compact);
  });

  testWidgets('narrow viewport stays comfortable even with a mouse', (
    tester,
  ) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    expect(
      await _effective(tester, size: const Size(360, 640)),
      IxDensity.comfortable,
    );
  });

  testWidgets('IxDensityScope overrides IxThemeBuilder(density:)', (
    tester,
  ) async {
    expect(
      await _effective(
        tester,
        themed: IxDensity.compact,
        scope: IxDensity.comfortable,
      ),
      IxDensity.comfortable,
    );
    expect(
      await _effective(
        tester,
        themed: IxDensity.comfortable,
        scope: IxDensity.compact,
      ),
      IxDensity.compact,
    );
  });

  testWidgets(
    'IxDensityScope tolerates a non-iX theme (no IxTheme extension) and '
    'still grows the hit area',
    (tester) async {
      await pumpIx(
        tester,
        IxDensityScope(
          density: IxDensity.comfortable,
          child: FilledButton(
            key: const Key('plainFilled'),
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
        // A plain ThemeData carries no IxTheme extension at all -- the
        // scenario this test guards against IxDensityAdapter.apply
        // crashing on `base.extension<IxTheme>()!`.
        theme: ThemeData(),
      );
      final size = tester.getSize(find.byKey(const Key('plainFilled')));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    },
  );

  group('static bake in IxThemeBuilder.build()', () {
    // `build()` has no BuildContext, so `adaptive` cannot be resolved from
    // the live input modality: the static bake follows Material's own
    // platform rule for `materialTapTargetSize` (padded on touch
    // platforms, shrinkWrap on desktop) so a desktop app keeps its 1.0.2
    // layout while touch platforms get 48x48 hit areas.
    void usePlatform(TargetPlatform platform) {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
    }

    MaterialTapTargetSize? buttonTts(ThemeData theme) =>
        theme.filledButtonTheme.style?.tapTargetSize;

    test('desktop platform bakes shrinkWrap tap targets', () {
      usePlatform(TargetPlatform.macOS);
      final theme = const IxThemeBuilder().build();
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
      expect(
        theme.switchTheme.materialTapTargetSize,
        MaterialTapTargetSize.shrinkWrap,
      );
      expect(
        theme.checkboxTheme.materialTapTargetSize,
        MaterialTapTargetSize.shrinkWrap,
      );
      expect(
        theme.radioTheme.materialTapTargetSize,
        MaterialTapTargetSize.shrinkWrap,
      );
      expect(buttonTts(theme), MaterialTapTargetSize.shrinkWrap);
    });

    test('touch platform bakes padded tap targets', () {
      usePlatform(TargetPlatform.android);
      final theme = const IxThemeBuilder().build();
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(
        theme.switchTheme.materialTapTargetSize,
        MaterialTapTargetSize.padded,
      );
      expect(
        theme.checkboxTheme.materialTapTargetSize,
        MaterialTapTargetSize.padded,
      );
      expect(buttonTts(theme), MaterialTapTargetSize.padded);
    });

    test('explicit comfortable stays padded on a desktop platform', () {
      usePlatform(TargetPlatform.macOS);
      final theme = const IxThemeBuilder(
        density: IxDensity.comfortable,
      ).build();
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(buttonTts(theme), MaterialTapTargetSize.padded);
      expect(theme.extension<IxTheme>()!.density, IxDensity.comfortable);
    });

    test('explicit compact stays shrinkWrap on a touch platform', () {
      usePlatform(TargetPlatform.android);
      final theme = const IxThemeBuilder(density: IxDensity.compact).build();
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
      expect(buttonTts(theme), MaterialTapTargetSize.shrinkWrap);
      expect(theme.extension<IxTheme>()!.density, IxDensity.compact);
    });

    test('IxTheme.density stays adaptive so effectiveOf resolves live', () {
      usePlatform(TargetPlatform.macOS);
      expect(
        const IxThemeBuilder().build().extension<IxTheme>()!.density,
        IxDensity.adaptive,
      );
    });

    test('resolvePlatform follows Material per platform', () {
      expect(
        IxDensity.resolvePlatform(TargetPlatform.android),
        IxDensity.comfortable,
      );
      expect(
        IxDensity.resolvePlatform(TargetPlatform.iOS),
        IxDensity.comfortable,
      );
      expect(
        IxDensity.resolvePlatform(TargetPlatform.fuchsia),
        IxDensity.comfortable,
      );
      expect(
        IxDensity.resolvePlatform(TargetPlatform.macOS),
        IxDensity.compact,
      );
      expect(
        IxDensity.resolvePlatform(TargetPlatform.windows),
        IxDensity.compact,
      );
      expect(
        IxDensity.resolvePlatform(TargetPlatform.linux),
        IxDensity.compact,
      );
      usePlatform(TargetPlatform.windows);
      expect(IxDensity.resolvePlatform(), IxDensity.compact);
    });
  });

  test('deprecated invented button variants are still present in 1.x', () {
    // ignore: deprecated_member_use_from_same_package
    expect(IxButtonVariant.warningPrimary, isNotNull);
  });
}
