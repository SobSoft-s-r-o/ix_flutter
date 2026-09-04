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
            excludeFromSemantics: true,
            key: Key('hidden'),
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    expect(tester.getSemantics(find.byKey(const Key('hidden'))).label, isEmpty);
    handle.dispose();
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
