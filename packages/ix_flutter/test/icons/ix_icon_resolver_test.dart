import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Guards `IxIconResolver`'s own public contract, which has no direct
/// upstream `.ct.ts`/scss counterpart to cite via `@Upstream`: the built-in
/// `material()` resolver maps every `IxIconKey`, `IxThemeBuilder(icons:)`
/// lets a single key be overridden while the rest keep resolving through the
/// material default, and `IxIconResolver.of` falls back to
/// `IxIconResolver.material()` when no `IxThemeBuilder` theme extension is
/// present.
void main() {
  test('material resolver covers every IxIconKey', () {
    final r = IxIconResolver.material();
    for (final k in IxIconKey.values) {
      expect(r.resolve(k), isA<IxMaterialIconData>(), reason: k.name);
    }
  });

  testWidgets('IxThemeBuilder(icons:) overrides a single key', (tester) async {
    final custom = IxIconResolver.material().copyWith(
      icons: {IxIconKey.close: IxIconData.widget((_) => const Text('X'))},
    );
    await pumpIx(
      tester,
      const IxIcon.key(IxIconKey.close),
      theme: IxThemeBuilder(mode: ThemeMode.light, icons: custom).build(),
    );
    expect(find.text('X'), findsOneWidget);
  });

  testWidgets(
    'IxIconResolver.of falls back to material when no theme extension',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: IxIcon.key(IxIconKey.close)),
      );
      expect(find.byType(Icon), findsOneWidget);
    },
  );
}
