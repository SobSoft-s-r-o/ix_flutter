import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Enables semantics for a test and returns the callback that releases the
/// handle again.
///
/// Flutter verifies that every [SemanticsHandle] is disposed *before*
/// `addTearDown` callbacks run, so the handle has to be released at the end
/// of the test body; the tear-down is the guard that still releases it when
/// the body throws first. Releasing twice would decrement the binding's
/// handle count twice, hence the latch.
VoidCallback ensureSemantics(WidgetTester tester) {
  final handle = tester.ensureSemantics();
  var released = false;
  void release() {
    if (released) {
      return;
    }
    released = true;
    handle.dispose();
  }

  addTearDown(release);
  return release;
}

/// Accessibility contract of the [IxApplicationScaffold] navigation menu:
/// exactly one semantics node per tile, the upstream `aria-selected` /
/// `aria-expanded` states, and the built-in theme toggle's toggled state.
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so each `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it.

void main() {
  @Upstream(
    'menu.tsx:975-978 role="menubar" + i18nAriaLabelMenu; menu-item.tsx:350 '
    'aria-current="page"; menu-category.tsx:491 aria-expanded; '
    'menu.tsx:1061-1063 role="menuitemcheckbox" + aria-checked',
  )
  void menuSemantics() {
    testWidgets(
      'menu bar role, one node per tile, category expanded state, theme '
      'toggle toggled state',
      (tester) async {
        final releaseSemantics = ensureSemantics(tester);
        await pumpIx(
          tester,
          IxApplicationScaffold(
            appTitle: 'App',
            initiallyExpanded: true,
            themeMode: ThemeMode.dark,
            onThemeModeChanged: (_) {},
            entries: const [
              IxMenuEntry(
                id: 'home',
                type: IxMenuEntryType.item,
                label: 'Home',
                icon: Icons.home,
                selected: true,
              ),
              IxMenuEntry(
                id: 'cat',
                type: IxMenuEntryType.category,
                label: 'Reports',
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
            body: const SizedBox(),
          ),
          size: const Size(1440, 900),
        );

        expect(
          find.bySemanticsLabel('Home'),
          findsOneWidget,
          reason: 'tooltip must not duplicate the label',
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Home')),
          matchesSemantics(
            isButton: true,
            hasSelectedState: true,
            isSelected: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Home',
          ),
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Reports')),
          matchesSemantics(
            isButton: true,
            hasExpandedState: true,
            isExpanded: false,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Reports',
          ),
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Toggle theme')),
          matchesSemantics(
            isButton: true,
            hasToggledState: true,
            isToggled: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Toggle theme',
            value: 'Dark',
          ),
        );
        expect(find.bySemanticsLabel('Collapse sidebar'), findsOneWidget);

        // `matchesSemantics` has no `role:` parameter in this Flutter
        // version, so the ARIA role mapping is asserted on the node.
        expect(
          tester.getSemantics(find.byKey(const Key('ix-menu-bar'))).role,
          SemanticsRole.menuBar,
        );
        releaseSemantics();
      },
    );
  }

  menuSemantics();

  @Upstream(
    'menu.tsx:842-911 handleMenuKeyDown calls focus() on the menu item it '
    'moves to, so assistive technology follows it',
  )
  void focusedTilePublishesFocus() {
    testWidgets('the focused tile publishes its focused state', (tester) async {
      final releaseSemantics = ensureSemantics(tester);
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: true,
          entries: const [
            IxMenuEntry(id: 'home', type: IxMenuEntryType.item, label: 'Home'),
            IxMenuEntry(
              id: 'profile',
              type: IxMenuEntryType.item,
              label: 'Profile',
            ),
          ],
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // sidebar toggle
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // first entry
      await tester.pump();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        matchesSemantics(
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isFocused: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Home',
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Profile')),
        matchesSemantics(
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Profile',
        ),
        reason: 'an unfocused tile keeps reporting isFocused: false',
      );
      releaseSemantics();
    });
  }

  focusedTilePublishesFocus();

  @Upstream(
    "menu-item.tsx:324 'ix-focusable': !this.disabled; :348 aria-disabled",
  )
  void disabledTileIsNotFocusable() {
    testWidgets('a disabled menu tile does not claim to be focusable', (
      tester,
    ) async {
      final releaseSemantics = ensureSemantics(tester);
      await pumpIx(
        tester,
        IxApplicationScaffold(
          appTitle: 'App',
          initiallyExpanded: true,
          entries: const [
            IxMenuEntry(
              id: 'off',
              type: IxMenuEntryType.item,
              label: 'Disabled entry',
              enabled: false,
            ),
          ],
          onNavigate: (_) {},
          body: const SizedBox(),
        ),
        size: const Size(1440, 900),
      );
      // `focusable` and `focused` share one tristate flag, and `focused` is
      // applied *after* `focusable`, so publishing `focused: false` on a
      // tile that already declared `focusable: false` puts it back into the
      // traversal order it must stay out of.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Disabled entry')),
        matchesSemantics(
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          label: 'Disabled entry',
        ),
      );
      releaseSemantics();
    });
  }

  disabledTileIsNotFocusable();
}
