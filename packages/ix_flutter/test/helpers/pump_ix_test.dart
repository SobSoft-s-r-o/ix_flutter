import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'pump_ix.dart';

void main() {
  testWidgets(
    'pumpIx applies IxTheme, size, text scale and disables animations',
    (tester) async {
      late BuildContext captured;
      await pumpIx(
        tester,
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
        size: const Size(360, 800),
        textScaler: const TextScaler.linear(2.0),
      );

      expect(Theme.of(captured).extension<IxTheme>(), isNotNull);
      expect(MediaQuery.disableAnimationsOf(captured), isTrue);
      expect(MediaQuery.sizeOf(captured), const Size(360, 800));
      expect(MediaQuery.textScalerOf(captured).scale(10), 20);
    },
  );
}
