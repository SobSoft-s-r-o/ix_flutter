import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/fixture_asset_bundle.dart';
import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Guards `IxIcon`'s own public widget contract, which has no direct
/// upstream `.ct.ts`/scss counterpart to cite via `@Upstream`:
/// `semanticLabel`/`excludeFromSemantics` wiring onto the `Semantics` node,
/// and `colorToken` resolving through `IxTheme`.
void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // that is invoked immediately below it (same convention as the C-2 red
  // matrices).
  @Upstream('ix-icons icon.css :host sizes 12/16/24/32')
  void ixIconRendersAFixedBoxForEverySizeRegardlessOfSource() {
    testWidgets(
      'IxIcon renders a fixed box for every size regardless of source',
      (tester) async {
        for (final size in IxIconSize.values) {
          await pumpIx(
            tester,
            Row(
              children: [
                IxIcon(
                  const IxIconData.material(Icons.close),
                  size: size,
                  key: const Key('m'),
                ),
                IxIcon(
                  IxIconData.widget((_) => const Text('x')),
                  size: size,
                  key: const Key('w'),
                ),
              ],
            ),
          );
          expect(
            tester.getSize(find.byKey(const Key('m'))),
            Size(size.px, size.px),
          );
          expect(
            tester.getSize(find.byKey(const Key('w'))),
            Size(size.px, size.px),
          );
        }
      },
    );
  }

  ixIconRendersAFixedBoxForEverySizeRegardlessOfSource();

  testWidgets('semanticLabel is exposed, excludeFromSemantics hides the node', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      Row(
        children: const [
          IxIcon(IxIconData.material(Icons.close), semanticLabel: 'Close'),
          IxIcon(
            IxIconData.material(Icons.info),
            semanticLabel: 'Info',
            excludeFromSemantics: true,
            key: Key('hidden'),
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    expect(find.bySemanticsLabel('Info'), findsNothing);
    expect(tester.getSemantics(find.byKey(const Key('hidden'))).label, isEmpty);
    handle.dispose();
  });

  group('size resolution', () {
    testWidgets('without a custom IconTheme the box is 24px', (tester) async {
      await pumpIx(
        tester,
        const IxIcon(IxIconData.material(Icons.close), key: Key('i')),
      );
      expect(tester.getSize(find.byKey(const Key('i'))), const Size(24, 24));
    });

    testWidgets('an explicit IxIconSize wins over the ambient IconTheme', (
      tester,
    ) async {
      await pumpIx(
        tester,
        const IconTheme(
          data: IconThemeData(size: 12),
          child: IxIcon(
            IxIconData.material(Icons.close),
            size: IxIconSize.s32,
            key: Key('i'),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('i'))), const Size(32, 32));
    });

    testWidgets('the ambient IconTheme size is used exactly, not snapped to '
        'an IxIconSize', (tester) async {
      await pumpIx(
        tester,
        const IconTheme(
          data: IconThemeData(size: 18),
          child: IxIcon(IxIconData.material(Icons.close), key: Key('i')),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('i'))), const Size(18, 18));
    });

    testWidgets('a widget-builder source is sized through the same resolved '
        'IconTheme', (tester) async {
      await pumpIx(
        tester,
        IconTheme(
          data: const IconThemeData(size: 18),
          child: IxIcon(
            IxIconData.widget(
              (context) => Text('${IconTheme.of(context).size}'),
            ),
            key: const Key('i'),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('i'))), const Size(18, 18));
      expect(find.text('18.0'), findsOneWidget);
    });

    testWidgets('a Material slot that styles its icon reaches IxIcon too', (
      tester,
    ) async {
      await pumpIx(
        tester,
        TextButton.icon(
          onPressed: () {},
          icon: const IxIcon(IxIconData.material(Icons.close), key: Key('i')),
          label: const Text('Close'),
        ),
      );
      final materialIconSize = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byKey(const Key('i')),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(
        tester.getSize(find.byKey(const Key('i'))),
        Size.square(materialIconSize.data.size!),
      );
      expect(materialIconSize.data.size, 18);
    });
  });

  testWidgets('colorToken resolves through IxTheme', (tester) async {
    await pumpIx(
      tester,
      const IxIcon(
        IxIconData.material(Icons.close),
        colorToken: IxThemeColorToken.alarm,
      ),
    );
    final icon = tester.widget<Icon>(find.byType(Icon));
    final ix = const IxThemeBuilder(
      mode: ThemeMode.light,
    ).build().extension<IxTheme>()!;
    expect(icon.color, ix.color(IxThemeColorToken.alarm));
  });

  testWidgets('an SVG icon adds no image node of its own', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      DefaultAssetBundle(
        bundle: FixtureAssetBundle(const {
          'valid.svg': 'test/fixtures/icons/valid.svg',
        }),
        child: IxIconButton(
          icon: const IxIcon(IxIconData.asset('valid.svg')),
          tooltip: 'Refresh',
          onPressed: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // `IxIcon` owns the icon's semantics; `SvgPicture`'s own `image: true`
    // node would announce a labelled button as an image on top of it.
    expect(
      tester.getSemantics(find.byType(IxIconButton)).flagsCollection.isImage,
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('an SVG icon honours IconThemeData.opacity', (tester) async {
    await pumpIx(
      tester,
      DefaultAssetBundle(
        bundle: FixtureAssetBundle(const {
          'valid.svg': 'test/fixtures/icons/valid.svg',
        }),
        child: const IconTheme(
          data: IconThemeData(size: 24, color: Color(0xFF102030), opacity: 0.5),
          child: IxIcon(IxIconData.asset('valid.svg')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      picture.colorFilter,
      ColorFilter.mode(
        const Color(0xFF102030).withValues(alpha: 0.5),
        BlendMode.srcIn,
      ),
    );
  });

  testWidgets('a Material icon honours IconThemeData.opacity too', (
    tester,
  ) async {
    await pumpIx(
      tester,
      const IconTheme(
        data: IconThemeData(size: 24, color: Color(0xFF102030), opacity: 0.5),
        child: IxIcon(IxMaterialIconData(Icons.close)),
      ),
    );
    expect(
      tester.widget<Icon>(find.byType(Icon)).color,
      const Color(0xFF102030).withValues(alpha: 0.5),
    );
  });

  group('IconThemeData.opacity is applied exactly once', () {
    // `Icon.color` and `SvgPicture.colorFilter` only record what `IxIcon`
    // *asked* for. Material's own `Icon` then resolves the ambient
    // `IconThemeData.opacity` against the colour it was handed
    // (`widgets/icon.dart`: `iconColor.withOpacity(iconColor.opacity *
    // iconOpacity)`) before the glyph is painted, so a colour `IxIcon` has
    // already dimmed is dimmed a second time. Only the painted colour tells
    // the two apart, which is why these assertions read the
    // `RenderParagraph` that actually paints the glyph.
    const base = Color(0xFF102030);
    const translucent = Color(0x80102030);

    Color paintedGlyphColor(WidgetTester tester, Key key) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.byKey(key), matching: find.byType(RichText)),
      );
      return paragraph.text.style!.color!;
    }

    void expectPainted(Color painted, Color source, double alpha) {
      expect(painted.withValues(alpha: 1), source.withValues(alpha: 1));
      expect(painted.a, closeTo(alpha, 0.001));
    }

    testWidgets('a Material glyph is painted at the ambient opacity, not '
        'its square', (tester) async {
      await pumpIx(
        tester,
        const IconTheme(
          data: IconThemeData(size: 24, color: base, opacity: 0.5),
          child: IxIcon(IxIconData.material(Icons.close), key: Key('i')),
        ),
      );
      expectPainted(paintedGlyphColor(tester, const Key('i')), base, 0.5);
    });

    testWidgets("an explicit color's own alpha is dimmed once", (tester) async {
      await pumpIx(
        tester,
        const IconTheme(
          data: IconThemeData(size: 24, color: base, opacity: 0.5),
          child: IxIcon(
            IxIconData.material(Icons.close),
            color: translucent,
            key: Key('i'),
          ),
        ),
      );
      expectPainted(
        paintedGlyphColor(tester, const Key('i')),
        translucent,
        translucent.a * 0.5,
      );
    });

    testWidgets('a custom widget icon is painted at the same opacity', (
      tester,
    ) async {
      await pumpIx(
        tester,
        IconTheme(
          data: const IconThemeData(size: 24, color: base, opacity: 0.5),
          child: IxIcon(
            IxIconData.widget((_) => const Icon(Icons.check)),
            key: const Key('i'),
          ),
        ),
      );
      expectPainted(paintedGlyphColor(tester, const Key('i')), base, 0.5);
    });

    testWidgets('a successful SVG tint dims an explicit alpha once', (
      tester,
    ) async {
      await pumpIx(
        tester,
        DefaultAssetBundle(
          bundle: FixtureAssetBundle(const {
            'valid.svg': 'test/fixtures/icons/valid.svg',
          }),
          child: const IconTheme(
            data: IconThemeData(size: 24, color: base, opacity: 0.5),
            child: IxIcon(IxIconData.asset('valid.svg'), color: translucent),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        ColorFilter.mode(
          translucent.withValues(alpha: translucent.a * 0.5),
          BlendMode.srcIn,
        ),
      );
    });
  });
}
