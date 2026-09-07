import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/src/ix_core/ix_upstream.dart';

import '../../tool/upstream_check.dart';

const _facts = UpstreamFacts(
  version: IxUpstream.version,
  tag: IxUpstream.tag,
  commit: IxUpstream.commit,
  iconsVersion: IxUpstream.iconsVersion,
  iconsTag: IxUpstream.iconsTag,
  iconsCommit: IxUpstream.iconsCommit,
);
const _upstreamOk =
    '| `@siemens/ix` (core, source of truth) | 5.2.1 | `@siemens/ix@5.2.1` | '
    '`56dfa7514832e2c21c406a2aa3b40ab7d9f8bced` (2026-08-27) | x |\n'
    '| `@siemens/ix-icons` | 3.5.0 | `v3.5.0` (annotated) | '
    '`c46e1b13f7ccdaf66e4fcf2261f3765c55d45557` (2026-08-04) | y |\n';
const _upstreamLine =
    'Upstream: @siemens/ix@5.2.1 (56dfa751), @siemens/ix-icons v3.5.0 '
    '(c46e1b13)';

/// The shape during development: `[Unreleased]` holds the release notes and
/// carries the `Upstream:` line, and the section below it already shipped.
const _changelogOk =
    '## [Unreleased]\n'
    '$_upstreamLine\n'
    '\n'
    '### Added\n'
    '- something\n'
    '\n'
    '## [1.0.2] - 2026-01-28\n'
    '\n'
    '### Changed\n'
    '- something older\n';

/// The shape `cider release` actually writes once CHANGELOG.md carries the
/// keep-a-changelog link reference definitions its parser needs (see
/// UPSTREAM.md#release-header-format and A33): the new release header has no
/// surrounding `[...]`, unlike every hand-written header in this repository's
/// history (`## [1.0.2] - ...`).
const _changelogPostCiderRelease =
    '## 1.1.0 - 2026-10-01\n'
    '$_upstreamLine\n'
    '\n'
    '### Added\n'
    '- something\n';

/// Covers `tool/upstream_check.dart`'s consistency checks between
/// `UPSTREAM.md`, the `CHANGELOG.md` release header, and `IxUpstream` (no
/// upstream `.ct.ts`/scss/tsx counterpart — this guards our own tooling, not
/// a mirrored Siemens IX behaviour — so this file carries a doc-comment
/// instead of `@Upstream`).
void main() {
  test('consistent inputs produce no errors', () {
    expect(
      checkUpstream(
        upstreamMd: _upstreamOk,
        changelog: _changelogOk,
        facts: _facts,
      ),
      isEmpty,
    );
  });

  test('UPSTREAM.md with a different core commit is reported', () {
    final md = _upstreamOk.replaceFirst(
      '56dfa7514832e2c21c406a2aa3b40ab7d9f8bced',
      '0000000000000000000000000000000000000000',
    );
    expect(
      checkUpstream(upstreamMd: md, changelog: _changelogOk, facts: _facts),
      contains(contains('core commit')),
    );
  });

  test('release header without Upstream line is reported', () {
    expect(
      checkUpstream(
        upstreamMd: _upstreamOk,
        changelog: '## [1.1.0] - 2026-10-01\n- stuff\n',
        facts: _facts,
      ),
      contains(contains('Upstream:')),
    );
  });

  test('a released header without brackets -- the shape cider release writes '
      '-- is still found', () {
    expect(
      checkUpstream(
        upstreamMd: _upstreamOk,
        changelog: _changelogPostCiderRelease,
        facts: _facts,
      ),
      isEmpty,
    );
  });

  test(
    'an older release is not required to carry the current Upstream line',
    () {
      // The regression this file exists for: the check used to read the first
      // *numbered* section, so a baseline pinned long after 1.0.2 shipped had to
      // be written under 1.0.2's own header to keep CI green -- claiming a
      // release from January was verified against an August upstream commit.
      expect(
        checkUpstream(
          upstreamMd: _upstreamOk,
          changelog: _changelogOk,
          facts: _facts,
        ),
        isEmpty,
      );
      // ... and it is the `[Unreleased]` line that is load-bearing, not 1.0.2's
      // absence of one.
      expect(
        checkUpstream(
          upstreamMd: _upstreamOk,
          changelog: _changelogOk.replaceFirst('$_upstreamLine\n', ''),
          facts: _facts,
        ),
        contains(contains('Unreleased')),
      );
    },
  );

  test('an [Unreleased] heading with no content yet is skipped', () {
    // Straight after a release: `cider release` has renamed the old section
    // and a maintainer has opened a fresh, still-empty one on top of it.
    expect(
      checkUpstream(
        upstreamMd: _upstreamOk,
        changelog: '## [Unreleased]\n\n$_changelogPostCiderRelease',
        facts: _facts,
      ),
      isEmpty,
    );
  });

  test('a stale Upstream line under [Unreleased] is reported', () {
    expect(
      checkUpstream(
        upstreamMd: _upstreamOk,
        changelog: _changelogOk.replaceFirst('56dfa751', '00000000'),
        facts: _facts,
      ),
      contains(contains('Upstream:')),
    );
  });

  test('the real files are consistent with IxUpstream', () {
    expect(
      checkUpstream(
        upstreamMd: File('../../UPSTREAM.md').readAsStringSync(),
        changelog: File('CHANGELOG.md').readAsStringSync(),
        facts: _facts,
      ),
      isEmpty,
    );
  });
}
