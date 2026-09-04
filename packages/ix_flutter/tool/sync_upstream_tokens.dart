// Použitie (z packages/ix_flutter):
//   dart run tool/sync_upstream_tokens.dart --tag @siemens/ix@5.2.1
//   dart run tool/sync_upstream_tokens.dart --tag @siemens/ix@5.2.1 --repo <url-or-local-path>
// Naklonuje siemens/ix na tagu (depth 1) z --repo (default
// https://github.com/siemens/ix; parameter existuje, aby CI aj lokálny beh
// vedeli nahradiť zdroj bez zásahu do skriptu), prečíta
// packages/core/scss/theme/classic/{light,dark}/_variables.scss a zapíše
// test/fixtures/upstream_classic_{light,dark}.json ako
// { "--theme-color-primary": "FF006E93", ... } (ARGB hex, alpha = round(a*255)).
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final tagIndex = args.indexOf('--tag');
  final tag = tagIndex >= 0 ? args[tagIndex + 1] : '@siemens/ix@5.2.1';
  final repoIndex = args.indexOf('--repo');
  final repo = repoIndex >= 0
      ? args[repoIndex + 1]
      : 'https://github.com/siemens/ix';
  final tmp = await Directory.systemTemp.createTemp('ix_upstream_');
  // Everything that can fail after the clone exists runs inside try/finally
  // so the temp clone is always removed. Failure paths set `exitCode` and
  // `return` instead of calling `exit()`, because `exit()` terminates the
  // process immediately and skips pending `finally` blocks (including this
  // one) — see https://api.dart.dev/stable/dart-io/exit.html.
  try {
    final clone = await Process.run('git', [
      'clone',
      '--quiet',
      '--depth',
      '1',
      '--branch',
      tag,
      repo,
      tmp.path,
    ]);
    if (clone.exitCode != 0) {
      stderr.writeln(clone.stderr);
      exitCode = 1;
      return;
    }
    for (final mode in ['light', 'dark']) {
      final String scss;
      try {
        scss = readClassicScss(cloneRoot: tmp.path, mode: mode, tag: tag);
      } on UpstreamScssNotFoundException catch (e) {
        stderr.writeln(e.message);
        exitCode = 1;
        return;
      }
      final out = <String, String>{};
      final re = RegExp(r'(--theme-color-[a-z0-9-]+):\s*([^;]+);');
      for (final m in re.allMatches(scss)) {
        final argb = _toArgb(m.group(2)!.trim());
        if (argb != null) out[m.group(1)!] = argb;
      }
      final sorted = Map.fromEntries(
        out.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      File('test/fixtures/upstream_classic_$mode.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(sorted)}\n',
      );
      stdout.writeln('$mode: ${sorted.length} tokens');
    }
  } finally {
    tmp.deleteSync(recursive: true);
  }
}

/// Reads the upstream classic-theme SCSS for [mode] from the repository
/// cloned at [cloneRoot].
///
/// Throws [UpstreamScssNotFoundException] — an already human-readable,
/// one-line message naming the expected path and [tag] — if the file is
/// missing or cannot be read, e.g. because a future upstream tag
/// restructures the classic theme layout. Callers should catch it and print
/// [UpstreamScssNotFoundException.message] instead of letting a raw
/// `FileSystemException` stack trace surface.
String readClassicScss({
  required String cloneRoot,
  required String mode,
  required String tag,
}) {
  final path =
      '$cloneRoot/packages/core/scss/theme/classic/$mode/_variables.scss';
  final file = File(path);
  if (!file.existsSync()) {
    throw UpstreamScssNotFoundException(
      'sync_upstream_tokens: upstream file not found for tag $tag: $path '
      '(has the upstream classic theme layout changed?)',
    );
  }
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (e) {
    throw UpstreamScssNotFoundException(
      'sync_upstream_tokens: cannot read upstream file for tag $tag: $path '
      '(${e.osError?.message ?? e.message})',
    );
  }
}

/// Raised by [readClassicScss] with an already-human-readable [message].
class UpstreamScssNotFoundException implements Exception {
  UpstreamScssNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

String? _toArgb(String value) {
  final hex = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(value);
  if (hex != null) return 'FF${hex.group(1)!.toUpperCase()}';
  final rgba = RegExp(
    r'^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9.]+)\s*\)$',
  ).firstMatch(value);
  if (rgba != null) {
    final a = (double.parse(rgba.group(4)!) * 255).round();
    String h(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '${h(a)}${h(int.parse(rgba.group(1)!))}${h(int.parse(rgba.group(2)!))}${h(int.parse(rgba.group(3)!))}';
  }
  return null; // var(...) odkazy sa nesnapshotujú
}
