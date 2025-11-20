import 'dart:io';
import 'package:path/path.dart' as path;
import '../color_generator.dart';

Future<void> main(List<String> arguments) async {
  // Determine the output directory
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.normalize(path.join(scriptDir, '..', '..'));
  final outputDir = path.join(projectRoot, 'lib', 'src', 'ix_colors', 'theme');

  print('Project root: $projectRoot');
  print('Output directory: $outputDir');

  // Create output directory if it doesn't exist
  final outputDirectory = Directory(outputDir);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
    print('Created output directory');
  }

  // Generate color tokens
  try {
    await ColorGenerator.generateColors(outputDir: outputDir);
    print('\n✓ Color generation completed successfully!');
    exit(0);
  } catch (e, stackTrace) {
    print('\n✗ Error during color generation:');
    print(e);
    print(stackTrace);
    exit(1);
  }
}
