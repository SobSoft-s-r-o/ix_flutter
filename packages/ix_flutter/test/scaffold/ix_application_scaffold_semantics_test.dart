import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Accessibility contract of the [IxApplicationScaffold] navigation menu:
/// exactly one semantics node per tile, the upstream `aria-selected` /
/// `aria-expanded` states, and the built-in theme toggle's toggled state.
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so each `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it.

void main() {
  @Upstream('menu-item.tsx aria-selected/aria-expanded; menu.tsx role')
  void menuSemantics() {
    testWidgets(
      'menu bar role, one node per tile, category expanded state, theme '
      'toggle toggled state',
      (tester) async {
        final handle = tester.ensureSemantics();
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
        handle.dispose();
      },
    );
  }

  menuSemantics();
}
