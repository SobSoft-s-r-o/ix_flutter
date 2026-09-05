import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the app-frame spec finding A-7: every user-facing string rendered
/// by [IxApplicationScaffold] must come from `IxApplicationStrings`, so an
/// app can localize the navigation menu without forking the widget. This is
/// a source-level lint over our own file layout, not a mirrored Siemens iX
/// behaviour, so it carries this doc-comment instead of an `@Upstream`
/// citation.
void main() {
  test('no user-facing string literals outside IxApplicationStrings', () {
    final src = File(
      'lib/src/widgets/ix_application_scaffold.dart',
    ).readAsStringSync();
    final literals = RegExp(
      r"'([A-Z][a-z]+(?: [a-z&]+)+)'",
    ).allMatches(src).map((m) => m.group(1)!).toList();
    expect(
      literals,
      isEmpty,
      reason: 'move to IxApplicationStrings: $literals',
    );
  });
}
