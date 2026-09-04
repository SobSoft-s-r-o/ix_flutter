import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/upstream.dart';

/// Guards spec finding T-1 (bundled fonts must actually be used by consumer
/// apps): Flutter registers a package's bundled fonts under
/// `packages/<package>/<family>`, so `TextStyle` must pass `package:` to
/// resolve them. The first test below has a real upstream source
/// (`scss/mixins/_fonts.scss`) and carries its own `@Upstream` tag. The
/// remaining tests check our own `IxTypography` API surface — that the UI
/// family keeps its unprefixed 1.x default, that a consumer-supplied family
/// is never prefixed, and that `package`/`monospacePackage` round-trip
/// correctly (including through `copyWith`) — none of which has a Siemens
/// iX upstream counterpart (it is Flutter/Dart font-registration plumbing,
/// not a mirrored `.ct.ts`/scss/tsx behaviour), so they carry this
/// doc-comment instead of `@Upstream`.
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

  test('explicit monospacePackage override survives an unrelated copyWith', () {
    final custom = IxTypography(monospacePackage: 'my_org_fonts');
    final tweaked = custom.copyWith(fontFamily: 'Custom UI Sans');
    expect(tweaked.monospacePackage, 'my_org_fonts');
    expect(tweaked.code.fontFamily, 'packages/my_org_fonts/JetBrains Mono');
  });

  test('monospacePackage null opt-out survives an unrelated copyWith', () {
    final custom = IxTypography(monospacePackage: null);
    final tweaked = custom.copyWith(fontFamily: 'Custom UI Sans');
    expect(tweaked.monospacePackage, isNull);
    expect(tweaked.code.fontFamily, IxFonts.jetBrainsMono);
  });

  test('changing monospaceFontFamily via copyWith re-derives the package', () {
    final custom = IxTypography(
      monospaceFontFamily: 'Menlo',
      monospacePackage: null,
    );
    final tweaked = custom.copyWith(monospaceFontFamily: IxFonts.jetBrainsMono);
    expect(tweaked.monospacePackage, IxFonts.packageName);
    expect(tweaked.code.fontFamily, 'packages/ix_flutter/JetBrains Mono');
  });
}
