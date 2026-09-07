import 'dart:io';

void main() {
  final dir = Directory('screenshots');
  final pngs = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))
      .toList();
  final errors = <String>[];
  if (pngs.length < 2 || pngs.length > 4) {
    errors.add('expected 2-4 PNG screenshots, found ${pngs.length}');
  }
  for (final f in pngs) {
    final b = f.readAsBytesSync();
    final width = (b[16] << 24) | (b[17] << 16) | (b[18] << 8) | b[19];
    if (width < 1280) {
      errors.add('${f.path}: width $width < 1280');
    }
  }
  final pubspec = File('pubspec.yaml').readAsStringSync();
  for (final f in pngs) {
    if (!pubspec.contains('path: screenshots/${f.uri.pathSegments.last}')) {
      errors.add('${f.path} not listed in pubspec screenshots');
    }
  }
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('screenshots OK (${pngs.length})');
}
