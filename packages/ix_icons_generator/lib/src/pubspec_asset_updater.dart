/// Adds the generated asset directory to a Flutter pubspec.
class PubspecAssetUpdater {
  PubspecAssetUpdater._();

  static final _flutterKey = RegExp(
    r'''^(?:flutter|'flutter'|"flutter")\s*:''',
  );
  static final _assetsKey = RegExp(r'''^(?:assets|'assets'|"assets")\s*:''');
  static final _flutterMappingHeader = RegExp(r'^flutter:\s*(?:#.*)?$');
  static final _assetsListHeader = RegExp(r'^assets:\s*(?:#.*)?$');

  /// Returns [pubspecContent] with [assetsPath] registered in the top-level
  /// `flutter.assets` list.
  ///
  /// This intentionally supports the ordinary block-mapping form used by
  /// Flutter pubspecs. Unsupported forms throw before a caller writes the
  /// returned content, preventing a partial or corrupt manifest update.
  static String addAsset(String pubspecContent, String assetsPath) {
    final asset = _assetEntry(assetsPath);
    final newline = _newlineFor(pubspecContent);
    final lines = pubspecContent.split(newline);
    final flutterHeaders = <int>[];

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final indent = _indentOf(line);
      final trimmed = line.trim();
      if (_isIgnorable(trimmed) || indent != 0) {
        continue;
      }
      if (trimmed == '---' ||
          trimmed == '...' ||
          trimmed.startsWith('%') ||
          trimmed.startsWith('{') ||
          trimmed.startsWith('[')) {
        throw const FormatException(
          'Unsupported pubspec YAML shape; expected one block mapping.',
        );
      }
      if (_looksLikeFlutterKey(trimmed)) {
        if (!_flutterMappingHeader.hasMatch(trimmed)) {
          throw const FormatException(
            'Unsupported top-level flutter value; expected a block mapping.',
          );
        }
        flutterHeaders.add(index);
      }
    }

    if (flutterHeaders.length > 1) {
      throw const FormatException(
        'Unsupported pubspec YAML shape; duplicate top-level flutter keys.',
      );
    }
    if (flutterHeaders.isEmpty) {
      return _appendFlutterMapping(pubspecContent, newline, asset);
    }

    final flutterHeader = flutterHeaders.single;
    final flutterEnd = _mappingEnd(lines, flutterHeader + 1);
    final childIndent = _childIndent(lines, flutterHeader + 1, flutterEnd);
    int? assetsHeader;

    for (var index = flutterHeader + 1; index < flutterEnd; index++) {
      final line = lines[index];
      final trimmed = line.trim();
      if (_isIgnorable(trimmed) || _indentOf(line) != childIndent) {
        continue;
      }
      if (trimmed.startsWith('-')) {
        throw const FormatException(
          'Unsupported top-level flutter value; expected a mapping.',
        );
      }
      if (_looksLikeAssetsKey(trimmed)) {
        if (!_assetsListHeader.hasMatch(trimmed)) {
          throw const FormatException(
            'Unsupported flutter.assets value; expected a block list.',
          );
        }
        if (assetsHeader != null) {
          throw const FormatException(
            'Unsupported pubspec YAML shape; duplicate flutter.assets keys.',
          );
        }
        assetsHeader = index;
      }
    }

    if (assetsHeader == null) {
      return _insertLines(lines, flutterHeader + 1, newline, [
        '${' ' * childIndent}assets:',
        '${' ' * (childIndent + 2)}- $asset',
      ]);
    }

    final assetsEnd = _blockEnd(
      lines,
      assetsHeader + 1,
      flutterEnd,
      childIndent,
    );
    final assetLines = <int>[];
    for (var index = assetsHeader + 1; index < assetsEnd; index++) {
      if (!_isIgnorable(lines[index].trim())) {
        assetLines.add(index);
      }
    }
    if (assetLines.isEmpty) {
      return _insertLines(lines, assetsHeader + 1, newline, [
        '${' ' * (childIndent + 2)}- $asset',
      ]);
    }

    final listIndent = _indentOf(lines[assetLines.first]);
    if (listIndent <= childIndent ||
        !lines[assetLines.first].trimLeft().startsWith('-')) {
      throw const FormatException(
        'Unsupported flutter.assets value; expected a block list.',
      );
    }
    for (final index in assetLines) {
      if (_indentOf(lines[index]) != listIndent) {
        continue;
      }
      final trimmed = lines[index].trimLeft();
      if (!trimmed.startsWith('-')) {
        throw const FormatException(
          'Unsupported flutter.assets value; expected a block list.',
        );
      }
      if (_listEntryEquals(trimmed, asset)) {
        return pubspecContent;
      }
    }

    return _insertLines(lines, assetsEnd, newline, [
      '${' ' * listIndent}- $asset',
    ]);
  }

  static String _assetEntry(String assetsPath) {
    if (assetsPath.isEmpty ||
        assetsPath.trim() != assetsPath ||
        assetsPath.contains('\n') ||
        assetsPath.contains('\r') ||
        assetsPath.contains('#')) {
      throw ArgumentError.value(
        assetsPath,
        'assetsPath',
        'must be a nonempty safe relative YAML path',
      );
    }
    return assetsPath.endsWith('/') ? assetsPath : '$assetsPath/';
  }

  static String _newlineFor(String content) {
    final withoutCrLf = content.replaceAll('\r\n', '');
    if (withoutCrLf.contains('\r') ||
        (content.contains('\r\n') && withoutCrLf.contains('\n'))) {
      throw const FormatException(
        'Unsupported pubspec line endings; use consistent LF or CRLF.',
      );
    }
    return content.contains('\r\n') ? '\r\n' : '\n';
  }

  static int _indentOf(String line) {
    var indent = 0;
    while (indent < line.length && line.codeUnitAt(indent) == 0x20) {
      indent++;
    }
    if (indent < line.length && line.codeUnitAt(indent) == 0x09) {
      throw const FormatException(
        'Unsupported pubspec indentation; tabs are not allowed.',
      );
    }
    return indent;
  }

  static bool _isIgnorable(String trimmed) =>
      trimmed.isEmpty || trimmed.startsWith('#');

  static bool _looksLikeFlutterKey(String trimmed) =>
      _flutterKey.hasMatch(trimmed) || trimmed.startsWith('? flutter');

  static bool _looksLikeAssetsKey(String trimmed) =>
      _assetsKey.hasMatch(trimmed) || trimmed.startsWith('? assets');

  static int _mappingEnd(List<String> lines, int start) {
    for (var index = start; index < lines.length; index++) {
      final trimmed = lines[index].trim();
      if (!_isIgnorable(trimmed) && _indentOf(lines[index]) == 0) {
        return index;
      }
    }
    return lines.length;
  }

  static int _childIndent(List<String> lines, int start, int end) {
    int? childIndent;
    for (var index = start; index < end; index++) {
      if (_isIgnorable(lines[index].trim())) {
        continue;
      }
      final indent = _indentOf(lines[index]);
      if (indent == 0) {
        continue;
      }
      if (childIndent == null || indent < childIndent) {
        childIndent = indent;
      }
    }
    return childIndent ?? 2;
  }

  static int _blockEnd(
    List<String> lines,
    int start,
    int outerEnd,
    int parentIndent,
  ) {
    for (var index = start; index < outerEnd; index++) {
      if (lines[index].trim().isEmpty) {
        continue;
      }
      if (_indentOf(lines[index]) <= parentIndent) {
        return index;
      }
    }
    return outerEnd;
  }

  static bool _listEntryEquals(String trimmed, String asset) {
    var value = trimmed.substring(1).trim();
    final comment = value.indexOf(RegExp(r'\s+#'));
    if (comment >= 0) {
      value = value.substring(0, comment).trimRight();
    }
    return value == asset || value == "'$asset'" || value == '"$asset"';
  }

  static String _insertLines(
    List<String> lines,
    int index,
    String newline,
    List<String> inserted,
  ) {
    final updated = [...lines]..insertAll(index, inserted);
    return updated.join(newline);
  }

  static String _appendFlutterMapping(
    String content,
    String newline,
    String asset,
  ) {
    final block = 'flutter:$newline  assets:$newline    - $asset$newline';
    if (content.isEmpty) {
      return block;
    }
    return content.endsWith(newline)
        ? '$content$block'
        : '$content$newline$block';
  }
}
