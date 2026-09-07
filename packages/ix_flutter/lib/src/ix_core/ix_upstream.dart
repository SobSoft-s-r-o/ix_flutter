/// The single pinned upstream baseline every parity claim is measured
/// against: the `@siemens/ix` release (and the `@siemens/ix-icons`
/// release its icons come from) this package ports.
///
/// `tool/upstream_check.dart` cross-checks these constants against
/// `UPSTREAM.md` and the CHANGELOG's `Upstream:` line, so they never
/// drift apart.
abstract final class IxUpstream {
  static const String version = '5.2.1';
  static const String tag = '@siemens/ix@5.2.1';
  static const String commit = '56dfa7514832e2c21c406a2aa3b40ab7d9f8bced';
  static const String iconsVersion = '3.5.0';
  static const String iconsTag = 'v3.5.0';
  static const String iconsCommit = 'c46e1b13f7ccdaf66e4fcf2261f3765c55d45557';
  static const String iconsTarballSha1 =
      'be50b3f933c8a5e210f980245a3df9825e8bcb7b';
}
