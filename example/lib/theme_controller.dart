import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// Drives IX Flutter theme configuration for the demo application.
///
/// The theme itself lives in [IxThemeController] (theme name, color schema,
/// light/dark `ThemeData`); this wrapper only adds the demo-only "theme
/// family" switch, which needs a fresh controller whenever the custom palette
/// is switched on or off.
class ThemeController extends ChangeNotifier {
  ThemeController() {
    _ix = _createController(IxColorSchema.light);
  }

  static final IxCustomPalette _demoPalette = IxCustomPalette.partial(
    light: {
      IxThemeColorToken.primary: const Color(0xFF0050F5),
      IxThemeColorToken.dynamic: const Color(0xFF00B59B),
      IxThemeColorToken.color1: const Color(0xFFFAF5FF),
      IxThemeColorToken.color3: const Color(0xFFE8DFF6),
    },
    dark: {
      IxThemeColorToken.primary: const Color(0xFF82A0FF),
      IxThemeColorToken.dynamic: const Color(0xFF4FE0C2),
      IxThemeColorToken.color1: const Color(0xFF090B14),
      IxThemeColorToken.color3: const Color(0xFF141828),
    },
  );

  late IxThemeController _ix;
  // ignore: deprecated_member_use -- Retain the legacy demo family selector.
  IxThemeFamily _family = IxThemeFamily.classic;

  // ignore: deprecated_member_use -- Retain the legacy demo family selector.
  IxThemeFamily get family => _family;
  ThemeMode get mode => _ix.themeMode;

  /// The light theme for the current family.
  ThemeData get light => _ix.light;

  /// The dark theme for the current family.
  ThemeData get dark => _ix.dark;

  // ignore: deprecated_member_use -- Retain the legacy demo family selector.
  void setFamily(IxThemeFamily value) {
    if (value == _family) {
      return;
    }
    _family = value;
    final colorSchema = _ix.colorSchema;
    _disposeController();
    _ix = _createController(colorSchema);
    notifyListeners();
  }

  void setMode(ThemeMode value) => _ix.setColorSchema(switch (value) {
    ThemeMode.light => IxColorSchema.light,
    ThemeMode.dark => IxColorSchema.dark,
    ThemeMode.system => IxColorSchema.system,
  });

  IxThemeController _createController(IxColorSchema colorSchema) {
    return IxThemeController(
      colorSchema: colorSchema,
      // ignore: deprecated_member_use -- Retain the legacy demo family selector.
      customPalette: _family == IxThemeFamily.custom ? _demoPalette : null,
    )..addListener(notifyListeners);
  }

  void _disposeController() {
    _ix.removeListener(notifyListeners);
    _ix.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
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
