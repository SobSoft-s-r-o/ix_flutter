import 'package:flutter/material.dart';

/// Runtime helpers for Siemens IX sizing primitives sourced from
/// packages/core/scss/theme/core/_common.scss.
@immutable
class IxCommonGeometry {
  const IxCommonGeometry._();

  static const double remInPx = 16.0;

  static double rem(double value) => value * remInPx;

  // Border widths.
  static const double borderWidthNone = 0.0;
  static const double borderWidthDefault = 0.0625 * remInPx;
  static const double borderWidthThick = spaceNeg3;

  // Border radii.
  static const double minBorderRadius = 0.0;
  static const double smallBorderRadius = spaceNeg3;
  static const double defaultBorderRadius = spaceNeg1;

  // Focus affordances.
  static const double focusBorderThickness = 0.0625 * remInPx;
  static const double focusOutlineOffset = spaceNeg3;

  // Control heights from the web tokens.
  static const double controlHeightMedium = 24.0;
  static const double controlHeightDefault = 32.0;
  static const double controlHeightLarge = 40.0;

  // Space tokens (px) sourced from --theme-space.
  static const double spaceNeg3 = 0.125 * remInPx;
  static const double spaceNeg2 = 0.1875 * remInPx;
  static const double spaceNeg1 = 0.25 * remInPx;
  static const double space0 = 0.375 * remInPx;
  static const double space1 = 0.5 * remInPx;
  static const double space2 = 0.75 * remInPx;
  static const double space3 = 1.0 * remInPx;
  static const double space4 = 1.5 * remInPx;
  static const double space5 = 2.0 * remInPx;
  static const double space6 = 3.0 * remInPx;
  static const double space7 = 4.0 * remInPx;
  static const double space8 = 6.0 * remInPx;

  // Container width tokens from --theme-container-size.
  static const double container0 = 15.0 * remInPx;
  static const double container1 = 20.0 * remInPx;
  static const double container2 = 22.5 * remInPx;
  static const double container3 = 30.0 * remInPx;
  static const double container4 = 37.5 * remInPx;
  static const double container5 = 45.0 * remInPx;
  static const double container6 = 52.5 * remInPx;

  // Modular scale tokens from --theme-ms.
  static const double modularScaleNeg2 = 0.625 * remInPx;
  static const double modularScaleNeg1 = 0.75 * remInPx;
  static const double modularScale0 = 0.875 * remInPx;
  static const double modularScale1 = 1.0 * remInPx;
  static const double modularScale2 = 1.25 * remInPx;
  static const double modularScale3 = 1.5 * remInPx;
  static const double modularScale4 = 1.8125 * remInPx;
  static const double modularScale5 = 2.1875 * remInPx;
  static const double modularScale6 = 2.625 * remInPx;
  static const double modularScale7 = 3.125 * remInPx;
  static const double modularScale8 = 3.75 * remInPx;

  // Icon sizes.
  static const double iconSizeSmall = space3;
  static const double iconSizeDefault = space4;
  static const double iconSizeLarge = space5;

  // Upload/dropzone primitives from packages/core/src/components/upload/upload.scss.
  static const double uploadMinHeight = space7;
  static const double uploadPadding = space3;

  // Scrollbar primitives to mirror packages/core/scss/_common-variables.scss.
  static const double scrollbarBaseThickness = space0;
  static const double scrollbarHoverThickness = space1;
  static const double scrollbarActiveThickness = modularScaleNeg2;
  static const double scrollbarMargin = spaceNeg3;
  static const double scrollbarRadius = space1;
  static const double scrollbarMinThumbLength = 2.5 * remInPx;

  // Toggle primitives from the same source file.
  static const double toggleThumbDiameter = 1.125 * remInPx;

  // Form field primitives shared across inputs/dropdowns.
  static const double formFieldIconSlot = 2.5 * remInPx;

  static double space(int token) {
    switch (token) {
      case -3:
        return spaceNeg3;
      case -2:
        return spaceNeg2;
      case -1:
        return spaceNeg1;
      case 0:
        return space0;
      case 1:
        return space1;
      case 2:
        return space2;
      case 3:
        return space3;
      case 4:
        return space4;
      case 5:
        return space5;
      case 6:
        return space6;
      case 7:
        return space7;
      case 8:
        return space8;
      default:
        throw ArgumentError('Unsupported Siemens IX space token "$token"');
    }
  }

  /// Returns the friendly EdgeInsets for the provided horizontal/vertical tokens.
  static EdgeInsets spaceInsets({int horizontal = 0, int vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: space(horizontal),
      vertical: space(vertical),
    );
  }

  /// Container width helpers for modal/sheet sizing.
  static double containerWidth(int token) {
    switch (token) {
      case 0:
        return container0;
      case 1:
        return container1;
      case 2:
        return container2;
      case 3:
        return container3;
      case 4:
        return container4;
      case 5:
        return container5;
      case 6:
        return container6;
      default:
        throw ArgumentError('Unsupported Siemens IX container token "$token"');
    }
  }

  /// Modular scale helper for typography-adjacent sizing.
  static double modularScale(int token) {
    switch (token) {
      case -2:
        return modularScaleNeg2;
      case -1:
        return modularScaleNeg1;
      case 0:
        return modularScale0;
      case 1:
        return modularScale1;
      case 2:
        return modularScale2;
      case 3:
        return modularScale3;
      case 4:
        return modularScale4;
      case 5:
        return modularScale5;
      case 6:
        return modularScale6;
      case 7:
        return modularScale7;
      case 8:
        return modularScale8;
      default:
        throw ArgumentError(
          'Unsupported Siemens IX modular scale token "$token"',
        );
    }
  }
}
