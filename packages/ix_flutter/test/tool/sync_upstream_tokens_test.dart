import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/sync_upstream_tokens.dart';

/// Covers the error-handling fix for tool/sync_upstream_tokens.dart's
/// upstream-scss lookup (no upstream `.ct.ts`/scss/tsx counterpart — this
/// guards our own tooling, not a mirrored Siemens IX behaviour — so this
/// file carries a doc-comment instead of `@Upstream`). Exercises
/// [readClassicScss] directly against a local temp directory; no network or
/// git clone involved.
void main() {
  group('readClassicScss', () {
    test('throws a one-line error naming the expected path and tag when the '
        'upstream file is missing', () {
      final root = Directory.systemTemp.createTempSync('ix_upstream_test_');
      addTearDown(() => root.deleteSync(recursive: true));
      final expectedPath =
          '${root.path}/packages/core/scss/theme/classic/light/_variables.scss';

      expect(
        () => readClassicScss(
          cloneRoot: root.path,
          mode: 'light',
          tag: '@siemens/ix@9.9.9',
        ),
        throwsA(
          isA<UpstreamScssNotFoundException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains(expectedPath),
              contains('@siemens/ix@9.9.9'),
              isNot(contains('\n')),
            ),
          ),
        ),
      );
    });

    test('returns the file contents when the upstream file exists', () {
      final root = Directory.systemTemp.createTempSync('ix_upstream_test_');
      addTearDown(() => root.deleteSync(recursive: true));
      final scssDir = Directory(
        '${root.path}/packages/core/scss/theme/classic/dark',
      )..createSync(recursive: true);
      File(
        '${scssDir.path}/_variables.scss',
      ).writeAsStringSync('--theme-color-primary: #00bde3;');

      final scss = readClassicScss(
        cloneRoot: root.path,
        mode: 'dark',
        tag: '@siemens/ix@9.9.9',
      );

      expect(scss, contains('--theme-color-primary'));
    });
  });
}
