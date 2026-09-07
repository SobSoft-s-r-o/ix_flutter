# Typography

- 1.x default UI family: Roboto Mono (deprecated). 2.0 default: Work Sans (OFL substitute for Siemens Sans).
- Opt in already in 1.x: `IxThemeBuilder(typography: IxTypography(fontFamily: IxFonts.workSans, package: IxFonts.packageName))`.
- Siemens Sans (license required): add the fonts to the application's `pubspec.yaml` and use `IxTypography(fontFamily: 'Siemens Sans')` (without `package`).
- Code styles: JetBrains Mono (`packages/ix_flutter/JetBrains Mono`).
- Scale: 23 iX formats + `buttonLabel` (14/700/1.429), `caption` (12/700/1.5), `textDefault` (14/400/1.429); all with `liga`/`clig` off.
