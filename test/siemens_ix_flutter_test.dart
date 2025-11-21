import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

void main() {
  test('builds Siemens IX theme with extension', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>();

    expect(ixTheme, isNotNull);
    expect(
      theme.colorScheme.primary,
      ixTheme!.color(IxThemeColorToken.primary),
    );

    final textStyle = ixTheme.textStyle(IxTypographyVariant.body);
    expect(textStyle.fontFamily, IxFonts.siemensSans);
    expect(textStyle.color, ixTheme.textColor(IxThemeTextTone.standard));
  });

  test('provides Siemens IX button styles', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.dark,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixButtons = theme.extension<IxButtonTheme>();

    expect(ixButtons, isNotNull);
    expect(theme.filledButtonTheme.style, same(ixButtons!.primary));

    final secondaryBackground = ixButtons
        .style(IxButtonVariant.secondary)
        .backgroundColor!;
    final baseColor = secondaryBackground.resolve(<WidgetState>{});
    final disabledColor = secondaryBackground.resolve(<WidgetState>{
      WidgetState.disabled,
    });

    expect(baseColor, ixTheme.color(IxThemeColorToken.secondary));
    expect(disabledColor, ixTheme.color(IxThemeColorToken.ghost));
  });

  test('wires Siemens IX app header theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixAppHeader = theme.extension<IxAppHeaderTheme>();

    expect(ixAppHeader, isNotNull);
    expect(
      theme.appBarTheme.backgroundColor,
      ixAppHeader!.appBarTheme.backgroundColor,
    );
    expect(ixAppHeader.titleTextStyle.color, ixAppHeader.foregroundColor);

    final shape = ixAppHeader.appBarTheme.shape as Border?;
    expect(shape?.bottom.color, ixAppHeader.borderColor);
    expect(shape?.bottom.width, ixAppHeader.borderWidth);
  });
}
