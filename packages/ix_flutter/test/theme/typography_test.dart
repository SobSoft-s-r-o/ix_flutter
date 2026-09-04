import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/upstream.dart';

void main() {
  // Metadata annotations can only precede a declaration, not a bare `test(...)`
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // that is invoked immediately below it (same convention as
  // palette_parity_test.dart / semantics_matrix_test.dart).
  @Upstream(
    'scss/mixins/_fonts.scss:178-210 typography-code uses JetBrainsMono',
  )
  void codeStylesReferenceBundledJetBrainsMonoViaPackagePrefix() {
    test(
      'code styles reference the bundled JetBrains Mono via package prefix',
      () {
        final t = IxTypography();
        expect(t.code.fontFamily, 'packages/ix_flutter/JetBrains Mono');
        expect(t.codeSm.fontFamily, 'packages/ix_flutter/JetBrains Mono');
        expect(t.codeLg.fontFamily, 'packages/ix_flutter/JetBrains Mono');
      },
    );
  }

  codeStylesReferenceBundledJetBrainsMonoViaPackagePrefix();

  test('UI styles keep the 1.x default family unchanged (no prefix)', () {
    final t = IxTypography();
    expect(t.body.fontFamily, IxFonts.robotoMono);
    expect(t.h1.fontFamily, IxFonts.robotoMono);
  });

  test('consumer can supply an app-level family without prefix', () {
    final t = IxTypography(fontFamily: 'Siemens Sans');
    expect(t.body.fontFamily, 'Siemens Sans');
    expect(t.body.fontFamilyFallback, IxFonts.robotoMonoFallback);
  });

  test('monospacePackage null removes the prefix', () {
    final t = IxTypography(
      monospaceFontFamily: 'Menlo',
      monospacePackage: null,
    );
    expect(t.code.fontFamily, 'Menlo');
  });
}
