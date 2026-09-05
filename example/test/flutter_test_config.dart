import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled fonts (copied from `packages/ix_flutter/test/flutter_test_config.dart`,
/// C-2) so goldens, text measurements and the pub.dev screenshots use real
/// glyphs instead of the test-harness Ahem font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('Roboto Mono', [
    '../packages/ix_flutter/assets/fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
    '../packages/ix_flutter/assets/fonts/Roboto_Mono/static/RobotoMono-Bold.ttf',
  ]);
  await _loadFont('JetBrains Mono', [
    '../packages/ix_flutter/assets/fonts/JetBrains_Mono/static/JetBrainsMono-Regular.ttf',
    '../packages/ix_flutter/assets/fonts/JetBrains_Mono/static/JetBrainsMono-Bold.ttf',
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
