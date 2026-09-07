// Machine-checks that `UPSTREAM.md` and the CHANGELOG.md section for the
// release being prepared agree with the pinned `IxUpstream` constants (the
// single source of truth for the upstream Siemens iX core/icons baseline).
//
// Usage (from packages/ix_flutter):
//   dart run tool/upstream_check.dart
//
// Exits 1 and prints every mismatch to stderr; otherwise prints a one-line
// OK summary to stdout and exits 0. Also runs in CI (see
// .github/workflows/ci.yml, job `format`).
import 'dart:io';

import 'package:ix_flutter/src/ix_core/ix_upstream.dart';

/// The upstream facts to check `UPSTREAM.md` and the CHANGELOG.md section for
/// the release being prepared against. In production this always mirrors
/// [IxUpstream]; tests pass synthetic values instead.
class UpstreamFacts {
  const UpstreamFacts({
    required this.version,
    required this.tag,
    required this.commit,
    required this.iconsVersion,
    required this.iconsTag,
    required this.iconsCommit,
  });

  final String version;
  final String tag;
  final String commit;
  final String iconsVersion;
  final String iconsTag;
  final String iconsCommit;
}

/// Compares `UPSTREAM.md` and the CHANGELOG.md section for the release being
/// prepared against [facts]. Returns the list of mismatches found (empty when
/// everything is consistent).
List<String> checkUpstream({
  required String upstreamMd,
  required String changelog,
  required UpstreamFacts facts,
}) {
  final errors = <String>[];

  String? cell(String rowStart, int col) {
    final line = upstreamMd
        .split('\n')
        .firstWhere((l) => l.startsWith(rowStart), orElse: () => '');
    if (line.isEmpty) return null;
    final cells = line.split('|').map((c) => c.trim()).toList();
    return cells.length > col ? cells[col] : null;
  }

  final coreVersion = cell('| `@siemens/ix` ', 2);
  final coreCommit = cell('| `@siemens/ix` ', 4);
  final iconsVersion = cell('| `@siemens/ix-icons`', 2);
  final iconsCommit = cell('| `@siemens/ix-icons`', 4);

  if (coreVersion != facts.version) {
    errors.add(
      'UPSTREAM.md core version "$coreVersion" != IxUpstream.version '
      '"${facts.version}"',
    );
  }
  if (coreCommit == null || !coreCommit.contains(facts.commit)) {
    errors.add(
      'UPSTREAM.md core commit does not contain IxUpstream.commit '
      '${facts.commit}',
    );
  }
  if (iconsVersion != facts.iconsVersion) {
    errors.add(
      'UPSTREAM.md icons version "$iconsVersion" != '
      'IxUpstream.iconsVersion "${facts.iconsVersion}"',
    );
  }
  if (iconsCommit == null || !iconsCommit.contains(facts.iconsCommit)) {
    errors.add(
      'UPSTREAM.md icons commit does not contain IxUpstream.iconsCommit '
      '${facts.iconsCommit}',
    );
  }

  // The `Upstream:` line belongs to the release being *prepared*, not to one
  // already published: it records what that release was verified against, and
  // the baseline moves while the release is still open. During development
  // the section being prepared is `[Unreleased]`; `cider release` then renames
  // that header in place (see UPSTREAM.md#release-header-format), so the line
  // travels with its own content and becomes the released section's line
  // without anybody editing it.
  //
  // So the section checked here is the topmost one that carries content --
  // `[Unreleased]` while it holds the release notes, otherwise the newest
  // numbered release. An `[Unreleased]` heading left empty right after a
  // release is skipped rather than reported. Older sections are never
  // checked: stamping today's baseline onto a version that shipped months
  // ago would be a false claim, not a consistency guarantee.
  //
  // Version brackets are optional throughout: a hand-written header reads
  // `## [1.0.2] - date`, while `cider release` writes `## 1.1.0 - date` with
  // no `[...]` at all.
  //
  // Heading positions are matched first and the bodies sliced between them: a
  // single section-matching regex would need an end-of-input lookahead, which
  // Dart's ECMAScript-flavoured RegExp does not offer (`\Z` is an identity
  // escape there, i.e. a literal `Z`), so the last section in the file would
  // silently never match.
  final headings = RegExp(
    r'^## +(?:\[([^\]]+)\]|(\d[^\s]*))[^\n]*$',
    multiLine: true,
  ).allMatches(changelog).toList();

  String? preparedName;
  String preparedBody = '';
  for (var i = 0; i < headings.length; i++) {
    final start = headings[i].end;
    final end = i + 1 < headings.length
        ? headings[i + 1].start
        : changelog.length;
    final body = changelog.substring(start, end);
    if (body.trim().isEmpty) continue; // an [Unreleased] opened but not filled
    preparedName = headings[i].group(1) ?? headings[i].group(2)!;
    preparedBody = body;
    break;
  }
  if (preparedName == null) {
    errors.add('CHANGELOG.md has no release section');
    return errors;
  }
  final expected =
      'Upstream: ${facts.tag} (${facts.commit.substring(0, 8)}), '
      '@siemens/ix-icons ${facts.iconsTag} '
      '(${facts.iconsCommit.substring(0, 8)})';
  final firstLine = preparedBody
      .split('\n')
      .map((l) => l.trim())
      .firstWhere((l) => l.isNotEmpty, orElse: () => '');
  if (firstLine != expected) {
    errors.add(
      'CHANGELOG.md section $preparedName must be followed by '
      '"$expected" (Upstream: line)',
    );
  }
  return errors;
}

void main() {
  const facts = UpstreamFacts(
    version: IxUpstream.version,
    tag: IxUpstream.tag,
    commit: IxUpstream.commit,
    iconsVersion: IxUpstream.iconsVersion,
    iconsTag: IxUpstream.iconsTag,
    iconsCommit: IxUpstream.iconsCommit,
  );
  final errors = checkUpstream(
    upstreamMd: File('../../UPSTREAM.md').readAsStringSync(),
    changelog: File('CHANGELOG.md').readAsStringSync(),
    facts: facts,
  );
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln(
    'upstream evidence OK: ${facts.tag} / ix-icons ${facts.iconsTag}',
  );
}
