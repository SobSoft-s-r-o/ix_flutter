import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_dark_colors.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_light_colors.dart';

import '../helpers/upstream.dart';

/// The enum → CSS name map is derived from the doc comments in the
/// generated palettes (`/// CSS Variable: --theme-color-…`).
Map<IxThemeColorToken, String> _cssNames(String dartFile) {
  final src = File(dartFile).readAsStringSync();
  final re = RegExp(
    r'/// CSS Variable: (--theme-color-[a-z0-9-]+)\s+static const Color (\w+) =',
  );
  final byName = {for (final t in IxThemeColorToken.values) t.name: t};
  return {
    for (final m in re.allMatches(src)) byName[m.group(2)!]!: m.group(1)!,
  };
}

String _argb(Color c) =>
    c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

void main() {
  // Metadata annotations can only precede a declaration, not a bare `for`
  // statement, so the @Upstream-tagged matrix is wrapped in a local function
  // that is invoked immediately below it (same convention as the C-2 red
  // matrices).
  @Upstream(
    'packages/core/scss/theme/classic/{light,dark}/_variables.scss @ 5.2.1',
  )
  void classicPaletteEqualsUpstreamSnapshot() {
    for (final mode in const ['light', 'dark']) {
      test('classic $mode palette equals upstream 5.2.1 snapshot', () {
        final dartFile =
            'lib/src/ix_colors/theme/ix_classic_${mode}_colors.dart';
        final palette = mode == 'light'
            ? IxClassicLightColors.palette
            : IxClassicDarkColors.palette;
        final snapshot =
            (json.decode(
                      File(
                        'test/fixtures/upstream_classic_$mode.json',
                      ).readAsStringSync(),
                    )
                    as Map<String, dynamic>)
                .cast<String, String>();
        final names = _cssNames(dartFile);

        expect(names.length, IxThemeColorToken.values.length);
        final mismatches = <String>[];
        for (final entry in names.entries) {
          final expected = snapshot[entry.value];
          final actual = _argb(palette[entry.key]!);
          if (expected != actual) {
            mismatches.add('${entry.value}: local $actual, upstream $expected');
          }
        }
        expect(mismatches, isEmpty, reason: mismatches.join('\n'));
      });
    }
  }

  classicPaletteEqualsUpstreamSnapshot();
}
