import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

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
}
