# Density

`IxDensity` is the adaptive policy that controls how much hit area Siemens
IX interactive controls (buttons, checkboxes, radios, switches, sliders,
`IxIconButton`) get, based on whether the app is being used with a pointer
(mouse, trackpad, TV remote) or with touch.

| Density | Who it targets | Hit area |
|---|---|---|
| `IxDensity.compact` | Pointer/keyboard (mouse connected, or `NavigationMode.directional`) | Equals the visual size (no extra padding) |
| `IxDensity.comfortable` | Touch (no pointer, or any viewport narrower than 600px) | Visual size padded out to at least 48x48, per WCAG 2.5.8 |
| `IxDensity.adaptive` (default) | -- | Resolves to one of the two above at runtime, per control/build |

Only the *hit area* changes between densities in this 1.x release. The
*visual* size of `FilledButton`/`OutlinedButton`/`TextButton`/checkbox/
radio/switch stays at its existing 40px height; `IxIconButton` stays at
32/24/16px. The 40px -> 32px visual change for the standard controls lands
in 2.0 (plan `breaking-2-0`, item B-4).

## Resolution rules

`IxDensity.resolve(context)` (never returns `adaptive`) applies, in order:

1. Viewport width < 600 logical pixels -> always `comfortable` (a small
   screen implies touch, regardless of any connected mouse).
2. A connected mouse (`RendererBinding.instance.mouseTracker.mouseIsConnected`)
   or `MediaQuery.navigationModeOf(context) == NavigationMode.directional`
   (TV/remote-control navigation) -> `compact`.
3. Otherwise (touch, no pointer) -> `comfortable`.

`IxDensity.effectiveOf(context)` is what widgets actually call. Its
precedence is:

```
IxDensityScope (nearest ancestor) > IxThemeBuilder(density:) > adaptive
```

An explicit `IxDensityScope(density: ...)` always wins over whatever
`IxThemeBuilder(density:)` was set to; `IxDensity.adaptive` (from either
source) is resolved live via `IxDensity.resolve`.

## Recommended usage

Wrap the app once, below `MaterialApp.builder`, so every descendant shares
the same resolved density and re-themed Material component tap targets:

```dart
MaterialApp(
  theme: const IxThemeBuilder().build(),
  builder: (context, child) =>
      IxDensityScope(child: child ?? const SizedBox.shrink()),
  home: const MyHome(),
)
```

`IxDensityScope` listens to `RendererBinding.instance.mouseTracker`, so it
re-resolves `adaptive` whenever a mouse connects or disconnects (in
addition to normal rebuilds), and re-themes `materialTapTargetSize` plus
the button/checkbox/radio/switch/slider theme data it wraps to match.

### Overriding for a subtree

Pin a subtree to a specific density regardless of input modality by
nesting another `IxDensityScope`:

```dart
IxDensityScope(
  density: IxDensity.compact, // e.g. a dense data-table toolbar
  child: MyToolbar(),
)
```

### Choosing a static default without `IxDensityScope`

`IxThemeBuilder(density: IxDensity.compact)` bakes a fixed density into
the built `ThemeData` for apps that don't use `IxDensityScope` at all (for
example, if `MaterialApp.theme` is constructed once outside of any
`BuildContext` and modality never needs to be resolved at runtime). Left
at the default `IxDensity.adaptive`, `IxThemeBuilder.build()` still bakes
in `comfortable` tap targets as a touch-safe static default (there is no
`BuildContext` available inside `build()` to resolve modality from) --
wrap the app in `IxDensityScope` to get live resolution instead.

## `IxIconButton`

`IxIconButton` is a square, icon-only Siemens IX button with three fixed
visual sizes, each with a matching icon size:

| `IxIconButtonSize` | Visual size | Icon size |
|---|---|---|
| `s32` (default) | 32x32 | 24 |
| `s24` | 24x24 | 16 |
| `s16` | 16x16 | 12 |

```dart
IxIconButton(
  icon: const Icon(Icons.close),
  onPressed: () {},
  tooltip: 'Close',
)
```

Like the other Siemens IX controls, its hit area grows to 48x48 in
`IxDensity.comfortable` without changing its visual size; pass `variant:`
to pick a button style (defaults to `IxButtonVariant.subtleTertiary`) and
`oval: true` for a circular shape. `tooltip` shows a visible hint and is
also merged into the button's accessible label unless `semanticLabel` is
given explicitly.
