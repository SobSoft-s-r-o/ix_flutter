// Machine-checks that `UPSTREAM.md` and the latest CHANGELOG.md release
// header agree with the pinned `IxUpstream` constants (the single source of
// truth for the upstream Siemens iX core/icons baseline).
//
// Usage (from packages/ix_flutter):
//   dart run tool/upstream_check.dart
//
// Exits 1 and prints every mismatch to stderr; otherwise prints a one-line
// OK summary to stdout and exits 0. Also runs in CI (see
// .github/workflows/ci.yml, job `format`).
import 'dart:io';

import 'package:ix_flutter/src/ix_core/ix_upstream.dart';

/// The upstream facts to check `UPSTREAM.md` and the CHANGELOG.md release
/// header against. In production this always mirrors [IxUpstream]; tests
/// pass synthetic values instead.
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

/// Compares `UPSTREAM.md` and the CHANGELOG.md release header against
/// [facts]. Returns the list of mismatches found (empty when everything is
/// consistent).
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

  final release = RegExp(
    r'^## \[(\d+\.\d+\.\d+[^\]]*)\][^\n]*\n([^\n]*)',
    multiLine: true,
  ).firstMatch(changelog);
  if (release == null) {
    errors.add('CHANGELOG.md has no release section');
    return errors;
  }
  final expected =
      'Upstream: ${facts.tag} (${facts.commit.substring(0, 8)}), '
      '@siemens/ix-icons ${facts.iconsTag} '
      '(${facts.iconsCommit.substring(0, 8)})';
  if (release.group(2)!.trim() != expected) {
    errors.add(
      'CHANGELOG.md release ${release.group(1)} must be followed by '
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
