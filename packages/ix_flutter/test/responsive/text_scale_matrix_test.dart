import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Matica šírok × text scale. Widgety, ktoré dnes pretekajú, sú označené
/// skip s ID nálezu; po oprave sa skip odstráni.
///
/// Traceability: upstream `@siemens/ix` nemá pre túto maticu šírok × text
/// scale priamy Playwright `.ct.ts` ani scss/tsx náprotivok (CSS breakpointy
/// vs. Flutter `LayoutBuilder` sa nedajú mapovať 1:1), preto jednotlivé testy
/// necitujú `@Upstream`. Matica stráži nález IXF-024 (WCAG 1.4.4 Resize
/// text) pre `IxDropdownButton`; skip sa odstráni v úlohe A-4/A-2, ktorá
/// spraví jeho label flexibilným.
void main() {
  const widths = [320.0, 360.0, 600.0, 768.0, 1024.0, 1440.0];
  const scales = [1.0, 1.3, 2.0];

  for (final w in widths) {
    for (final s in scales) {
      testWidgets('IxBlind ${w.toInt()}px × $s', (tester) async {
        await pumpIx(
          tester,
          const IxBlind(
            title: 'Long blind title that wraps',
            expanded: true,
            child: Text('x'),
          ),
          size: Size(w, 800),
          textScaler: TextScaler.linear(s),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'IxDropdownButton trigger ${w.toInt()}px × $s',
        (tester) async {
          await pumpIx(
            tester,
            IxDropdownButton<int>(
              label: 'Eine sehr lange Beschriftung für die Aktion',
              items: const [IxDropdownMenuItem(label: 'A', value: 1)],
            ),
            size: Size(w, 800),
            textScaler: TextScaler.linear(s),
          );
          expect(tester.takeException(), isNull);
        },
        skip: w <= 360 || (w <= 768 && s >= 2.0),
      ); // IXF-024 – A-4/A-2 Flexible label
    }
  }
}
