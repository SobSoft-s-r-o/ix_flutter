import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralizes edge-to-edge configuration for the demo application.
class EdgeToEdge {
  const EdgeToEdge._();

  /// Enables Flutter's edge-to-edge system UI mode and applies a themed overlay.
  static Future<void> configureSystemUi({
    Brightness brightness = Brightness.light,
  }) async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    final fallbackTheme = ThemeData(brightness: brightness);
    SystemChrome.setSystemUIOverlayStyle(overlayStyleFor(fallbackTheme));
  }

  /// Returns a [SystemUiOverlayStyle] whose colors follow the current theme.
  static SystemUiOverlayStyle overlayStyleFor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;
    final statusColor = _statusBarColor(theme);
    final navColor = _navigationBarColor(theme);

    return SystemUiOverlayStyle(
      statusBarColor: statusColor,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: navColor,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: true,
    );
  }

  /// Adds the current bottom view padding to a base [EdgeInsets].
  static EdgeInsets scrollPadding(
    BuildContext context, {
    EdgeInsets base = const EdgeInsets.all(24),
    double additionalBottom = 0,
  }) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return base.copyWith(bottom: base.bottom + bottomInset + additionalBottom);
  }

  static Color _statusBarColor(ThemeData theme) {
    final scheme = theme.colorScheme;
    final double opacity = theme.brightness == Brightness.dark ? 0.0 : 0.08;
    return scheme.surface.withValues(alpha: opacity);
  }

  static Color _navigationBarColor(ThemeData theme) {
    final scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color base = scheme.surface;
    final Color overlay = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final Color blended = Color.alphaBlend(overlay, base);
    final double opacity = isDark ? 0.9 : 0.96;
    return blended.withValues(alpha: opacity);
  }
}
