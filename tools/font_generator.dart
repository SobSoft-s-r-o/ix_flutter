import 'dart:io';

import 'package:path/path.dart' as p;

/// Copies Siemens IX font files required for Flutter from the brand source
/// directory into the package assets folder.
class FontGenerator {
  static const String _sourceDir = 'brand_theme_source/fonts';
  static const String _outputDir = 'assets/fonts';

  static Future<void> copyFonts() async {
    final source = Directory(_sourceDir);
    if (!await source.exists()) {
      print('Font source directory not found: ${source.path}');
      return;
    }

    final output = Directory(_outputDir);
    await output.create(recursive: true);

    final copiedFiles = <String>[];
    final files = source.listSync().whereType<File>().where(
      (file) => p.extension(file.path).toLowerCase() == '.ttf',
    );

    for (final file in files) {
      final targetPath = p.join(output.path, p.basename(file.path));
      await file.copy(targetPath);
      copiedFiles.add(p.basename(targetPath));
    }

    if (copiedFiles.isEmpty) {
      print('No TTF fonts found to copy.');
    } else {
      print('Copied ${copiedFiles.length} font(s): ${copiedFiles.join(', ')}');
    }
  }
}
