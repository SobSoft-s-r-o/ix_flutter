import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

import 'package:ix_icons_generator/ix_icons_generator.dart';
import 'package:ix_icons_generator/src/pubspec_asset_updater.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'project-root',
      abbr: 'p',
      help: 'Root directory of the Flutter project',
      defaultsTo: Directory.current.path,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help:
          'Output directory for generated Dart code (relative to project root)',
      defaultsTo: 'lib',
    )
    ..addOption(
      'assets',
      abbr: 'a',
      help: 'Assets directory for SVG files (relative to project root)',
      defaultsTo: 'assets/svg',
    )
    ..addOption(
      'package',
      abbr: 'n',
      help: 'Package name (leave empty if icons are in the same package)',
    )
    ..addOption(
      'icons-version',
      defaultsTo: IconGenerator.defaultIconsVersion,
      help: 'Version of @siemens/ix-icons to download',
    )
    ..addFlag(
      'legacy-getters',
      defaultsTo: true,
      help: 'Emit deprecated IxIcons widget getters',
    )
    ..addFlag(
      'format',
      defaultsTo: true,
      help: 'Run "dart format" on the generated file',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Siemens iX Icons Generator');
      print('');
      print('Usage: dart run ix_icons_generator:generate_icons [options]');
      print('');
      print('Options:');
      print(parser.usage);
      exit(0);
    }

    final projectRoot = path.normalize(results['project-root'] as String);
    final outputDir = path.join(projectRoot, results['output'] as String);
    final assetsDir = path.join(projectRoot, results['assets'] as String);
    final packageName = results['package'] as String?;
    final iconsVersion = results['icons-version'] as String;
    final legacyGetters = results['legacy-getters'] as bool;
    final format = results['format'] as bool;

    print('Project root: $projectRoot');
    print('Output directory: $outputDir');
    print('Assets directory: $assetsDir');
    print('Icons version: $iconsVersion');
    if (packageName != null && packageName.isNotEmpty) {
      print('Package name: $packageName');
    } else {
      print('Package name: <current package>');
    }
    print('');

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
    await IconGenerator.generateIcons(
      outputDir: outputDir,
      assetsDir: assetsDir,
      flutterPackageName: packageName?.isNotEmpty == true ? packageName : null,
      iconsVersion: iconsVersion,
      legacyGetters: legacyGetters,
      format: format,
    );

    // Update pubspec.yaml to include assets
    await _updatePubspec(
      projectRoot,
      path.relative(assetsDir, from: projectRoot),
    );

    print('\n✓ Icon generation completed successfully!');
    print('');
    print('Next steps:');
    print('1. Make sure your pubspec.yaml includes:');
    print('   flutter:');
    print('     assets:');
    print('       - ${path.relative(assetsDir, from: projectRoot)}/');
    print('2. Run: flutter pub get');
    print('3. Use: IxIcon(IxIconsData.about)');
    print(
      '4. Keep LICENSE.md and READMEOSS.html with the generated SVGs when '
      'redistributing them',
    );
    exit(0);
  } catch (e, stackTrace) {
    print('\n✗ Error during icon generation:');
    print(e);
    if (e is! FormatException) {
      print(stackTrace);
    }
    exit(1);
  }
}

Future<void> _updatePubspec(String projectRoot, String assetsPath) async {
  final pubspecPath = path.join(projectRoot, 'pubspec.yaml');
  final pubspecFile = File(pubspecPath);

  if (!await pubspecFile.exists()) {
    print('Warning: pubspec.yaml not found at $pubspecPath');
    return;
  }

  final pubspecContent = await pubspecFile.readAsString();
  final updatedContent = PubspecAssetUpdater.addAsset(
    pubspecContent,
    assetsPath,
  );
  if (updatedContent == pubspecContent) {
    print('Assets path already in pubspec.yaml');
    return;
  }

  await pubspecFile.writeAsString(updatedContent);
  print('Added assets path to pubspec.yaml');
}
