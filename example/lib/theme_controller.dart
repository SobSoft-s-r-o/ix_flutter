import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

/// Drives Siemens IX theme configuration for the demo application.
class ThemeController extends ChangeNotifier {
  IxThemeFamily _family = IxThemeFamily.brand;
  ThemeMode _mode = ThemeMode.light;

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
