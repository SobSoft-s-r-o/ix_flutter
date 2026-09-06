import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled fonts so goldens and text-width measurements use real
/// glyphs instead of the test Ahem font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('Roboto Mono', [
    'assets/fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
    'assets/fonts/Roboto_Mono/static/RobotoMono-Bold.ttf',
  ]);
  await _loadFont('JetBrains Mono', [
    'assets/fonts/JetBrains_Mono/static/JetBrainsMono-Regular.ttf',
    'assets/fonts/JetBrains_Mono/static/JetBrainsMono-Bold.ttf',
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
