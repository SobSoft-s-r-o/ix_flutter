import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

/// Drives Siemens IX theme configuration for the demo application.
class ThemeController extends ChangeNotifier {
  IxThemeFamily _family = IxThemeFamily.classic;
  ThemeMode _mode = ThemeMode.light;

  static final IxCustomPalette _demoPalette = IxCustomPalette.override(
    lightOverrides: {
      IxThemeColorToken.primary: const Color(0xFF0050F5),
      IxThemeColorToken.dynamic: const Color(0xFF00B59B),
      IxThemeColorToken.color1: const Color(0xFFFAF5FF),
      IxThemeColorToken.color3: const Color(0xFFE8DFF6),
    },
    darkOverrides: {
      IxThemeColorToken.primary: const Color(0xFF82A0FF),
      IxThemeColorToken.dynamic: const Color(0xFF4FE0C2),
      IxThemeColorToken.color1: const Color(0xFF090B14),
      IxThemeColorToken.color3: const Color(0xFF141828),
    },
  );

  IxThemeFamily get family => _family;
  ThemeMode get mode => _mode;

  void setFamily(IxThemeFamily value) {
    if (value == _family) {
      return;
    }
    _family = value;
    notifyListeners();
  }

  void setMode(ThemeMode value) {
    if (value == _mode) {
      return;
    }
    _mode = value;
    notifyListeners();
  }

  ThemeData buildTheme(ThemeMode target) {
    final builder = IxThemeBuilder(
      family: _family,
      mode: target,
      systemBrightness: target == ThemeMode.dark
          ? Brightness.dark
          : Brightness.light,
      customPalette: _family == IxThemeFamily.custom ? _demoPalette : null,
    );
    return builder.build();
  }
}

/// Exposes the [ThemeController] down the widget tree.
class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in widget tree.');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(ThemeControllerScope oldWidget) =>
      notifier != oldWidget.notifier;
}
