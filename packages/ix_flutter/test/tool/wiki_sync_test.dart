import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Covers `tool/wiki_sync.sh`'s link rewriting (no upstream `.ct.ts`/scss/tsx
/// counterpart — this guards our own documentation tooling, not a mirrored
/// Siemens IX behaviour — so this file carries a doc-comment instead of
/// `@Upstream`).
///
/// The script is run for real against a throwaway repository laid out in a
/// temp directory, because a `--dry-run` only prints the copy plan and proves
/// nothing about the rewriting.
void main() {
  late Directory root;

  /// Lays out a fake repository around [sources] (repo-relative path →
  /// contents) with [map] as `tool/wiki_sync_map.txt`, runs the real
  /// `tool/wiki_sync.sh` against a wiki directory inside it, and returns the
  /// generated page contents by destination file name.
  Map<String, String> sync({
    required Map<String, String> sources,
    required String map,
  }) {
    final script = File('../../tool/wiki_sync.sh');
    expect(script.existsSync(), isTrue, reason: 'run from packages/ix_flutter');

    Directory('${root.path}/tool').createSync(recursive: true);
    final copied = File('${root.path}/tool/wiki_sync.sh')
      ..writeAsStringSync(script.readAsStringSync());
    Process.runSync('chmod', ['+x', copied.path]);
    File('${root.path}/tool/wiki_sync_map.txt').writeAsStringSync(map);
    sources.forEach((path, contents) {
      final file = File('${root.path}/$path');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(contents);
    });
    final wiki = Directory('${root.path}/wiki')..createSync();

    final run = Process.runSync('bash', [copied.path, wiki.path]);
    expect(
      run.exitCode,
      0,
      reason: 'wiki_sync.sh failed: ${run.stdout}${run.stderr}',
    );

    return {
      for (final f in wiki.listSync().whereType<File>())
        f.uri.pathSegments.last: f.readAsStringSync(),
    };
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('ix_wiki_sync_test_');
  });
  tearDown(() => root.deleteSync(recursive: true));

  test('an image target becomes a raw URL, not a blob one', () {
    // The regression: `blob/main/<path>.png` serves the file-viewer HTML page
    // (Content-Type: text/html), so every screenshot embedded in a synced page
    // rendered as a broken image on the wiki.
    final pages = sync(
      map: 'README.md -> Home.md\n',
      sources: {
        'README.md': '![Overview](packages/ix_flutter/screenshots/a.png)\n',
      },
    );

    expect(
      pages['Home.md'],
      contains(
        '![Overview](https://raw.githubusercontent.com/SobSoft-s-r-o/'
        'ix_flutter/main/packages/ix_flutter/screenshots/a.png)',
      ),
    );
    expect(pages['Home.md'], isNot(contains('blob/main')));
  });

  test('a plain link to an unmapped file still becomes a blob URL', () {
    final pages = sync(
      map: 'README.md -> Home.md\n',
      sources: {'README.md': '[notices](THIRD_PARTY_NOTICES.md)\n'},
    );

    expect(
      pages['Home.md'],
      contains(
        '[notices](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/'
        'THIRD_PARTY_NOTICES.md)',
      ),
    );
  });

  test('one path used as both an image and a link gets both hosts', () {
    final pages = sync(
      map: 'README.md -> Home.md\n',
      sources: {
        'README.md':
            '![shot](screenshots/a.png)\n'
            '[full size](screenshots/a.png)\n',
      },
    );

    expect(
      pages['Home.md'],
      contains(
        '![shot](https://raw.githubusercontent.com/SobSoft-s-r-o/ix_flutter/'
        'main/screenshots/a.png)',
      ),
    );
    expect(
      pages['Home.md'],
      contains(
        '[full size](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/'
        'screenshots/a.png)',
      ),
    );
  });

  test('a link to another mapped source becomes a bare wiki page name', () {
    final pages = sync(
      map: 'README.md -> Home.md\ndoc/theming.md -> theming.md\n',
      sources: {
        'README.md': '[theming](doc/theming.md#palettes)\n',
        'doc/theming.md': '# Theming\n',
      },
    );

    expect(pages['Home.md'], contains('[theming](theming#palettes)'));
  });

  test('an absolute image URL is left alone', () {
    final pages = sync(
      map: 'README.md -> Home.md\n',
      sources: {
        'README.md': '![CI](https://img.shields.io/badge/x-y-blue.svg)\n',
      },
    );

    expect(
      pages['Home.md'],
      contains('![CI](https://img.shields.io/badge/x-y-blue.svg)'),
    );
  });
}
