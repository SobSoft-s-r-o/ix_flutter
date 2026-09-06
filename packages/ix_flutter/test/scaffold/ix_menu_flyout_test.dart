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

/// Captures `debugPrint` so the reserved-id notice never leaks into the
/// suite log, and returns the captured lines plus the callback that puts
/// `debugPrint` back.
///
/// Flutter asserts that no foundation debug variable is still overridden
/// *before* `addTearDown` callbacks run, so the test body has to call
/// `restore` itself; the tear-down is the guard for a body that throws
/// first, latched so it can never clobber a later override.
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

/// The viewport the fly-out must stay inside, in global coordinates.
Rect _viewportRect(Size size) => Offset.zero & size;

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
      expect(
        tester.getRect(find.byKey(const Key('ix-menu-flyout'))).width,
        320,
        reason: 'the side layout leaves room for the full panel width',
      );

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
    'showSettings/showThemeToggle/showAboutLegal: false suppress the built-in '
    'entries',
    (tester) async {
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
          onThemeModeChanged: (_) {},
          showSettings: false,
          showThemeToggle: false,
          showAboutLegal: false,
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );

      expect(find.text('Settings'), findsNothing);
      expect(find.text('Toggle theme'), findsNothing);
      expect(find.text('About & legal information'), findsNothing);
    },
  );

  testWidgets(
    'a kept reserved entry is not duplicated by its built-in counterpart',
    (tester) async {
      final capture = _captureDebugPrint();
      addTearDown(IxApplicationScaffold.debugResetReservedIdWarnings);
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: true,
          entries: const [
            IxMenuEntry(id: 'home', type: IxMenuEntryType.item, label: 'Home'),
            IxMenuEntry(
              id: 'settings',
              type: IxMenuEntryType.item,
              label: 'Settings',
              isBottom: true,
            ),
            IxMenuEntry(
              id: 'theme-toggle',
              type: IxMenuEntryType.custom,
              label: 'Theme',
              isBottom: true,
            ),
            IxMenuEntry(
              id: 'about-legal',
              type: IxMenuEntryType.item,
              label: 'About & legal',
              isBottom: true,
            ),
          ],
          settings: const Text('settings-panel'),
          about: const Text('about-panel'),
          onThemeModeChanged: (_) {},
          onOpenSettings: () {},
          onOpenAboutLegal: () {},
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('About & legal'), findsOneWidget);
      capture.restore();
      expect(find.text('Toggle theme'), findsNothing);
      expect(find.text('About & legal information'), findsNothing);
      expect(capture.logs.where((l) => l.contains('reserved')), hasLength(3));
    },
  );

  testWidgets('works above the Navigator, where there is no Overlay ancestor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1440, 900),
          disableAnimations: true,
        ),
        child: MaterialApp(
          theme: const IxThemeBuilder(mode: ThemeMode.light).build(),
          debugShowCheckedModeBanner: false,
          // A persistent shell placed above the Navigator: the common 1.x
          // placement, where `Overlay.maybeOf` finds nothing.
          builder: (context, child) => IxApplicationScaffold(
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
                ],
              ),
            ],
            onNavigate: (_) {},
            body: child!,
          ),
          home: const SizedBox.shrink(),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Reports'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daily'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daily'), findsNothing);
    expect(
      find.descendant(
        of: find.byWidget(FocusManager.instance.primaryFocus!.context!.widget),
        matching: find.byTooltip('Reports'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'drawer layout: a built-in panel opens next to the drawer and neither it '
    'nor the theme toggle closes the drawer',
    (tester) async {
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          entries: const [
            IxMenuEntry(id: 'home', type: IxMenuEntryType.item, label: 'Home'),
          ],
          settings: const Text('settings-panel'),
          onThemeModeChanged: (_) {},
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        // Below the 1024px breakpoint the menu lives in a Drawer.
        size: const Size(600, 800),
      );

      await tester.tap(find.byTooltip('Open menu'));
      // The drawer's own slide-in is not driven by MediaQuery, so it needs
      // to settle rather than a single fixed pump.
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('settings-panel'), findsOneWidget);
      expect(
        find.text('Home'),
        findsOneWidget,
        reason: 'the drawer stays open behind the panel',
      );

      const viewport = Size(600, 800);
      final panel = tester.getRect(find.byKey(const Key('ix-menu-flyout')));
      expect(
        panel.left,
        greaterThanOrEqualTo(0.0),
        reason: 'panel $panel starts outside ${_viewportRect(viewport)}',
      );
      expect(
        panel.right,
        lessThanOrEqualTo(viewport.width),
        reason: 'panel $panel is clipped on the right of $viewport',
      );
      expect(
        panel.bottom,
        lessThanOrEqualTo(viewport.height),
        reason: 'panel $panel is clipped at the bottom of $viewport',
      );
      expect(
        panel.top,
        greaterThanOrEqualTo(kToolbarHeight),
        reason: 'panel $panel overlaps the app bar',
      );
      expect(
        panel.width,
        greaterThan(200),
        reason: 'panel $panel was clamped down to an unusable width',
      );

      await tester.tap(find.text('Toggle theme'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    },
  );

  testWidgets(
    'drawer layout in RTL: the panel opens leftwards and stays inside the '
    'viewport',
    (tester) async {
      // Mirror of the LTR drawer assertion above. In RTL the drawer sits on
      // the right edge and `IxMenuFlyout` opens leftwards, so the room left
      // for the panel is measured from the anchor's left edge, not from the
      // viewport's right edge.
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          entries: const [
            IxMenuEntry(id: 'home', type: IxMenuEntryType.item, label: 'Home'),
          ],
          settings: const Text('settings-panel'),
          onThemeModeChanged: (_) {},
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(600, 800),
        textDirection: TextDirection.rtl,
      );

      await tester.tap(find.byTooltip('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('settings-panel'), findsOneWidget);

      const viewport = Size(600, 800);
      final panel = tester.getRect(find.byKey(const Key('ix-menu-flyout')));
      expect(
        panel.left,
        greaterThanOrEqualTo(0.0),
        reason: 'panel $panel starts outside ${_viewportRect(viewport)}',
      );
      expect(
        panel.right,
        lessThanOrEqualTo(viewport.width),
        reason: 'panel $panel is clipped on the right of $viewport',
      );
      expect(
        panel.bottom,
        lessThanOrEqualTo(viewport.height),
        reason: 'panel $panel is clipped at the bottom of $viewport',
      );
      expect(
        panel.width,
        greaterThan(200),
        reason: 'panel $panel was clamped down to an unusable width',
      );
    },
  );

  testWidgets(
    'reserved id "settings" still works through the shim and warns once in '
    'debug',
    (tester) async {
      final capture = _captureDebugPrint();
      addTearDown(IxApplicationScaffold.debugResetReservedIdWarnings);
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
      capture.restore();

      expect(opened, 1);
      expect(capture.logs.where((l) => l.contains('reserved')).length, 1);
    },
  );

  testWidgets('re-tapping the anchor closes the panel and keeps the focus on '
      'the tile', (tester) async {
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
              IxMenuEntry(id: 'r1', type: IxMenuEntryType.item, label: 'Daily'),
            ],
          ),
        ],
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
      size: const Size(1440, 900),
    );

    // Opened from the keyboard, so the focus really is inside the panel.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // collapse button
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // category tile
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daily'), findsOneWidget);

    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Daily'), findsNothing);
    expect(
      find.descendant(
        of: find.byWidget(FocusManager.instance.primaryFocus!.context!.widget),
        matching: find.byTooltip('Reports'),
      ),
      findsOneWidget,
      reason: 'closing by re-tapping the anchor drops the focus',
    );
  });

  testWidgets('expanding the rail closes the panel and keeps the focus on the '
      'tile', (tester) async {
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
              IxMenuEntry(id: 'r1', type: IxMenuEntryType.item, label: 'Daily'),
            ],
          ),
        ],
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
      size: const Size(1440, 900),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // collapse button
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // category tile
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daily'), findsOneWidget);

    await tester.tap(find.byType(IxIconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Daily'), findsNothing);
    expect(
      find.descendant(
        of: find.byWidget(FocusManager.instance.primaryFocus!.context!.widget),
        matching: find.text('Reports'),
      ),
      findsOneWidget,
      reason: 'expanding the rail dropped the focus out of the menu',
    );
  });

  testWidgets('a panel whose anchor disappears is closed', (tester) async {
    Widget scaffold({required bool withSettings}) => IxApplicationScaffold(
      appTitle: 'App',
      initiallyExpanded: true,
      entries: const [
        IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
      ],
      settings: withSettings ? const Text('Settings panel') : null,
      onNavigate: (_) {},
      body: const SizedBox(),
    );

    await pumpIx(tester, scaffold(withSettings: true));
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Settings panel'), findsOneWidget);

    await pumpIx(tester, scaffold(withSettings: false));
    await tester.pumpAndSettle();
    expect(find.text('Settings panel'), findsNothing);
    expect(tester.takeException(), isNull);

    // The panel must not re-open by itself when the anchor comes back: the
    // open state was forgotten with the anchor, not merely un-rendered.
    await pumpIx(tester, scaffold(withSettings: true));
    await tester.pumpAndSettle();
    expect(find.text('Settings panel'), findsNothing);
  });

  testWidgets('navigating from a menu entry closes an open panel', (
    tester,
  ) async {
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        initiallyExpanded: true,
        entries: const [
          IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
        ],
        settings: const Text('Settings panel'),
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
    );
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Settings panel'), findsOneWidget);

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(find.text('Settings panel'), findsNothing);
  });

  testWidgets('a dropdown inside a panel does not dismiss it', (tester) async {
    var selected = 0;
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        initiallyExpanded: true,
        entries: const [
          IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
        ],
        settings: Builder(
          builder: (context) => IxDropdownButton<int>(
            label: 'Language',
            items: const [
              IxDropdownMenuItem(value: 1, label: 'English'),
              IxDropdownMenuItem(value: 2, label: 'Deutsch'),
            ],
            onItemSelected: (value) => selected = value,
          ),
        ),
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
    );

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(
      find.text('Language'),
      findsOneWidget,
      reason: 'opening the dropdown closed the panel',
    );
    expect(find.text('Deutsch'), findsOneWidget);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(
      find.text('Language'),
      findsOneWidget,
      reason: 'picking a dropdown item closed the panel',
    );
  });

  for (final width in const [360.0, 320.0]) {
    testWidgets('the drawer fly-out stays inside a ${width.toInt()}px '
        'viewport', (tester) async {
      final size = Size(width, 640);
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: true,
          entries: const [
            IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
          ],
          settings: const Text('Settings panel'),
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: size,
      );

      await tester.tap(find.byTooltip('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final panel = tester.getRect(find.byKey(const Key('ix-menu-flyout')));
      expect(panel.left, greaterThanOrEqualTo(0));
      expect(panel.right, lessThanOrEqualTo(width));
      expect(panel.width, greaterThanOrEqualTo(200));
      expect(tester.takeException(), isNull);
    });
  }
}
