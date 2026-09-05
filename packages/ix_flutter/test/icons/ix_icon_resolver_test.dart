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

  // `IxIconKey`'s own doc-comment promises that library widgets always
  // request icons through `IxIcon.key`, and `doc/ix_icons.md` repeats it:
  // an `IxThemeBuilder(icons:)` override has to reach every built-in
  // widget, not just the scaffold/toast/pagination/dropdown ones.
  group('IxThemeBuilder(icons:) reaches the built-in widgets', () {
    ThemeData themeWith(Map<IxIconKey, IconData> overrides) => IxThemeBuilder(
      mode: ThemeMode.light,
      icons: IxIconResolver.material().copyWith(
        icons: {
          for (final e in overrides.entries)
            e.key: IxIconData.material(e.value),
        },
      ),
    ).build();

    testWidgets('IxBlind header chevron', (tester) async {
      await pumpIx(
        tester,
        const IxBlind(title: 'Section', expanded: false, child: Text('body')),
        theme: themeWith({IxIconKey.chevronRight: Icons.star}),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('IxBreadcrumb home icon and chevrons', (tester) async {
      await pumpIx(
        tester,
        const IxBreadcrumb(
          items: [
            IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'home'),
            IxBreadcrumbItemData(label: 'Plant', breadcrumbKey: 'plant'),
          ],
          showHomeLabel: true,
        ),
        theme: themeWith({
          IxIconKey.home: Icons.rocket_launch,
          IxIconKey.chevronRightSmall: Icons.pets,
          IxIconKey.chevronDownSmall: Icons.anchor,
        }),
      );
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsWidgets);
      expect(find.byIcon(Icons.anchor), findsWidgets);
    });

    testWidgets('IxResponsiveDataView empty states', (tester) async {
      Widget dataView({String? searchQuery}) => IxResponsiveDataView<String>(
        items: const [],
        desktopColumns: [
          IxColumnDef<String>(
            label: 'Name',
            cellBuilder: (context, item) => Text(item),
          ),
        ],
        mobileFields: [
          IxMobileFieldDef<String>(
            label: 'Name',
            valueBuilder: (context, item) => Text(item),
          ),
        ],
        rowActions: const [],
        searchQuery: searchQuery,
      );

      final theme = themeWith({
        IxIconKey.search: Icons.bug_report,
        IxIconKey.info: Icons.cake,
      });

      await pumpIx(tester, dataView(), theme: theme);
      expect(find.byIcon(Icons.cake), findsOneWidget);

      await pumpIx(tester, dataView(searchQuery: 'nothing'), theme: theme);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });
  });
}
