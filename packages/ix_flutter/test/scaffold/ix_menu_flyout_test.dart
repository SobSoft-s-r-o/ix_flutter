import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// The internal `IxMenuFlyout` overlay panel of [IxApplicationScaffold].
///
/// The collapsed-rail fly-out restores the app-frame spec finding A-7 (P0):
/// before it, a category in a collapsed menu had no way to reveal its
/// children at all. The built-in `settings:`/`about:` panels and
/// `enableToggleTheme` mirror the upstream `<ix-menu-settings>` /
/// `<ix-menu-about>` elements and `ix-menu`'s `enableToggleTheme` property;
/// the reserved-id shim is our own 1.x compatibility contract and therefore
/// has no upstream counterpart, which is why those tests are covered by this
/// file-level doc-comment rather than an invented `@Upstream` citation.
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so each `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it.

void main() {
  testWidgets(
    'collapsed rail: category opens a fly-out with children; Escape closes '
    'and restores focus',
    (tester) async {
      final navigated = <String>[];
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: false,
          entries: const [
            IxMenuEntry(
              id: 'cat',
              type: IxMenuEntryType.category,
              label: 'Reports',
              icon: Icons.folder,
              children: [
                IxMenuEntry(
                  id: 'r1',
                  type: IxMenuEntryType.item,
                  label: 'Daily',
                ),
                IxMenuEntry(
                  id: 'r2',
                  type: IxMenuEntryType.item,
                  label: 'Weekly',
                ),
              ],
            ),
          ],
          onNavigate: navigated.add,
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );

      expect(find.text('Daily'), findsNothing);
      await tester.tap(find.byTooltip('Reports'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);

      await tester.tap(find.text('Weekly'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(navigated, ['r2']);
      expect(
        find.text('Daily'),
        findsNothing,
        reason: 'fly-out closes after navigation',
      );

      await tester.tap(find.byTooltip('Reports'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Daily'), findsNothing);
      expect(
        find.descendant(
          of: find.byWidget(
            FocusManager.instance.primaryFocus!.context!.widget,
          ),
          matching: find.byTooltip('Reports'),
        ),
        findsOneWidget,
      );
    },
  );

  @Upstream('menu.tsx <ix-menu-settings>/<ix-menu-about>, enableToggleTheme')
  void builtInPanels() {
    testWidgets('settings: and about: render built-in items that open panels; '
        'enableToggleTheme=false hides the toggle', (tester) async {
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: true,
          entries: const [
            IxMenuEntry(id: 'home', type: IxMenuEntryType.item, label: 'Home'),
          ],
          settings: const Text('settings-panel'),
          about: const Text('about-panel'),
          enableToggleTheme: false,
          onThemeModeChanged: (_) {},
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );

      expect(find.text('Toggle theme'), findsNothing);

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('settings-panel'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('settings-panel'), findsNothing);

      await tester.tap(find.text('About & legal information'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('about-panel'), findsOneWidget);
    });
  }

  builtInPanels();

  testWidgets(
    'reserved id "settings" still works through the shim and warns once in '
    'debug',
    (tester) async {
      final logs = <String>[];
      final prev = debugPrint;
      addTearDown(() => debugPrint = prev);
      debugPrint = (String? m, {int? wrapWidth}) => logs.add(m ?? '');
      var opened = 0;
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: true,
          onOpenSettings: () => opened++,
          entries: const [
            IxMenuEntry(
              id: 'settings',
              type: IxMenuEntryType.item,
              label: 'Settings',
              isBottom: true,
            ),
          ],
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );
      await tester.tap(find.text('Settings'));
      await tester.pump();
      debugPrint = prev;

      expect(opened, 1);
      expect(logs.where((l) => l.contains('reserved')).length, 1);
    },
  );
}
