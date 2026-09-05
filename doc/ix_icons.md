# Siemens iX Icons

Guide to using Siemens iX Design System icons in `ix_flutter`.

## Table of Contents

- [Overview](#overview)
- [Internal Icons](#internal-icons)
- [Full Icon Catalogue](#full-icon-catalogue)
- [API](#api)
  - [IxIcon](#ixicon)
  - [IxIconData](#ixicondata)
  - [IxIconSize](#ixiconsize)
  - [IxIconResolver](#ixiconresolver)
  - [Overriding icons with IxThemeBuilder](#overriding-icons-with-ixthemebuilder)
  - [Sizing](#sizing)
- [Fallback Policy](#fallback-policy)
- [Dependencies](#dependencies)
- [License](#license)
- [Version](#version)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## Overview

`ix_flutter` renders every icon through one widget, `IxIcon`, backed by one of two sources:

1. **Internal icons** — a small, fixed set of icons the library's own widgets need (chevrons, close, search, status glyphs, …), addressed by the semantic `IxIconKey` enum. No setup or generator required. See [Internal Icons](#internal-icons).
2. **Full icon catalogue** — the complete `@siemens/ix-icons` set (1 479 icons in version 3.5.0), generated into your own app as `IxIconsData` constants by the optional `ix_icons_generator` tool. See [Full Icon Catalogue](#full-icon-catalogue).

Both sources render through the same `IxIcon` widget and share the same [fallback policy](#fallback-policy): a missing or corrupt SVG never crashes the UI or changes layout — it falls back to a Material glyph at the same size.

## Internal Icons

`ix_flutter`'s own widgets (pagination, dropdowns, toasts, the application scaffold, …) need a small, fixed set of icons — 28 keys, enumerated in `IxIconKey`. Library code never imports your generated `IxIcons`/`IxIconsData`; internal widgets always resolve icons through `IxIcon.key`:

```dart
Widget internalKeyIcon() => const IxIcon.key(IxIconKey.home);
```

Once the LEGAL REVIEW gate documented in `UPSTREAM.md` is passed, the library will bundle these 28 icons as SVG assets under `packages/ix_flutter/assets/icons/internal/`, with the MIT notice in `packages/ix_flutter/assets/icons/internal/NOTICE`; until then library widgets fall back to Material glyphs through `IxIconResolver.material()` — see [Fallback Policy](#fallback-policy). This affects only the library's own internal rendering; it does not block using `IxIcon`/`IxIconData` or the full-catalogue generator in your own app today.

## Full Icon Catalogue

The complete Siemens iX icon set is optional. Generate it into your own app with `ix_icons_generator` — this is the only supported install/run path:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

```bash
dart run ix_icons_generator:generate_icons            # default: @siemens/ix-icons 3.5.0
dart run ix_icons_generator:generate_icons --icons-version 3.5.0 -a assets/ix_icons
```

Running it:

- Downloads the pinned `@siemens/ix-icons` release (1 479 icons in 3.5.0) from the official npm package.
- Writes SVG assets into your assets directory (default `assets/svg/`; override with `-a`/`--assets`).
- Generates `lib/ix_icons.dart` with `IxIconsData` constants for `IxIcon`, plus — by default — deprecated `IxIcons` widget getters kept for source compatibility (see `--no-legacy-getters`).
- Updates your `pubspec.yaml` with the asset paths.

Use the generated constants with `IxIcon`:

```dart
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';

Widget catalogueIcon() => const IxIcon(IxIconsData.home);
```

Command line options (`dart run ix_icons_generator:generate_icons --help`):

| Option | Short | Description | Default |
|---|---|---|---|
| `--project-root` | `-p` | Root directory of the Flutter project | current directory |
| `--output` | `-o` | Output directory for generated Dart code | `lib` |
| `--assets` | `-a` | Assets directory for SVG files | `assets/svg` |
| `--package` | `-n` | Package name, for cross-package asset loading | none |
| `--icons-version` |  | `@siemens/ix-icons` version to download — a pinned version, selectable with `--icons-version` | `3.5.0` |
| `--[no-]legacy-getters` |  | Emit deprecated `IxIcons` widget getters | on |
| `--help` | `-h` | Show help | |

Building a library package that ships generated icons to its own consumers: pass `-n`/`--package` with your package name so the generated code loads assets from the right place.

## API

### IxIcon

`IxIcon` is a `StatelessWidget` that renders one icon, from either an explicit `IxIconData` or — via `IxIcon.key` — whatever the ambient `IxIconResolver` maps an `IxIconKey` to:

```dart
Widget bothIconSources() => const Row(
  children: [
    IxIcon(IxIconsData.home), // explicit data (generated catalogue)
    IxIcon.key(IxIconKey.home), // resolver-driven (internal keys)
  ],
);
```

Constructor parameters: `size` (`IxIconSize?`, defaulting to the ambient `IconTheme` size and then 24px — see [Sizing](#sizing)), `color`, `colorToken` (an `IxThemeColorToken`, used when `color` is unset), `semanticLabel`, and `excludeFromSemantics`.

### IxIconData

A sealed class describing where an icon's visual content comes from:

- `IxIconData.packageAsset(name, {fallback, semanticLabel})` — bundled with `ix_flutter` itself.
- `IxIconData.asset(assetPath, {package, fallback, semanticLabel})` — an SVG from your own (or another package's) assets; this is what the generator emits as `IxIconsData.*` constants.
- `IxIconData.material(icon, {semanticLabel})` — a plain Material `IconData` glyph.
- `IxIconData.widget(builder, {fallback, semanticLabel})` — a fully custom widget.

`fallback` (a Material `IconData`) is only ever used if the primary source fails to load or decode.

### IxIconSize

A fixed set of square sizes: `s12`, `s16`, `s24`, `s32` — mirroring the Siemens iX `ix-icon` element's own size variants. `IxIcon.size` is optional; see [Sizing](#sizing) for what an `IxIcon` renders at when it is left unset.

### IxIconResolver

A `ThemeExtension<IxIconResolver>` that maps every `IxIconKey` to concrete `IxIconData`. `IxIconResolver.material()` maps all 28 keys to Material glyphs and is the default `IxThemeBuilder` registers. `IxIconResolver.of(context)` resolves the ambient resolver, or `.material()` if none is registered.

### Overriding icons with IxThemeBuilder

Register a custom resolver — for example, once the bundled SVG set ships, or to swap in your own asset — with `IxThemeBuilder(icons:)`:

```dart
ThemeData themeWithCustomIcon() => IxThemeBuilder(
  icons: IxIconResolver.material().copyWith(
    icons: {IxIconKey.home: const IxIconData.asset('assets/custom/home.svg')},
  ),
).build();
```

`copyWith` merges the given keys over `IxIconResolver.material()`'s full map, so the result always stays resolvable for every `IxIconKey`.

### Sizing

`IxIcon` always renders inside a fixed square box. Its edge length is:

1. the explicit `size:` (`IxIconSize.s12`/`s16`/`s24`/`s32`), if given;
2. otherwise the ambient `IconTheme.size`, used exactly as given — including values that are not `IxIconSize` steps, such as the 18px `TextButton.icon` styles its icon at;
3. otherwise 24px, which is also `MaterialApp`'s own `IconTheme` default, so an `IxIcon` outside any custom `IconTheme` is unchanged.

That makes `IxIcon` interchangeable with a Material `Icon` in any slot that sizes its icon through an `IconTheme` — `IxIconButton`, `TextButton.icon`, `InputDecoration.prefixIcon` — while an explicit `size:` still wins over whatever the surrounding slot asks for:

```dart
// IxIconButton sizes its icon via a merged IconTheme, which IxIcon reads:
// an IxIconButtonSize.s24 button renders its icon at 16px on its own. Pass
// `size:` only to override that.
Widget closeButtonWithCatalogueIcon(VoidCallback onPressed) => IxIconButton(
  icon: const IxIcon(IxIconsData.close), // 16px, from the button's slot
  size: IxIconButtonSize.s24,
  onPressed: onPressed,
);
```

## Fallback Policy

`IxIcon` only ever falls back to a Material glyph in three cases:

1. **No SVG set is bundled yet.** While the LEGAL REVIEW gate in `UPSTREAM.md` is open, `IxThemeBuilder` registers `IxIconResolver.material()` by default, so internal library icons render as Material glyphs.
2. **The primary source fails.** A missing or corrupt SVG asset (package or app), or an SVG the decoder rejects. `IxIcon` swaps in `IxIconData.fallback` (or `Icons.broken_image` if none was given) at the same size, and — in debug builds — reports the failure through `FlutterError.reportError` under the `ix_flutter icons` library name, so it surfaces in your error console without crashing the UI.
3. **An explicit request.** Code that constructs `IxIconResolver.material()` or `IxIconData.material(...)` directly.

On the successful path, iX and Material glyphs are never mixed for the same icon. In every case, falling back never changes the icon's `SizedBox` dimension, hit area, or `Semantics` — only the glyph itself changes.

## Dependencies

- `ix_flutter` depends on `flutter_svg` directly because it renders its bundled internal icons.
- Apps do **not** need to declare `flutter_svg`: generated icon code (generator ≥ 1.1.0) uses `IxIcon`/`IxIconData`.
- If the icon runtime is extracted into a separate package in the future, `flutter_svg` moves with it.

## License

`@siemens/ix-icons` is MIT-licensed (Copyright (c) 2022 Siemens AG); see `UPSTREAM.md` for the exact version, tag, commit and tarball checksum. `ix_flutter` itself (widgets, the `IxIcon`/`IxIconResolver` runtime, the generator) is also MIT — see `LICENSE`.

- Once the LEGAL REVIEW gate documented in `UPSTREAM.md` is passed, the library will bundle a minimal internal set (28 icons) required by its own widgets, with the MIT notice in `packages/ix_flutter/assets/icons/internal/NOTICE`; until then library widgets fall back to Material glyphs through `IxIconResolver.material()`.
- The full catalogue (1 479 icons in 3.5.0) is optional and generated into your app with `dart run ix_icons_generator:generate_icons`.
- Redistribution keeps the MIT copyright/permission notice and `READMEOSS.html`. Siemens trademarks and brand guidelines are separate from the MIT copyright license — see `ICON_LICENSING.md`.

## Version

The library is verified against a single pinned `@siemens/ix-icons` release:

| | |
|---|---|
| Version | 3.5.0 |
| Tag | `v3.5.0` |
| Commit | `c46e1b13f7ccdaf66e4fcf2261f3765c55d45557` |
| Tarball sha1 | `be50b3f933c8a5e210f980245a3df9825e8bcb7b` |
| Icon count | 1 479 |

This is a pinned version, selectable with `--icons-version` — the generator downloads whichever version you ask for, though only the default is verified against the internal-icon baseline. The same value is exposed at runtime as `IxUpstream.iconsVersion` (`packages/ix_flutter/lib/src/ix_core/ix_upstream.dart`) and recorded in `UPSTREAM.md`.

## Troubleshooting

### Full-catalogue icons don't show up

1. Confirm you ran the generator (see [Full Icon Catalogue](#full-icon-catalogue)) and that `pubspec.yaml` lists your assets directory under `flutter: assets:`.
2. Run `flutter clean && flutter pub get` and rebuild.
3. Check the import — `import 'package:your_app/ix_icons.dart';` (your app's package name, not `ix_flutter`).
4. If a specific icon renders as a Material glyph instead of the iX glyph, check the debug console: `IxIcon` reports SVG decode failures there (see [Fallback Policy](#fallback-policy)) instead of failing silently.

### Generator fails to download icons

1. Check your internet connection and access to `https://registry.npmjs.org`.
2. Check proxy/firewall settings if you're behind one.
3. Retry — network issues are often transient.

### Generated file has formatting or compile errors

- The generated file is not run through `dart format`; if your project checks formatting, run `dart format lib/ix_icons.dart` after generating.
- Don't hand-edit the generated file — regenerate instead: `rm lib/ix_icons.dart && dart run ix_icons_generator:generate_icons`.
- Make sure `ix_flutter` and `ix_icons_generator` are both up to date: `flutter pub upgrade ix_flutter ix_icons_generator`.

## FAQ

### Do I need to run the generator?

No. `ix_flutter`'s own widgets render their icons from the internal `IxIconKey` set (falling back to Material glyphs today; see [Internal Icons](#internal-icons)) — no generator required. Run `ix_icons_generator` only if your own code wants icons from the full 1 479-icon catalogue.

### How do I update to a newer icon set?

Re-run the generator with `--icons-version`, e.g. `dart run ix_icons_generator:generate_icons --icons-version 3.5.0`. The default version only changes when `ix_icons_generator` itself is updated — see its `CHANGELOG.md`.

### Can I customize specific icons?

Yes. After generating, edit any SVG file in your assets directory directly — your changes are used as-is until you regenerate. To swap an icon programmatically without editing files, see [Overriding icons with IxThemeBuilder](#overriding-icons-with-ixthemebuilder).

### How large is the generated catalogue?

The generator writes 1 479 SVG files to your project. Flutter's build system only bundles the assets your code actually references, so your shipped app size reflects only the icons you use.

### Why did an icon render as a Material glyph instead of the iX glyph?

Either you used `IxIcon.key(...)` and the LEGAL REVIEW gate for the internal set hasn't passed yet (see [Fallback Policy](#fallback-policy)), or the underlying SVG asset failed to load — check the debug console for a reported error.

### Do icons work on all platforms?

Yes. `IxIcon` renders SVGs through `flutter_svg` (a direct `ix_flutter` dependency; see [Dependencies](#dependencies)) and Material glyphs through the framework, both of which support Android, iOS, web, macOS, Windows and Linux.

### What's the difference between `IxIcon` and the deprecated `IxIcons.<name>` getters?

`IxIcons.<name>` getters are generated for backward compatibility (pass `--no-legacy-getters` to skip them) and are removed in `ix_icons_generator` 2.0. They render an unsized `IxIcon`, which follows the ambient `IconTheme.size` (24px when none is set) exactly as the 1.x getters did — migrate to `IxIcon(IxIconsData.<name>)`, passing `size:` where you want a size of your own. See `ICON_MIGRATION.md` and `packages/ix_icons_generator/CHANGELOG.md`.

---

## Need Help?

- **Siemens iX Design System:** https://ix.siemens.io
- **Icon Library:** https://ix.siemens.io/docs/icons/icon-library
- **Package Issues:** [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
