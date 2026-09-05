import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Visual metrics, controlled open state, close behaviour and theming of
/// [IxDropdownButton] and [IxDropdownTheme].
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so each `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it.

/// Host that keeps [IxDropdownButton.isOpen] in its own state so the
/// controlled contract (the widget never opens by itself) can be observed.
class _ControlledHost extends StatefulWidget {
  const _ControlledHost({required this.opens, this.followCallback = false});

  /// Records every `onOpenChanged` notification.
  final List<bool> opens;

  /// When `true` the host mirrors the requested state back into `isOpen`.
  final bool followCallback;

  @override
  State<_ControlledHost> createState() => _ControlledHostState();
}

class _ControlledHostState extends State<_ControlledHost> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<int>(
      label: 'Actions',
      isOpen: _open,
      onOpenChanged: (open) {
        widget.opens.add(open);
        if (widget.followCallback) {
          setState(() => _open = open);
        }
      },
      items: const [IxDropdownMenuItem(label: 'Edit', value: 1)],
    );
  }
}

void main() {
  @Upstream(
    'dropdown-item.scss:13-49 item height 40 and full-bleed rows; '
    'dropdown.scss:16-24 menu surface without a border',
  )
  void itemMetricsAndMenuSurface() {
    testWidgets('item height 40, no border, hover uses ghostHover', (
      tester,
    ) async {
      final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
      final ix = theme.extension<IxTheme>()!;
      final dropdownTheme = theme.extension<IxDropdownTheme>()!;
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          items: const [IxDropdownMenuItem(label: 'One', value: 1)],
        ),
        theme: theme,
      );
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));

      final inkWell = find
          .ancestor(of: find.text('One'), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(inkWell).height, 40);
      expect(
        tester.widget<InkWell>(inkWell).hoverColor,
        ix.color(IxThemeColorToken.ghostHover),
      );

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(const Key('ix-dropdown-menu')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect((material.shape as RoundedRectangleBorder?)?.side.width ?? 0, 0);
      expect(material.color, dropdownTheme.background);
    });
  }

  itemMetricsAndMenuSurface();

  @Upstream(
    'dropdown-item.scss:106-131 focus-visible outline with a '
    'negative outline-offset',
  )
  void itemFocusRingStaysInsideTheRow() {
    testWidgets('the item focus ring is inset and rounded', (tester) async {
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          items: const [
            IxDropdownMenuItem(label: 'One', value: 1),
            IxDropdownMenuItem(label: 'Two', value: 2),
          ],
        ),
      );
      // Opening focuses the first row, so the menu is arrow-navigable right
      // away no matter how it was opened.
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));
      // The focus change lands in a microtask after the overlay's first
      // frame, so the ring is painted by the frame after that.
      await tester.pump();

      final rings = tester
          .widgetList<IxFocusRing>(find.byType(IxFocusRing))
          .where((ring) => ring.focused)
          .toList();
      expect(rings, hasLength(1));
      // A negative offset cancels the ring's default 2px outset, so the
      // stroke lands on the row's own edge instead of overlapping the
      // neighbouring row and the menu's rounded corner.
      expect(rings.single.offset, -IxCommonGeometry.focusBorderThickness);
      expect(rings.single.borderRadius, isNotNull);

      final ringBox = find.descendant(
        of: find.byWidget(rings.single),
        matching: find.byType(DecoratedBox),
      );
      expect(ringBox, findsOneWidget);
      final row = tester.getRect(
        find
            .ancestor(of: find.text('One'), matching: find.byType(InkWell))
            .first,
      );
      expect(tester.getRect(ringBox), row);
    });
  }

  itemFocusRingStaysInsideTheRow();

  @Upstream('dropdown-controller.ts:20,55 closeBehavior')
  void closeBehaviorGovernsOutsideAndInsideDismissal() {
    testWidgets('closeBehavior governs outside taps and item selection', (
      tester,
    ) async {
      Future<void> open(WidgetTester tester) async {
        await tester.tap(find.text('A'));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('One'), findsOneWidget);
      }

      Widget build(IxDropdownCloseBehavior behavior) => Column(
        children: [
          const SizedBox(key: Key('outside'), height: 200, width: 200),
          IxDropdownButton<int>(
            label: 'A',
            closeBehavior: behavior,
            items: const [IxDropdownMenuItem(label: 'One', value: 1)],
          ),
        ],
      );

      await pumpIx(tester, build(IxDropdownCloseBehavior.both));
      await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsNothing);

      await pumpIx(tester, build(IxDropdownCloseBehavior.inside));
      await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsOneWidget);
      await tester.tap(find.text('One'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsNothing);

      await pumpIx(tester, build(IxDropdownCloseBehavior.outside));
      await open(tester);
      await tester.tap(find.text('One'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsNothing);

      await pumpIx(tester, build(IxDropdownCloseBehavior.none));
      await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsOneWidget);
      await tester.tap(find.text('One'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsOneWidget);
    });
  }

  closeBehaviorGovernsOutsideAndInsideDismissal();

  @Upstream(
    'dropdown.tsx:166-180 an empty dropdown still renders its '
    'surface',
  )
  void emptyMenuOpensWithoutSemanticsViolation() {
    testWidgets('an empty menu opens without a menu-role violation', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpIx(tester, const IxDropdownButton<int>(label: 'A', items: []));
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('ix-dropdown-menu')), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  }

  emptyMenuOpensWithoutSemanticsViolation();

  @Upstream('dropdown.tsx:166-180 `show` is a controlled property')
  void controlledIsOpenOnlyFollowsTheOwner() {
    testWidgets('isOpen makes the widget controlled by its owner', (
      tester,
    ) async {
      final opens = <bool>[];
      await pumpIx(tester, _ControlledHost(opens: opens));
      await tester.tap(find.text('Actions'));
      await tester.pump(const Duration(milliseconds: 200));

      // The owner ignored the request, so nothing opened.
      expect(opens, [true]);
      expect(find.text('Edit'), findsNothing);

      opens.clear();
      await pumpIx(tester, _ControlledHost(opens: opens, followCallback: true));
      await tester.tap(find.text('Actions'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(opens, [true]);
      expect(find.text('Edit'), findsOneWidget);

      await tester.tap(find.text('Actions'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(opens, [true, false]);
      expect(find.text('Edit'), findsNothing);
    });
  }

  controlledIsOpenOnlyFollowsTheOwner();

  @Upstream('dropdown.tsx:166-180 the `showChanged` veto keeps the menu shut')
  void onWillOpenCanVetoOpening() {
    testWidgets('onWillOpen returning false keeps the menu closed', (
      tester,
    ) async {
      var allow = false;
      final opens = <bool>[];
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          onWillOpen: () => allow,
          onOpenChanged: opens.add,
          items: const [IxDropdownMenuItem(label: 'One', value: 1)],
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsNothing);
      expect(opens, isEmpty);

      allow = true;
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('One'), findsOneWidget);
      expect(opens, [true]);
    });
  }

  onWillOpenCanVetoOpening();

  @Upstream('dropdown-item.scss:55-71 checked item reserves the check column')
  void checkedItemIsExposedAndReservesAColumn() {
    testWidgets('checked items expose checked semantics and a check column', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          items: const [
            IxDropdownMenuItem(label: 'One', value: 1, checked: true),
            IxDropdownMenuItem(label: 'Two', value: 2),
          ],
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        tester.getSemantics(find.text('One')),
        matchesSemantics(
          isButton: true,
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'One',
        ),
      );
      expect(
        tester.getSemantics(find.text('Two')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Two',
        ),
      );
      // Both labels start at the same x so the checkmark column is reserved
      // for the unchecked row as well.
      expect(
        tester.getRect(find.text('One')).left,
        tester.getRect(find.text('Two')).left,
      );
      handle.dispose();
    });
  }

  checkedItemIsExposedAndReservesAColumn();

  @Upstream(
    'dropdown.tsx:166-180 the floating-ui flip() middleware moves '
    'the menu to the other side of the trigger when it does not fit',
  )
  void placementFlipsWhenTheMenuDoesNotFit() {
    testWidgets('the menu flips instead of covering its trigger', (
      tester,
    ) async {
      // Each scenario gets its own key: without it the element (and its
      // still-open state) would be reused across `pumpIx` calls, and the
      // next tap would close the menu instead of opening it.
      Widget dropdown(
        String name,
        IxDropdownPlacement placement,
        String itemLabel,
      ) {
        return IxDropdownButton<int>(
          key: ValueKey(name),
          label: 'A',
          placement: placement,
          items: [
            for (var i = 0; i < 5; i++)
              IxDropdownMenuItem(label: '$itemLabel $i', value: i),
          ],
        );
      }

      Future<(Rect trigger, Rect menu)> open(WidgetTester tester) async {
        await tester.tap(find.text('A'));
        await tester.pump(const Duration(milliseconds: 200));
        return (
          tester.getRect(find.byType(ElevatedButton)),
          tester.getRect(find.byKey(const Key('ix-dropdown-menu'))),
        );
      }

      // A `bottomStart` trigger 400px down a 600px viewport: the gap below
      // it is wide enough to *start* the menu but not to hold its ~208px,
      // so the menu belongs above the trigger instead of clamped over it.
      await pumpIx(
        tester,
        Column(
          children: [
            const SizedBox(height: 400),
            dropdown(
              'below-does-not-fit',
              IxDropdownPlacement.bottomStart,
              'Item',
            ),
          ],
        ),
        size: const Size(400, 600),
      );
      var (trigger, menu) = await open(tester);
      expect(menu.height, greaterThan(600 - trigger.bottom));
      expect(menu.bottom, lessThanOrEqualTo(trigger.top));
      expect(menu.top, greaterThanOrEqualTo(8));

      // Same on the horizontal axis: a `rightStart` trigger near the right
      // edge opens to its left.
      await pumpIx(
        tester,
        Row(
          children: [
            const SizedBox(width: 600),
            dropdown(
              'right-does-not-fit',
              IxDropdownPlacement.rightStart,
              'A considerably longer item',
            ),
          ],
        ),
        size: const Size(800, 600),
      );
      (trigger, menu) = await open(tester);
      expect(menu.width, greaterThan(800 - trigger.right));
      expect(menu.right, lessThanOrEqualTo(trigger.left));
      expect(menu.left, greaterThanOrEqualTo(8));

      // With room on the preferred side, the menu stays there.
      await pumpIx(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: dropdown(
            'below-fits',
            IxDropdownPlacement.bottomStart,
            'Item',
          ),
        ),
        size: const Size(400, 600),
      );
      (trigger, menu) = await open(tester);
      expect(menu.top, greaterThanOrEqualTo(trigger.bottom));
      expect(menu.bottom, lessThanOrEqualTo(600 - 8));
    });
  }

  placementFlipsWhenTheMenuDoesNotFit();

  @Upstream('dropdown-button.tsx the trigger renders the small chevron glyph')
  void triggerKeepsItsHeightWithA16pxChevron() {
    testWidgets('the trigger chevron is 16px and does not grow the button', (
      tester,
    ) async {
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          items: const [IxDropdownMenuItem(label: 'One', value: 1)],
        ),
      );

      // The visual button box (the button's Material, not the padded
      // `MaterialTapTargetSize` box around it, which is a flat 48px either
      // way). 41px is what the 1.x trigger measured: 12+12 vertical padding
      // from IxButtonTheme around a 17px content row whose tallest item is
      // the 14px/1.2 label line box, just above the 40px `minimumSize`. A
      // 24px chevron box would make the content 24px and the trigger 48px,
      // growing every existing dropdown button, so the glyph stays at 16px.
      final visual = find
          .descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(Material),
          )
          .first;
      expect(tester.getSize(visual).height, 41.0);
      expect(
        tester.getSize(
          find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(IxIcon),
          ),
        ),
        const Size(16, 16),
      );
    });
  }

  triggerKeepsItsHeightWithA16pxChevron();

  @Upstream('dropdown.scss:16-24 the menu honours an explicit max height')
  void maxHeightOverridesTheViewportBudget() {
    testWidgets('maxHeight caps the menu height', (tester) async {
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          maxHeight: 120,
          items: [
            for (var i = 0; i < 30; i++)
              IxDropdownMenuItem(label: 'Item $i', value: i),
          ],
        ),
        size: const Size(800, 600),
      );
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        tester.getRect(find.byKey(const Key('ix-dropdown-menu'))).height,
        120,
      );
    });
  }

  maxHeightOverridesTheViewportBudget();

  @Upstream(
    'button.tsx variant mapping; buttonVariant supersedes the '
    'deprecated IxDropdownButtonVariant',
  )
  void buttonVariantTakesPrecedenceOverTheDeprecatedVariant() {
    testWidgets('buttonVariant takes precedence over the deprecated variant', (
      tester,
    ) async {
      final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
      final buttonTheme = theme.extension<IxButtonTheme>()!;
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          // ignore: deprecated_member_use
          variant: IxDropdownButtonVariant.primary,
          buttonVariant: IxButtonVariant.subtleTertiary,
          items: const [IxDropdownMenuItem(label: 'One', value: 1)],
        ),
        theme: theme,
      );

      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style,
        buttonTheme.style(IxButtonVariant.subtleTertiary),
      );
    });
  }

  buttonVariantTakesPrecedenceOverTheDeprecatedVariant();

  @Upstream(
    'dropdown-button.ct.ts:106-133 the trigger carries an accessible '
    'name',
  )
  void semanticLabelOverridesTheTriggerName() {
    testWidgets('semanticLabel replaces the visible label for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: '3',
          semanticLabel: 'Rows per page',
          items: const [IxDropdownMenuItem(label: 'One', value: 1)],
        ),
      );

      expect(
        tester.getSemantics(find.text('3')),
        matchesSemantics(
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Rows per page',
        ),
      );
      handle.dispose();
    });
  }

  semanticLabelOverridesTheTriggerName();

  @Upstream(
    'dropdown.scss:16-24; dropdown-item.scss:13-49,55-71,106-131; '
    '_variables.scss:225 --theme-shadow-4',
  )
  void dropdownThemeIsBuiltFromTheIxPalette() {
    test('IxDropdownTheme.fromPalette maps the Siemens IX tokens', () {
      final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
      final ix = theme.extension<IxTheme>()!;
      final dropdown = theme.extension<IxDropdownTheme>();

      expect(dropdown, isNotNull);
      expect(dropdown!.background, ix.color(IxThemeColorToken.color2));
      expect(dropdown.borderRadius, IxCommonGeometry.defaultBorderRadius);
      expect(dropdown.shadow, hasLength(3));
      expect(dropdown.padding, const EdgeInsets.symmetric(vertical: 4));
      expect(dropdown.itemHeight, 40);
      expect(dropdown.itemPadding, const EdgeInsets.only(left: 8, right: 24));
      expect(dropdown.checkColumnWidth, 24);
      expect(dropdown.itemHover, ix.color(IxThemeColorToken.ghostHover));
      expect(dropdown.itemActive, ix.color(IxThemeColorToken.ghostActive));
      expect(dropdown.itemDisabledText, ix.color(IxThemeColorToken.weakText));
      expect(dropdown.itemFocusBorder, ix.color(IxThemeColorToken.focusBdr));
      expect(dropdown.itemText, ix.color(IxThemeColorToken.stdText));
      expect(dropdown.itemTextStyle.fontSize, ix.typography.body.fontSize);

      final other = dropdown.copyWith(itemHeight: 64);
      expect(other.itemHeight, 64);
      expect(other.background, dropdown.background);
      expect(dropdown.lerp(other, 1).itemHeight, 64);
      expect(dropdown.lerp(null, 1).itemHeight, dropdown.itemHeight);
    });
  }

  dropdownThemeIsBuiltFromTheIxPalette();
}
