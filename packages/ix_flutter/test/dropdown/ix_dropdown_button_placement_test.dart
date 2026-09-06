import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// [IxDropdownButton] placed where no [Overlay] can be resolved.
///
/// A persistent shell built through `MaterialApp.builder` sits *above* the
/// `Navigator`, so `Overlay.maybeOf` finds nothing there. 1.0.2 only touched
/// the overlay when the menu opened, so a trigger in that position built
/// fine; mounting the portal unconditionally turned it into a build-time
/// crash for the whole shell. The portal is mounted only where an overlay
/// exists again, and wrapping the shell in [Overlay.wrap] -- the remedy the
/// debug notice names, and the one tooltips need too -- makes the menu work.
Widget _shell(Widget child, {bool withOverlay = false}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: const IxThemeBuilder(mode: ThemeMode.light).build(),
    builder: (context, app) {
      final shell = Column(
        children: [
          child,
          Expanded(child: app ?? const SizedBox.shrink()),
        ],
      );
      return withOverlay ? Overlay.wrap(child: shell) : shell;
    },
    home: const Scaffold(body: Center(child: Text('page'))),
  );
}

IxDropdownButton<int> _dropdown(List<int> selected) => IxDropdownButton<int>(
  label: 'Actions',
  items: const [
    IxDropdownMenuItem(value: 1, label: 'One'),
    IxDropdownMenuItem(value: 2, label: 'Two'),
  ],
  onItemSelected: selected.add,
);

void main() {
  testWidgets('builds above the Navigator without an Overlay ancestor', (
    tester,
  ) async {
    await tester.pumpWidget(_shell(Material(child: _dropdown(<int>[]))));
    expect(tester.takeException(), isNull);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('page'), findsOneWidget);
  });

  testWidgets('IxPaginationBar page-size menu works in the wrapped shell', (
    tester,
  ) async {
    final sizes = <int>[];
    await tester.pumpWidget(
      _shell(
        Material(
          child: IxPaginationBar(
            page: 0,
            totalPages: 5,
            onPageChanged: (_) {},
            pageSize: 10,
            pageSizeOptions: const [10, 25],
            onPageSizeChanged: sizes.add,
          ),
        ),
        // The bar's chevrons are tooltipped `IxIconButton`s, and a Material
        // tooltip needs an Overlay wherever it is: the wrap is not optional
        // for this widget above the Navigator.
        withOverlay: true,
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25').last);
    await tester.pumpAndSettle();
    expect(sizes, [25]);
  });

  testWidgets('the opening menu carries its rows in semantics', (tester) async {
    // A fully transparent `FadeTransition` drops its child's semantics, which
    // left the `menu` node child-less on the opening frame and tripped the
    // framework's "a menu cannot be empty" assertion.
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: const IxThemeBuilder(mode: ThemeMode.light).build(),
        home: Scaffold(body: Material(child: _dropdown(<int>[]))),
      ),
    );
    await tester.tap(find.text('Actions'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('One'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Overlay.wrap around the shell makes the menu work', (
    tester,
  ) async {
    final selected = <int>[];
    await tester.pumpWidget(
      _shell(Material(child: _dropdown(selected)), withOverlay: true),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(selected, [2]);
    expect(find.text('One'), findsNothing);
  });
}
