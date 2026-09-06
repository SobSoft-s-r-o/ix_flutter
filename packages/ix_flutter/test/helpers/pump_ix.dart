import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// Standard widget wrapper for ix_flutter tests.
///
/// - `disableAnimations: true` stops IxSpinner/Animated* once IxMotion lands
///   (accessibility-interaction plan, Task A-5), allowing pumpAndSettle.
/// - `size` sets the logical viewport (DPR 1) and resets it after the test.
Future<void> pumpIx(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode themeMode = ThemeMode.light,
  bool disableAnimations = true,
  Size size = const Size(1024, 768),
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        disableAnimations: disableAnimations,
        textScaler: textScaler,
      ),
      child: MaterialApp(
        theme: theme ?? const IxThemeBuilder(mode: ThemeMode.light).build(),
        darkTheme:
            darkTheme ?? const IxThemeBuilder(mode: ThemeMode.dark).build(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        builder: (context, app) => Directionality(
          textDirection: textDirection,
          child: app ?? const SizedBox.shrink(),
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
}
