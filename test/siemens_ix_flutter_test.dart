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
      theme.chipTheme.side,
      const BorderSide(color: Colors.transparent, width: 0),
    );
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
    expect(
      primary.closeHoverBackground,
      ixTheme.color(IxThemeColorToken.ghostHover),
    );

    final warningOutline = ixChips.statusStyle(
      IxChipStatus.warning,
      outline: true,
    );
    expect(
      warningOutline.borderColor,
      ixTheme.color(IxThemeColorToken.warning),
    );
    expect(
      warningOutline.closeActiveBackground,
      ixTheme.color(IxThemeColorToken.ghostActive),
    );
  });

  test('wires Siemens IX card theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixCards = theme.extension<IxCardTheme>();

    expect(ixCards, isNotNull);
    expect(theme.cardTheme, same(ixCards!.materialCardTheme));

    final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
    expect(shape, isNotNull);
    final radii = shape!.borderRadius.resolve(TextDirection.ltr);
    expect(radii.topLeft.x, closeTo(4, 0.001));

    expect(ixCards.borderWidth, closeTo(1, 0.001));
    expect(ixCards.focusOutlineOffset, closeTo(2, 0.001));

    final outline = ixCards.style(IxCardVariant.outline);
    expect(outline.borderColor, ixTheme.color(IxThemeColorToken.softBdr));
    expect(
      outline.hoverBackground,
      ixTheme.color(IxThemeColorToken.ghostHover),
    );

    final filled = ixCards.style(IxCardVariant.filled);
    expect(
      filled.selectedBackground,
      ixTheme.color(IxThemeColorToken.ghostSelected),
    );

    final alarm = ixCards.style(IxCardVariant.alarm);
    expect(alarm.background, ixTheme.color(IxThemeColorToken.alarm));
    expect(alarm.foreground, ixTheme.color(IxThemeColorToken.alarmContrast));
    expect(alarm.selectedBorderColor, ixTheme.color(IxThemeColorToken.dynamic));
  });

  test('wires Siemens IX tabs theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixTabs = theme.extension<IxTabsTheme>();

    expect(ixTabs, isNotNull);
    expect(theme.tabBarTheme, same(ixTabs!.materialTabTheme));

    final indicator = theme.tabBarTheme.indicator as UnderlineTabIndicator?;
    expect(indicator, isNotNull);
    expect(indicator!.borderSide.width, closeTo(ixTabs.indicatorHeight, 0.001));
    expect(
      ixTabs.tab.background.hover,
      ixTheme.color(IxThemeColorToken.ghostPrimaryHover),
    );
    expect(
      ixTabs.circle.border.selected,
      ixTheme.color(IxThemeColorToken.dynamic),
    );
    expect(ixTabs.circleDiameter, closeTo(48, 0.001));
    expect(ixTabs.tabPadding.horizontal, closeTo(48, 0.001));
    expect(ixTabs.materialTabTheme.labelStyle?.fontWeight, FontWeight.w700);
    final overlay = ixTabs.materialTabTheme.overlayColor!;
    expect(overlay.resolve(<WidgetState>{}), ixTabs.tab.background.base);
    expect(
      overlay.resolve(<WidgetState>{WidgetState.hovered}),
      ixTabs.tab.background.hover,
    );
    expect(
      overlay.resolve(<WidgetState>{WidgetState.pressed}),
      ixTabs.tab.background.active,
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

  test('wires Siemens IX modal theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixModal = theme.extension<IxModalTheme>();

    expect(ixModal, isNotNull);
    final dialogTheme = theme.dialogTheme;
    expect(dialogTheme.backgroundColor, ixModal!.backgroundColor);

    final shape = dialogTheme.shape as RoundedRectangleBorder?;
    expect(shape, isNotNull);
    final radii = shape!.borderRadius.resolve(TextDirection.ltr);
    expect(radii.topLeft.x, closeTo(ixModal.borderRadius, 0.001));

    final EdgeInsets? inset = dialogTheme.insetPadding;
    expect(inset?.left, closeTo(ixModal.dialogPadding, 0.001));
    expect(ixModal.size(IxModalSize.md).width, 600);
    expect(ixModal.shadow.length, greaterThanOrEqualTo(1));
  });

  test('wires Siemens IX scrollbar theme', () {
    const builder = IxThemeBuilder(
      family: IxThemeFamily.brand,
      mode: ThemeMode.light,
    );

    final theme = builder.build();
    final ixTheme = theme.extension<IxTheme>()!;
    final ixScrollbar = theme.extension<IxScrollbarTheme>();

    expect(ixScrollbar, isNotNull);
    expect(theme.scrollbarTheme, same(ixScrollbar!.materialScrollbarTheme));

    final thumb = theme.scrollbarTheme.thumbColor!;
    expect(
      thumb.resolve(<WidgetState>{}),
      ixTheme.color(IxThemeColorToken.component4),
    );
    expect(
      thumb.resolve(<WidgetState>{WidgetState.hovered}),
      ixTheme.color(IxThemeColorToken.component5),
    );
    expect(
      thumb.resolve(<WidgetState>{WidgetState.pressed}),
      ixTheme.color(IxThemeColorToken.component6),
    );

    final trackBorder = theme.scrollbarTheme.trackBorderColor!;
    expect(
      trackBorder.resolve(<WidgetState>{WidgetState.hovered}),
      ixTheme.color(IxThemeColorToken.softBdr),
    );
    expect(
      trackBorder.resolve(<WidgetState>{WidgetState.pressed}),
      ixTheme.color(IxThemeColorToken.stdBdr),
    );

    final thickness = theme.scrollbarTheme.thickness!;
    expect(
      thickness.resolve(<WidgetState>{}),
      closeTo(ixScrollbar.baseThickness, 0.001),
    );
    expect(
      thickness.resolve(<WidgetState>{WidgetState.hovered}),
      closeTo(ixScrollbar.hoverThickness, 0.001),
    );
    expect(
      thickness.resolve(<WidgetState>{WidgetState.pressed}),
      closeTo(ixScrollbar.activeThickness, 0.001),
    );
  });
}
