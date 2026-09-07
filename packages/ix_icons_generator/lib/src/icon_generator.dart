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
  /// [format] - Run `dart format` on the generated file (best effort)
  static Future<void> generateIcons({
    required String outputDir,
    required String assetsDir,
    String? flutterPackageName,
    http.Client? client,
    String iconsVersion = defaultIconsVersion,
    bool legacyGetters = true,
    bool format = true,
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
        // Identifier -> the file it was derived from, so a collision names
        // both sides instead of writing a class that does not compile.
        final claimedNames = <String, String>{};

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
          final iconName = dartIdentifierFor(
            path.basenameWithoutExtension(fileName),
          );
          final claimedBy = claimedNames[iconName];
          if (claimedBy != null) {
            throw Exception(
              'Duplicate icon identifier "$iconName": both "$claimedBy" and '
              '"$fileName" map to it. Rename one of the source icons or '
              'exclude it before generating.',
            );
          }
          claimedNames[iconName] = fileName;
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
        if (format) {
          await _formatGeneratedFile(outputFile);
        }

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

    // Extract the tarball. A rejected entry aborts the whole extraction, so
    // the half-written directory has to go with it - otherwise every refused
    // archive leaves a stray `ix_icons_*` tree in the system temp directory.
    print('Extracting package to ${tempDir.path}');
    try {
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
    } catch (_) {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      rethrow;
    }

    print('Extraction complete');
    return (tempDir, shasum);
  }

  /// Dart's reserved words, which may never be used as an identifier.
  ///
  /// Built-in identifiers (`export`, `import`, `library`, `extension`, …) are
  /// deliberately absent: they are only restricted as type names and are
  /// perfectly legal member names, so icons called `export.svg` or
  /// `library.svg` keep the name they have always had.
  static const _dartReservedWords = {
    'assert', 'break', 'case', 'catch', 'class', 'const', 'continue',
    'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
    'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
    'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
    // A static member may not repeat a name every class inherits from Object.
    'hashCode', 'noSuchMethod', 'runtimeType', 'toString',
  };

  /// Turns an icon file's base name into a Dart identifier that compiles.
  ///
  /// The name is camel-cased as before; on top of that a leading digit is
  /// prefixed (`3d-view` -> `icon3dView`, since Dart identifiers may not start
  /// with one), a reserved word gets a trailing underscore (`class` ->
  /// `class_`), and anything that is left empty falls back to `icon`.
  static String dartIdentifierFor(String fileBaseName) {
    var name = ReCase(
      fileBaseName,
    ).camelCase.replaceAll(RegExp(r'[^A-Za-z0-9_$]'), '');
    if (name.isEmpty) {
      return 'icon';
    }
    if (RegExp(r'^[0-9]').hasMatch(name)) {
      name = 'icon${name[0].toUpperCase()}${name.substring(1)}';
    }
    if (_dartReservedWords.contains(name)) {
      name = '${name}_';
    }
    return name;
  }

  /// Runs `dart format` over [file], best effort.
  ///
  /// The generated catalogue lands in the host project's `lib/`, which CI
  /// formatting checks usually cover, so the generator formats it rather than
  /// leaving that to the caller. A missing or failing `dart` executable is
  /// only reported - it never fails the generation.
  static Future<void> _formatGeneratedFile(File file) async {
    try {
      final result = await Process.run('dart', ['format', file.path]);
      if (result.exitCode != 0) {
        print('Could not format ${file.path}: ${result.stderr}');
      } else {
        print('Formatted ${file.path}');
      }
    } on ProcessException catch (e) {
      print('Could not run "dart format" (${e.message}); output left as is');
    }
  }

  /// Element start tag: name plus its attribute list, quote-aware so that an
  /// attribute value may legally contain `>`.
  static final RegExp _startTag = RegExp(
    r'<([a-zA-Z][\w:.-]*)((?:[^>\x22\x27]|\x22[^\x22]*\x22|\x27[^\x27]*\x27)*)>',
  );

  /// A `fill="none"` (or `fill='none'`) attribute, tolerating whitespace and
  /// never matching `fill-rule` / `fill-opacity`.
  static final RegExp _fillNone = RegExp(
    r'(?<![\w-])fill\s*=\s*[\x22\x27]none[\x22\x27]',
  );

  /// A `stroke` paint attribute whose value is not `none`.
  static final RegExp _paintingStroke = RegExp(
    r'(?<![\w-])stroke\s*=\s*[\x22\x27](?!none[\x22\x27])[^\x22\x27]+[\x22\x27]',
  );

  /// SVG elements that only group other elements; a `fill` on one of them is
  /// inherited by its children and never paints anything itself.
  static const _containerElements = {'svg', 'g', 'a', 'switch', 'symbol'};

  /// Strips the `fill="none"` attributes that would otherwise make an icon
  /// invisible.
  ///
  /// Upstream ships its icons for the web, where `icon.css`
  /// (`svg [fill] { fill: currentColor !important }`) overrides every `fill`
  /// at paint time. Flutter has no such stylesheet, so a `fill="none"` that
  /// upstream never honours is taken literally and the icon compiles to zero
  /// draw commands. `@siemens/ix-icons` 3.5.0 declares `fill="none"` on the
  /// root `<svg>` of 891 of its 1479 icons whose `<path>`s carry no fill of
  /// their own, and all of those would render blank.
  ///
  /// The attribute is removed from container elements (`<svg>`, `<g>`, …),
  /// which cannot paint themselves, and from shapes that carry no stroke.
  /// A shape that pairs `fill="none"` with a real `stroke` is a deliberate
  /// outline and keeps its attribute. No other part of the SVG is modified.
  static String cleanSvgContent(String svgContent) {
    return svgContent.replaceAllMapped(_startTag, (match) {
      final attributes = match.group(2)!;
      if (!_fillNone.hasMatch(attributes)) {
        return match.group(0)!;
      }
      final name = match.group(1)!;
      if (!_containerElements.contains(name.toLowerCase()) &&
          _paintingStroke.hasMatch(attributes)) {
        return match.group(0)!;
      }
      final cleaned = attributes
          .replaceAll(_fillNone, '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trimRight();
      return '<$name$cleaned>';
    });
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
