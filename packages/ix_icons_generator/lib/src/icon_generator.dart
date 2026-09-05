import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

/// Icon generator for Siemens iX Design System icons.
///
/// Downloads icons from the official npm package and generates an
/// `IxIconsData` catalogue of `IxIconData` constants for `ix_flutter`'s
/// `IxIcon` widget. The generated code never imports `flutter_svg`.
class IconGenerator {
  static const _packageName = '@siemens/ix-icons';

  /// Version of `@siemens/ix-icons` downloaded when no other version is
  /// requested.
  static const String defaultIconsVersion = '3.5.0';

  static const _npmRegistryUrl = 'https://registry.npmjs.org';

  /// Generates icon assets and Dart code from the Siemens iX icons npm package.
  ///
  /// [outputDir] - Directory where the generated Dart file will be written
  /// [assetsDir] - Directory where SVG assets will be copied
  /// [flutterPackageName] - Optional package name for cross-package asset loading
  /// [client] - Optional HTTP client for testing
  /// [iconsVersion] - Version of `@siemens/ix-icons` to download
  /// [legacyGetters] - Also emit the deprecated `IxIcons` widget getters
  static Future<void> generateIcons({
    required String outputDir,
    required String assetsDir,
    String? flutterPackageName,
    http.Client? client,
    String iconsVersion = defaultIconsVersion,
    bool legacyGetters = true,
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
      print('Downloading package $_packageName@$iconsVersion...');
      final (tempDir, shasum) = await _downloadAndExtractPackage(
        httpClient,
        iconsVersion,
      );

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
        final dataClassBuffer = StringBuffer();
        dataClassBuffer.writeln('// GENERATED FILE - DO NOT EDIT');
        dataClassBuffer.writeln(
          '// $_packageName $iconsVersion (tarball sha1 ${shasum ?? 'unknown'})',
        );
        if (legacyGetters) {
          dataClassBuffer.writeln("import 'package:flutter/widgets.dart';");
        }
        dataClassBuffer.writeln("import 'package:ix_flutter/ix_flutter.dart';");
        dataClassBuffer.writeln('');
        dataClassBuffer.writeln(
          '/// Siemens iX icon catalogue as [IxIconData].',
        );
        dataClassBuffer.writeln('class IxIconsData {');
        dataClassBuffer.writeln('  IxIconsData._();');
        dataClassBuffer.writeln('');

        // Deprecated widget getters, only emitted when [legacyGetters] is set.
        final legacyClassBuffer = StringBuffer();
        legacyClassBuffer.writeln(
          '/// Deprecated widget getters (removed in ix_flutter 2.0 / generator 2.0).',
        );
        legacyClassBuffer.writeln('class IxIcons {');
        legacyClassBuffer.writeln('  IxIcons._();');
        legacyClassBuffer.writeln('');

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
          svgContent = cleanSvgContent(svgContent);

          // Copy cleaned SVG to assets directory
          final assetFile = File(path.join(assetsDir, fileName));
          await assetFile.writeAsString(svgContent);

          // Generate icon data constant
          final iconName = ReCase(
            path.basenameWithoutExtension(fileName),
          ).camelCase;
          final packageArgument = flutterPackageName != null
              ? ", package: '$flutterPackageName'"
              : '';
          dataClassBuffer.writeln(
            "  static const IxIconData $iconName = "
            "IxIconData.asset('$relativeAssetsPath/$fileName'$packageArgument);",
          );

          if (legacyGetters) {
            legacyClassBuffer.writeln(
              "  @Deprecated('Use IxIcon(IxIconsData.$iconName)')",
            );
            legacyClassBuffer.writeln(
              '  static Widget get $iconName => const IxIcon(IxIconsData.$iconName);',
            );
          }
          generatedCount++;
        }

        if (generatedCount == 0) {
          throw Exception('No valid SVG icons could be generated.');
        }

        dataClassBuffer.writeln('}');
        legacyClassBuffer.writeln('}');

        final outputBuffer = StringBuffer(dataClassBuffer.toString());
        if (legacyGetters) {
          outputBuffer.writeln('');
          outputBuffer.write(legacyClassBuffer.toString());
        }

        final outputFile = File(path.join(outputDir, 'ix_icons.dart'));
        await outputFile.writeAsString(outputBuffer.toString());

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

  /// Download the npm package [iconsVersion] and extract it to a temporary
  /// directory.
  ///
  /// Returns the temporary directory together with the tarball's sha1 checksum
  /// as published in the registry metadata (`dist.shasum`), or `null` when the
  /// registry does not report one.
  static Future<(Directory tempDir, String? shasum)> _downloadAndExtractPackage(
    http.Client client,
    String iconsVersion,
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
    if (versions == null || !versions.containsKey(iconsVersion)) {
      // List available versions for debugging
      final availableVersions = versions?.keys.toList() ?? [];
      print(
        'Available versions: ${availableVersions.take(10).join(", ")}${availableVersions.length > 10 ? "..." : ""}',
      );
      throw Exception('Version $iconsVersion not found in package metadata');
    }

    final versionData = versions[iconsVersion] as Map<String, dynamic>;
    final dist = versionData['dist'] as Map<String, dynamic>?;

    if (dist == null || !dist.containsKey('tarball')) {
      throw Exception('Tarball URL not found in version metadata');
    }

    final tarballUrl = dist['tarball'] as String;
    final shasum = dist['shasum'] as String?;
    print('Downloading tarball from $tarballUrl');

    // Download the tarball
    final tarballResponse = await client.get(Uri.parse(tarballUrl));
    if (tarballResponse.statusCode != 200) {
      throw Exception(
        'Failed to download tarball: ${tarballResponse.statusCode}',
      );
    }

    print('Downloaded ${tarballResponse.bodyBytes.length} bytes');

    // Verify the download against the registry's own checksum before a
    // single byte of it is written to disk or quoted in generated code.
    // npm still publishes the legacy sha1 `dist.shasum` for every version;
    // when the registry omits it there is nothing to check against and the
    // generated header says so ("tarball sha1 unknown").
    if (shasum != null) {
      final actual = sha1.convert(tarballResponse.bodyBytes).toString();
      if (actual != shasum) {
        throw Exception(
          'Tarball sha1 mismatch for $_packageName@$iconsVersion: the '
          'registry declares $shasum but the downloaded bytes hash to '
          '$actual. Refusing to extract.',
        );
      }
      print('Verified tarball sha1 $actual');
    } else {
      print('Registry published no dist.shasum; skipping checksum check');
    }

    // Create temporary directory
    final tempDir = await Directory.systemTemp.createTemp('ix_icons_');

    // Extract the tarball
    print('Extracting package to ${tempDir.path}');
    final archive = TarDecoder().decodeBytes(
      GZipDecoder().decodeBytes(tarballResponse.bodyBytes),
    );

    for (final file in archive) {
      // A tar entry names its own output path, so a hostile or corrupt
      // archive can point it outside the extraction directory
      // ("zip slip", e.g. `../../.ssh/authorized_keys`). Resolve the entry
      // against tempDir and refuse anything that does not stay inside it.
      final filename = path.normalize(path.join(tempDir.path, file.name));
      if (!path.isWithin(tempDir.path, filename)) {
        throw Exception(
          'Refusing to extract "${file.name}": it escapes the extraction '
          'directory ${tempDir.path}.',
        );
      }
      // Symlinks are never needed for an icon package and are the second
      // half of the same attack (a link is followed by later entries
      // written "through" it), so drop them instead of materialising them.
      if (file.isSymbolicLink) {
        print('Skipping symbolic link ${file.name}');
        continue;
      }
      if (file.isFile) {
        final outputFile = File(filename);
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filename).create(recursive: true);
      }
    }

    print('Extraction complete');
    return (tempDir, shasum);
  }

  /// Strips `fill="none"` from `<g>` elements so the icon can be tinted.
  ///
  /// This mirrors upstream's `icon.css` rule (`svg [fill] { fill: currentColor
  /// !important }`) for the group elements that would otherwise swallow the
  /// tint. No other part of the SVG is modified.
  static String cleanSvgContent(String svgContent) {
    return svgContent.replaceAllMapped(
      RegExp(r'(<g\b[^>]*?)\s+fill\s*=\s*"none"'),
      (match) => match.group(1)!,
    );
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
