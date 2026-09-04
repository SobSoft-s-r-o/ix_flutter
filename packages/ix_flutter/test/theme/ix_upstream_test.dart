import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// `IxUpstream` pins our own baseline reference (tag/commit); there is no
/// upstream `.ct.ts` or scss/tsx source it mirrors, so this test carries a
/// doc-comment instead of `@Upstream`. See `palette_parity_test.dart` for the
/// token-level parity check that validates the pinned tag against a real
/// upstream snapshot.
void main() {
  test('IxUpstream pins the stable Siemens iX baseline', () {
    expect(IxUpstream.version, '5.2.1');
    expect(IxUpstream.tag, '@siemens/ix@5.2.1');
    expect(IxUpstream.commit, '56dfa7514832e2c21c406a2aa3b40ab7d9f8bced');
    expect(IxUpstream.iconsVersion, '3.5.0');
    expect(IxUpstream.iconsCommit, 'c46e1b13f7ccdaf66e4fcf2261f3765c55d45557');
  });
}
