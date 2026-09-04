import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every font declared in `pubspec.yaml` must exist on disk, and Work Sans
/// must be declared with 4 static faces (400/700 x normal/italic).
void main() {
  test('pubspec declares Work Sans static faces that exist on disk', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    const faces = [
      'assets/fonts/Work_Sans/static/WorkSans-Regular.ttf',
      'assets/fonts/Work_Sans/static/WorkSans-Bold.ttf',
      'assets/fonts/Work_Sans/static/WorkSans-Italic.ttf',
      'assets/fonts/Work_Sans/static/WorkSans-BoldItalic.ttf',
    ];
    expect(pubspec.contains('family: Work Sans'), isTrue);
    for (final f in faces) {
      expect(pubspec.contains('asset: $f'), isTrue, reason: f);
      expect(File(f).existsSync(), isTrue, reason: f);
    }
  });

  test('every declared font asset exists', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final assets = RegExp(r'asset: (assets/fonts/\S+)').allMatches(pubspec);
    for (final m in assets) {
      expect(File(m.group(1)!).existsSync(), isTrue, reason: m.group(1));
    }
  });
}
