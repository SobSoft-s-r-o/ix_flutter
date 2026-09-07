import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// [IxIconButton]'s size contract: the visual button is a plain
/// [IxIconButtonSize.px] square and the glyph inside it is one step down the
/// [IxIconSize] scale ([IxIconButtonSize.iconSize]), applied through a merged
/// [IconTheme]. Whatever widget is handed to `icon:` -- a Material [Icon] or
/// an [IxIcon] -- has to end up at that same size, otherwise the two
/// documented numbers disagree with each other.
///
/// The upstream web component sizes its icon from CSS on the host element,
/// which has no Flutter-side counterpart to cite, so these tests carry no
/// `@Upstream` tag; the sizes themselves are asserted against
/// [IxIconButtonSize] rather than against literals.
void main() {
  Finder inButton(Finder matching) =>
      find.descendant(of: find.byType(IxIconButton), matching: matching);

  for (final size in IxIconButtonSize.values) {
    testWidgets('IxIconButton(${size.name}) renders an IxIcon glyph at '
        '${size.iconSize.px}px', (tester) async {
      await pumpIx(
        tester,
        IxIconButton(
          size: size,
          icon: const IxIcon.key(IxIconKey.closeSmall),
          tooltip: 'Close',
          onPressed: () {},
        ),
      );
      expect(
        tester.getSize(inButton(find.byType(IxIcon))),
        Size.square(size.iconSize.px),
      );
      expect(
        tester.getSize(inButton(find.byType(Icon))),
        Size.square(size.iconSize.px),
      );
      expect(
        tester.getSize(find.byType(IxIconButton)).shortestSide,
        greaterThanOrEqualTo(size.px),
      );
    });

    testWidgets('IxIconButton(${size.name}) renders a Material Icon at '
        '${size.iconSize.px}px', (tester) async {
      await pumpIx(
        tester,
        IxIconButton(
          size: size,
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () {},
        ),
      );
      expect(
        tester.getSize(inButton(find.byType(Icon))),
        Size.square(size.iconSize.px),
      );
    });
  }

  testWidgets('an explicit IxIconSize still wins inside an IxIconButton', (
    tester,
  ) async {
    // A smaller explicit size than the button's own slot: the button's
    // 32x32 box can hold it, so this isolates the precedence question from
    // the button's fixed size clamping the glyph anyway.
    await pumpIx(
      tester,
      IxIconButton(
        size: IxIconButtonSize.s32,
        icon: const IxIcon.key(IxIconKey.closeSmall, size: IxIconSize.s12),
        tooltip: 'Close',
        onPressed: () {},
      ),
    );
    expect(tester.getSize(inButton(find.byType(IxIcon))), const Size(12, 12));
  });
}
