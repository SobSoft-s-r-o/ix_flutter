import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:archive/archive.dart';

/// Icon generator for Siemens iX Design System icons.
///
/// Downloads icons from the official npm package and generates
/// Flutter-compatible icon widgets.
class IconGenerator {
  static const _packageName = '@siemens/ix-icons';
  static const _packageVersion = '3.2.0';
  static const _npmRegistryUrl = 'https://registry.npmjs.org';

  /// Generates icon assets and Dart code from the Siemens iX icons npm package.
  ///
  /// [outputDir] - Directory where the generated Dart file will be written
  /// [assetsDir] - Directory where SVG assets will be copied
  /// [flutterPackageName] - Optional package name for cross-package asset loading
  /// [client] - Optional HTTP client for testing
  static Future<void> generateIcons({
    required String outputDir,
    required String assetsDir,
    String? flutterPackageName,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();

    try {
      print('Starting icon generation...');
      await _ensureDirectoryExists(outputDir);
      await _ensureDirectoryExists(assetsDir);

      // Calculate the relative asset path - always use forward slashes for Flutter assets
      final normalizedAssetsDir = path.normalize(assetsDir);

      // Find common ancestor and calculate relative path from root
      String relativeAssetsPath;
      if (path.isAbsolute(normalizedAssetsDir)) {
        // Get the parts after the project root
        final parts = path.split(normalizedAssetsDir);
        final assetsIndex = parts.indexOf('assets');
        if (assetsIndex >= 0) {
          relativeAssetsPath = parts.sublist(assetsIndex).join('/');
        } else {
          // Fallback: use basename
          relativeAssetsPath = 'assets/${path.basename(normalizedAssetsDir)}';
        }
      } else {
        // Already relative
        relativeAssetsPath = normalizedAssetsDir.replaceAll('\\', '/');
      }

      // Download and extract the npm package
      print('Downloading package $_packageName@$_packageVersion...');
      final tempDir = await _downloadAndExtractPackage(httpClient);

      try {
        // Find the SVG directory in the extracted package
        final svgDir = Directory(path.join(tempDir.path, 'package', 'svg'));
        if (!await svgDir.exists()) {
          throw Exception(
            'SVG directory not found in package at ${svgDir.path}',
          );
        }

        print('Found SVG directory at ${svgDir.path}');

        // Clear existing SVG assets
        await _clearExistingSvgAssets(assetsDir);

        // Process all SVG files
        final iconClassBuffer = StringBuffer();
        iconClassBuffer.writeln('// GENERATED FILE - DO NOT EDIT');
        iconClassBuffer.writeln("import 'package:flutter/widgets.dart';");
        iconClassBuffer.writeln(
          "import 'package:flutter_svg/flutter_svg.dart';",
        );
        iconClassBuffer.writeln('');
        iconClassBuffer.writeln('/// Siemens iX Design System Icons');
        iconClassBuffer.writeln('class IxIcons {');
        iconClassBuffer.writeln('  IxIcons._();');
        iconClassBuffer.writeln('');
        if (flutterPackageName != null) {
          iconClassBuffer.writeln(
            "  static const _assetPackage = '$flutterPackageName';",
          );
        } else {
          iconClassBuffer.writeln(
            "  static const String? _assetPackage = null;",
          );
        }
        iconClassBuffer.writeln('');

        var generatedCount = 0;
        final svgFiles = await _getSvgFiles(svgDir);

        print('Found ${svgFiles.length} SVG files');

        for (final svgFile in svgFiles) {
          final fileName = path.basename(svgFile.path);
          var svgContent = await svgFile.readAsString();

          if (!svgContent.contains('<svg')) {
            print('Skipping $fileName - invalid SVG content');
            continue;
          }

          // Clean SVG content to allow proper coloring
          svgContent = _cleanSvgContent(svgContent);

          // Copy cleaned SVG to assets directory
          final assetFile = File(path.join(assetsDir, fileName));
          await assetFile.writeAsString(svgContent);

          // Generate icon constant
          final iconName = ReCase(
            path.basenameWithoutExtension(fileName),
          ).camelCase;
          iconClassBuffer.writeln("  /// Icon: $fileName");
          iconClassBuffer.writeln(
            "  static Widget get $iconName => const _IxIconWidget(",
          );
          iconClassBuffer.writeln("    '$relativeAssetsPath/$fileName',");
          iconClassBuffer.writeln('  );');
          iconClassBuffer.writeln('');
          generatedCount++;
        }

        if (generatedCount == 0) {
          throw Exception('No valid SVG icons could be generated.');
        }

        iconClassBuffer.writeln('}');
        iconClassBuffer.writeln('');
        iconClassBuffer.writeln(
          'class _IxIconWidget extends StatelessWidget {',
        );
        iconClassBuffer.writeln('  const _IxIconWidget(this.assetPath);');
        iconClassBuffer.writeln('');
        iconClassBuffer.writeln('  final String assetPath;');
        iconClassBuffer.writeln('');
        iconClassBuffer.writeln('  @override');
        iconClassBuffer.writeln('  Widget build(BuildContext context) {');
        iconClassBuffer.writeln('    final iconTheme = IconTheme.of(context);');
        iconClassBuffer.writeln(
          '    final resolvedSize = iconTheme.size ?? 24;',
        );
        iconClassBuffer.writeln('    final resolvedColor = iconTheme.color;');
        iconClassBuffer.writeln('');
        iconClassBuffer.writeln('    return SvgPicture.asset(');
        iconClassBuffer.writeln('      assetPath,');
        iconClassBuffer.writeln('      width: resolvedSize,');
        iconClassBuffer.writeln('      height: resolvedSize,');
        iconClassBuffer.writeln('      package: IxIcons._assetPackage,');
        iconClassBuffer.writeln('      colorFilter: resolvedColor == null');
        iconClassBuffer.writeln('          ? null');
        iconClassBuffer.writeln(
          '          : ColorFilter.mode(resolvedColor, BlendMode.srcIn),',
        );
        iconClassBuffer.writeln('    );');
        iconClassBuffer.writeln('  }');
        iconClassBuffer.writeln('}');
        final outputFile = File(path.join(outputDir, 'ix_icons.dart'));
        await outputFile.writeAsString(iconClassBuffer.toString());

        print('Generated $generatedCount icons');
        print('Output file: ${outputFile.path}');
      } finally {
        // Clean up temporary directory
        await tempDir.delete(recursive: true);
        print('Cleaned up temporary files');
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Download the npm package and extract it to a temporary directory
  static Future<Directory> _downloadAndExtractPackage(
    http.Client client,
  ) async {
    // Get package metadata from npm registry
    final metadataUrl = '$_npmRegistryUrl/$_packageName';
    print('Fetching package metadata from $metadataUrl');

    final metadataResponse = await client.get(Uri.parse(metadataUrl));
    if (metadataResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch package metadata: ${metadataResponse.statusCode}',
      );
    }

    // Parse JSON response
    final Map<String, dynamic> packageData = json.decode(metadataResponse.body);

    // Navigate to the specific version
    final versions = packageData['versions'] as Map<String, dynamic>?;
    if (versions == null || !versions.containsKey(_packageVersion)) {
      // List available versions for debugging
      final availableVersions = versions?.keys.toList() ?? [];
      print(
        'Available versions: ${availableVersions.take(10).join(", ")}${availableVersions.length > 10 ? "..." : ""}',
      );
      throw Exception('Version $_packageVersion not found in package metadata');
    }

    final versionData = versions[_packageVersion] as Map<String, dynamic>;
    final dist = versionData['dist'] as Map<String, dynamic>?;

    if (dist == null || !dist.containsKey('tarball')) {
      throw Exception('Tarball URL not found in version metadata');
    }

    final tarballUrl = dist['tarball'] as String;
    print('Downloading tarball from $tarballUrl');

    // Download the tarball
    final tarballResponse = await client.get(Uri.parse(tarballUrl));
    if (tarballResponse.statusCode != 200) {
      throw Exception(
        'Failed to download tarball: ${tarballResponse.statusCode}',
      );
    }

    print('Downloaded ${tarballResponse.bodyBytes.length} bytes');

    // Create temporary directory
    final tempDir = await Directory.systemTemp.createTemp('ix_icons_');

    // Extract the tarball
    print('Extracting package to ${tempDir.path}');
    final archive = TarDecoder().decodeBytes(
      GZipDecoder().decodeBytes(tarballResponse.bodyBytes),
    );

    for (final file in archive) {
      final filename = path.join(tempDir.path, file.name);
      if (file.isFile) {
        final outputFile = File(filename);
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filename).create(recursive: true);
      }
    }

    print('Extraction complete');
    return tempDir;
  }

  /// Clean SVG content to allow proper rendering and coloring
  static String _cleanSvgContent(String svgContent) {
    var cleaned = svgContent;

    // Remove fill="white" or fill="#ffffff" or fill="#fff" (case insensitive)
    // Using \x27 for single quote and \x22 for double quote in raw strings
    cleaned = cleaned.replaceAll(
      RegExp(
        r'fill\s*=\s*[\x22\x27]#?(?:fff(?:fff)?|white)[\x22\x27]',
        caseSensitive: false,
      ),
      '',
    );

    // Remove stroke="white" or stroke="#ffffff"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'stroke\s*=\s*[\x22\x27]#?(?:fff(?:fff)?|white)[\x22\x27]',
        caseSensitive: false,
      ),
      '',
    );

    // Remove fill="none" to allow coloring
    cleaned = cleaned.replaceAll(
      RegExp(r'fill\s*=\s*[\x22\x27]none[\x22\x27]'),
      '',
    );

    return cleaned;
  }

  /// Recursively get all SVG files from a directory
  static Future<List<File>> _getSvgFiles(Directory dir) async {
    final svgFiles = <File>[];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.svg')) {
        svgFiles.add(entity);
      }
    }

    svgFiles.sort((a, b) => a.path.compareTo(b.path));
    return svgFiles;
  }

  static Future<void> _clearExistingSvgAssets(String assetsDir) async {
    final directory = Directory(assetsDir);
    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.svg')) {
        await entity.delete();
      }
    }
  }

  static Future<void> _ensureDirectoryExists(String pathToEnsure) async {
    final directory = Directory(pathToEnsure);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}
