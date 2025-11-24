import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

class ColorGenerator {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/siemens/ix/main/packages/core/scss/theme';

  static final Map<String, Map<String, _ThemeModeSource>> _themeSources = {
    'classic': {
      'dark': _ThemeModeSource.remote('classic/dark/_variables.scss'),
      'light': _ThemeModeSource.remote('classic/light/_variables.scss'),
    },
  };

  static Set<String>? _cachedIxThemeTokens;

  /// Generate color token classes from Siemens IX repository
  static Future<void> generateColors({required String outputDir}) async {
    print('Starting color token generation...');

    for (final themeEntry in _themeSources.entries) {
      final theme = themeEntry.key;
      for (final modeEntry in themeEntry.value.entries) {
        final mode = modeEntry.key;
        print('Processing $theme theme - $mode mode...');
        await _generateThemeColors(theme, mode, outputDir, modeEntry.value);
      }
    }

    print('Color token generation completed!');
  }

  static Future<void> _generateThemeColors(
    String theme,
    String mode,
    String outputDir,
    _ThemeModeSource source,
  ) async {
    final content = await _loadThemeContent(theme, mode, source);
    if (content == null) {
      return;
    }

    // Parse color tokens
    final tokens = _parseScssVariables(content);
    print('  Found ${tokens.length} tokens');

    final supportedTokens = await _loadIxThemeTokenNames();

    // Generate Dart code
    final dartCode = _generateDartCode(theme, mode, tokens, supportedTokens);

    // Save to file
    final fileName = 'ix_${theme}_${mode}_colors.dart';
    final outputPath = '$outputDir/$fileName';
    await File(outputPath).writeAsString(dartCode);
    print('  Generated: $outputPath');
  }

  static Map<String, String> _parseScssVariables(String scssContent) {
    final tokens = <String, String>{};
    final lines = scssContent.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('--theme-color')) {
        // Parse CSS variable definition: --theme-color-xxx: value;
        final match = RegExp(
          r'(--theme-color-[^:]+):\s*([^;]+);',
        ).firstMatch(trimmed);
        if (match != null) {
          final name = match.group(1)!;
          var value = match.group(2)!.trim();

          // Skip if value is a CSS variable reference (we only want concrete values)
          if (!value.startsWith('var(')) {
            tokens[name] = value;
          }
        }
      }
    }

    return tokens;
  }

  static String _generateDartCode(
    String theme,
    String mode,
    Map<String, String> tokens,
    Set<String> supportedTokens,
  ) {
    final className =
        'Ix${ReCase(theme).pascalCase}${ReCase(mode).pascalCase}Colors';
    final constantsBuffer = StringBuffer();
    final paletteEntriesBuffer = StringBuffer();
    final missingPaletteTokens = <String>[];
    var hasPaletteEntries = false;

    // Sort tokens by name for consistency
    final sortedKeys = tokens.keys.toList()..sort();

    for (final key in sortedKeys) {
      final value = tokens[key]!;
      final color = _parseColorValue(value);

      if (color != null) {
        // Convert CSS variable name to Dart property name
        // --theme-color-alarm => alarm
        // --theme-color-alarm--hover => alarmHover
        final propertyName = _cssVarToDartProperty(key);
        final docComment = '  /// CSS Variable: $key';

        constantsBuffer
          ..writeln(docComment)
          ..writeln('  static const Color $propertyName = $color;')
          ..writeln();

        if (supportedTokens.contains(propertyName)) {
          paletteEntriesBuffer.writeln(
            '    IxThemeColorToken.$propertyName: $propertyName,',
          );
          hasPaletteEntries = true;
        } else {
          missingPaletteTokens.add(propertyName);
        }
      }
    }

    if (missingPaletteTokens.isNotEmpty) {
      print(
        '  Warning: Skipped ${missingPaletteTokens.length} tokens missing '
        'in IxThemeColorToken enum for $theme/$mode: '
        '${missingPaletteTokens.join(', ')}',
      );
    }

    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// Generated from Siemens IX Design System')
      ..writeln('// Theme: $theme, Mode: $mode')
      ..writeln('// Source: https://github.com/siemens/ix')
      ..writeln()
      ..writeln("import 'package:flutter/material.dart';");

    if (hasPaletteEntries) {
      buffer.writeln("import '../ix_theme_color_tokens.dart';");
    }

    buffer
      ..writeln()
      ..writeln('/// Color tokens for Siemens IX $theme theme in $mode mode')
      ..writeln('class $className {')
      ..writeln('  $className._();')
      ..writeln()
      ..write(constantsBuffer.toString());

    if (hasPaletteEntries) {
      buffer
        ..writeln('  /// Complete palette keyed by IxThemeColorToken.')
        ..writeln('  static const Map<IxThemeColorToken, Color> palette = {')
        ..write(paletteEntriesBuffer.toString())
        ..writeln('  };')
        ..writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _cssVarToDartProperty(String cssVar) {
    // Remove --theme-color- prefix and convert to camelCase
    var name = cssVar.replaceFirst('--theme-color-', '');

    // Replace double dashes with underscore for states like --hover, --active
    name = name.replaceAll('--', '_');

    // Replace single dashes with spaces for camelCase conversion
    name = name.replaceAll('-', ' ');

    // Convert to camelCase
    var dartName = ReCase(name).camelCase;

    // If the name starts with a number, prefix it with 'color'
    if (dartName.isNotEmpty && RegExp(r'^[0-9]').hasMatch(dartName)) {
      dartName = 'color$dartName';
    }

    return dartName;
  }

  static String? _parseColorValue(String value) {
    value = value.trim();

    // Handle hex colors
    if (value.startsWith('#')) {
      return _hexToFlutterColor(value);
    }

    // Handle rgba colors
    if (value.startsWith('rgba(')) {
      return _rgbaToFlutterColor(value);
    }

    // Handle rgb colors
    if (value.startsWith('rgb(')) {
      return _rgbToFlutterColor(value);
    }

    return null;
  }

  static String _hexToFlutterColor(String hex) {
    hex = hex.replaceFirst('#', '');

    if (hex.length == 6) {
      return 'Color(0xFF$hex)';
    } else if (hex.length == 8) {
      // Already has alpha
      return 'Color(0x$hex)';
    }

    return 'Color(0xFF$hex)';
  }

  static String _rgbaToFlutterColor(String rgba) {
    final match = RegExp(
      r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)',
    ).firstMatch(rgba);

    if (match != null) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);
      final a = double.parse(match.group(4)!);

      final alpha = (a * 255).round();
      final hex =
          '${alpha.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

      return 'Color(0x$hex)';
    }

    return 'Color(0xFF000000)'; // fallback
  }

  static String _rgbToFlutterColor(String rgb) {
    final match = RegExp(r'rgb\((\d+),\s*(\d+),\s*(\d+)\)').firstMatch(rgb);

    if (match != null) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);

      final hex =
          'FF${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

      return 'Color(0x$hex)';
    }

    return 'Color(0xFF000000)'; // fallback
  }

  static Future<String?> _loadThemeContent(
    String theme,
    String mode,
    _ThemeModeSource source,
  ) async {
    if (source.isLocal) {
      final root = Directory.current.path;
      final filePath = p.normalize(p.join(root, source.location));
      print('  Reading local file: $filePath');
      final file = File(filePath);
      if (!await file.exists()) {
        print('  Warning: Local file missing for $theme/$mode');
        return null;
      }
      return file.readAsString();
    }

    final url = '$_baseUrl/${source.location}';
    print('  Downloading from: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      print('  Warning: Failed to download $url (${response.statusCode})');
      return null;
    }
    return response.body;
  }

  static Future<Set<String>> _loadIxThemeTokenNames() async {
    if (_cachedIxThemeTokens != null) {
      return _cachedIxThemeTokens!;
    }

    final root = Directory.current.path;
    final filePath = p.normalize(
      p.join(root, 'lib/src/ix_colors/ix_theme_color_tokens.dart'),
    );

    final file = File(filePath);
    if (!await file.exists()) {
      print(
        '  Warning: Could not locate IxThemeColorToken enum at $filePath. '
        'Palette maps will be empty.',
      );
      _cachedIxThemeTokens = <String>{};
      return _cachedIxThemeTokens!;
    }

    final content = await file.readAsString();
    _cachedIxThemeTokens = _parseIxThemeTokenNames(content);
    return _cachedIxThemeTokens!;
  }

  static Set<String> _parseIxThemeTokenNames(String content) {
    final match = RegExp(
      r'enum\s+IxThemeColorToken\s*{([^}]*)}',
      dotAll: true,
    ).firstMatch(content);

    if (match == null) {
      print(
        '  Warning: Could not parse IxThemeColorToken enum. '
        'Palette maps will be empty.',
      );
      return <String>{};
    }

    final body = match.group(1)!;
    final tokens = body
        .split(',')
        .map((part) => part.split('//').first.trim())
        .where((part) => part.isNotEmpty)
        .toSet();

    return tokens;
  }
}

class _ThemeModeSource {
  final String location;
  final bool isLocal;

  const _ThemeModeSource.remote(this.location) : isLocal = false;

  const _ThemeModeSource.local(this.location) : isLocal = true;
}
