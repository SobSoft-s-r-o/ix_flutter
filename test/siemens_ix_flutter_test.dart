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

    const expectedRadiusPx = 0.125 * 16;
    final shape = ixButtons.style(IxButtonVariant.primary).shape;
    final resolvedShape = shape?.resolve(<WidgetState>{});
    expect(resolvedShape, isA<RoundedRectangleBorder>());
    final borderRadius = (resolvedShape! as RoundedRectangleBorder).borderRadius
        .resolve(TextDirection.ltr);
    expect(borderRadius.topLeft.x, expectedRadiusPx);

    final warningBorder = ixButtons
        .style(IxButtonVariant.warningSecondary)
        .side
        ?.resolve(<WidgetState>{});
    expect(warningBorder, isNotNull);
    expect(warningBorder!.color, ixTheme.color(IxThemeColorToken.warningBdr));

    final successPrimaryBackground = ixButtons
        .style(IxButtonVariant.successPrimary)
        .backgroundColor!
        .resolve(<WidgetState>{});
    expect(successPrimaryBackground, ixTheme.color(IxThemeColorToken.success));

    final infoGhostForeground = ixButtons
        .style(IxButtonVariant.infoTertiary)
        .foregroundColor!
        .resolve(<WidgetState>{});
    expect(infoGhostForeground, ixTheme.color(IxThemeColorToken.info));
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

  test('wires Siemens IX app menu theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixAppMenu = theme.extension<IxAppMenuTheme>();

    expect(ixAppMenu, isNotNull);
    expect(theme.menuTheme, same(ixAppMenu!.menuTheme));
    expect(ixAppMenu.backgroundColor, ixTheme.color(IxThemeColorToken.color2));

    final selectedTextColor = ixAppMenu.itemForeground.resolve(<WidgetState>{
      WidgetState.selected,
    });

    expect(selectedTextColor, ixTheme.color(IxThemeColorToken.primary));
  });

  test('provides icon theming tied to Siemens IX palette', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.classic,
      mode: ThemeMode.dark,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;

    expect(theme.iconTheme.color, ixTheme.color(IxThemeColorToken.stdText));
    expect(
      theme.primaryIconTheme.color,
      ixTheme.color(IxThemeColorToken.contrastText),
    );
    expect(theme.iconTheme.size, 24);
  });

  test('wires Siemens IX chip theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixChips = theme.extension<IxChipTheme>();

    expect(ixChips, isNotNull);
    expect(theme.chipTheme.shape, const StadiumBorder());
    expect(
      theme.chipTheme.backgroundColor,
      ixTheme.color(IxThemeColorToken.component1),
    );

    final primary = ixChips!.variant(IxChipVariant.primary);
    expect(primary.background, ixTheme.color(IxThemeColorToken.primary));
    expect(
      primary.foreground,
      ixTheme.color(IxThemeColorToken.primaryContrast),
    );

    final warningOutline = ixChips.statusStyle(
      IxChipStatus.warning,
      outline: true,
    );
    expect(
      warningOutline.borderColor,
      ixTheme.color(IxThemeColorToken.warning),
    );
  });

  test('wires Siemens IX sidebar theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.dark,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixSidebar = theme.extension<IxSidebarTheme>();

    expect(ixSidebar, isNotNull);
    expect(theme.navigationRailTheme, same(ixSidebar!.navigationRailTheme));
    expect(ixSidebar.backgroundColor, ixTheme.color(IxThemeColorToken.color2));

    final selectedIconColor = ixSidebar.itemIconColor.resolve(<WidgetState>{
      WidgetState.selected,
    });

    expect(selectedIconColor, ixTheme.color(IxThemeColorToken.primary));
  });
}
