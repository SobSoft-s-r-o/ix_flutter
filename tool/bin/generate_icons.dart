import 'dart:io';
import 'package:path/path.dart' as path;

import '../icon_generator.dart';

Future<void> main(List<String> arguments) async {
  // Determine the output directory
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.normalize(path.join(scriptDir, '..', '..'));
  final outputDir = path.join(projectRoot, 'lib', 'src', 'ix_icons');
  final assetsDir = path.join(projectRoot, 'assets', 'svg');

  print('Project root: $projectRoot');
  print('Output directory: $outputDir');
  print('Assets directory: $assetsDir');

  // Create output directory if it doesn't exist
  final outputDirectory = Directory(outputDir);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
    print('Created output directory');
  }

  // Create assets directory if it doesn't exist
  final assetsDirectory = Directory(assetsDir);
  if (!await assetsDirectory.exists()) {
    await assetsDirectory.create(recursive: true);
    print('Created assets directory');
  }

  // Generate icons
  try {
    await IconGenerator.generateIcons(
      outputDir: outputDir,
      assetsDir: assetsDir,
    );
    print('\n✓ Icon generation completed successfully!');
    exit(0);
  } catch (e, stackTrace) {
    print('\n✗ Error during icon generation:');
    print(e);
    print(stackTrace);
    exit(1);
  }
}
