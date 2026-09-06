// Usage (from packages/ix_flutter):
//   dart run tool/sync_upstream_tokens.dart @siemens/ix@5.2.1
//   dart run tool/sync_upstream_tokens.dart --tag @siemens/ix@5.2.1 --repo <url-or-local-path>
// Clones siemens/ix at the tag (depth 1) from --repo (default
// https://github.com/siemens/ix; the parameter exists so CI and a local run
// can swap the source without touching the script), reads
// packages/core/scss/theme/classic/{light,dark}/_variables.scss and writes
// test/fixtures/upstream_classic_{light,dark}.json as
// { "--theme-color-primary": "FF006E93", ... } (ARGB hex, alpha = round(a*255)).
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final SyncArgs parsed;
  try {
    parsed = parseArgs(args);
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    exitCode = 64;
    return;
  }
  final tag = parsed.tag;
  final repo = parsed.repo;
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

/// The resolved `tag`/`repo` command-line configuration for [main].
class SyncArgs {
  const SyncArgs({required this.tag, required this.repo});

  /// The `@siemens/ix` tag to clone and read tokens from.
  final String tag;

  /// The git remote (URL or local path) to clone [tag] from.
  final String repo;
}

/// Raised by [parseArgs] with an already-human-readable [message] when the
/// command line cannot be parsed.
class UsageException implements Exception {
  UsageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Parses [args] into a [SyncArgs].
///
/// Accepts either a single positional `<tag>` -- the form UPSTREAM.md's sync
/// procedure documents -- or `--tag <value>` (and `--repo <value>` to
/// override the cloned source); `--tag`/`--repo` win over a positional
/// argument if both are given. Throws [UsageException] when `--tag` or
/// `--repo` is the last argument and carries no value, instead of the caller
/// indexing past the end of [args].
SyncArgs parseArgs(List<String> args) {
  String? tag;
  String? repo;
  final positionals = <String>[];
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--tag':
        if (i + 1 >= args.length) {
          throw UsageException(
            'sync_upstream_tokens: --tag requires a value, e.g. '
            '--tag @siemens/ix@5.2.1',
          );
        }
        tag = args[++i];
      case '--repo':
        if (i + 1 >= args.length) {
          throw UsageException(
            'sync_upstream_tokens: --repo requires a value, e.g. '
            '--repo https://github.com/siemens/ix',
          );
        }
        repo = args[++i];
      default:
        positionals.add(args[i]);
    }
  }
  return SyncArgs(
    tag:
        tag ??
        (positionals.isNotEmpty ? positionals.first : '@siemens/ix@5.2.1'),
    repo: repo ?? 'https://github.com/siemens/ix',
  );
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
  return null; // var(...) references are not snapshotted
}
