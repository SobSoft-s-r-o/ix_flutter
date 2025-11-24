import 'package:flutter_test/flutter_test.dart';

import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_colors/theme/ix_classic_dark_colors.dart';
import 'package:siemens_ix_flutter/src/ix_colors/theme/ix_classic_light_colors.dart';

void main() {
  group('IxThemeColorToken consistency', () {
    final allTokens = IxThemeColorToken.values.toSet();

    test('classic light and dark palettes cover every token', () {
      final classicLightKeys = IxClassicLightColors.palette.keys.toSet();
      final classicDarkKeys = IxClassicDarkColors.palette.keys.toSet();

      expect(classicLightKeys, equals(allTokens));
      expect(classicDarkKeys, equals(allTokens));
    });
  });
}
