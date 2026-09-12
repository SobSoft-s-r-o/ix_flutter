import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled fonts (copied from `packages/ix_flutter/test/flutter_test_config.dart`,
/// C-2) so goldens, text measurements and the pub.dev screenshots use real
/// glyphs instead of the test-harness Ahem font.
///
/// Roboto Mono and JetBrains Mono mirror the package's own test config (the
/// real 1.x default typeface, per `IxTypography()`'s default). Work Sans is
/// loaded in addition, under its package-prefixed family name, because
/// `screenshots_test.dart` explicitly opts into it for the pub.dev
/// screenshots -- it is the bundled Work Sans family the package ships, and
/// becomes the 2.0 default, but stays opt-in pre-2.0.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await materialIcons.load();
  await _loadFont('Roboto Mono', [
    '../packages/ix_flutter/assets/fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
    '../packages/ix_flutter/assets/fonts/Roboto_Mono/static/RobotoMono-Bold.ttf',
  ]);
  await _loadFont('JetBrains Mono', [
    '../packages/ix_flutter/assets/fonts/JetBrains_Mono/static/JetBrainsMono-Regular.ttf',
    '../packages/ix_flutter/assets/fonts/JetBrains_Mono/static/JetBrainsMono-Bold.ttf',
  ]);
  // Registered under the `package:` prefixed family name IxTypography
  // resolves to (see typography_test.dart's "Work Sans opt-in uses the
  // package prefix"), so a TextStyle built with
  // IxTypography(fontFamily: IxFonts.workSans, package: IxFonts.packageName)
  // matches this loaded font instead of falling back to Ahem.
  await _loadFont('packages/ix_flutter/Work Sans', [
    '../packages/ix_flutter/assets/fonts/Work_Sans/static/WorkSans-Regular.ttf',
    '../packages/ix_flutter/assets/fonts/Work_Sans/static/WorkSans-Bold.ttf',
  ]);
  await testMain();
}

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File(file).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}
