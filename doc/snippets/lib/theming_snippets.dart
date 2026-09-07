import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

(ThemeData light, ThemeData dark) buildBothBrightnesses() =>
    (const IxThemeBuilder.light().build(), const IxThemeBuilder.dark().build());

ThemeData buildDarkClassic() => IxThemeBuilder(
  theme: IxThemeName.classic,
  brightness: Brightness.dark,
  typography: IxTypography(
    fontFamily: IxFonts.workSans,
    package: IxFonts.packageName,
  ),
).build();

class ThemedApp extends StatefulWidget {
  const ThemedApp({super.key});

  @override
  State<ThemedApp> createState() => _ThemedAppState();
}

class _ThemedAppState extends State<ThemedApp> {
  final _theme = IxThemeController(); // defaults to classic + system

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _theme,
    builder: (context, _) => MaterialApp(
      theme: _theme.light,
      darkTheme: _theme.dark,
      themeMode: _theme.themeMode,
      home: const Placeholder(),
    ),
  );
}

IxThemeController controllerWithBrandPrimary() {
  final palette = IxCustomPalette.partial(
    light: {IxThemeColorToken.primary: const Color(0xFF0050F5)},
    dark: {IxThemeColorToken.primary: const Color(0xFF82A0FF)},
  );

  return IxThemeController(customPalette: palette);
}
