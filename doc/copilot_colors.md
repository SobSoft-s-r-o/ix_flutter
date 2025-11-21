# Siemens IX Color Notes for Copilot

_Source: [Siemens IX Design System – Colors](https://ix.siemens.io/docs/styles/colors) (accessed 21 Nov 2025)_

Use this cheat sheet when crafting Copilot prompts that have to align with Siemens IX color guidance.

## Background Colors
- Reserved for non-interactive surfaces (app canvas, panels, etc.).
- All values are fully opaque except `color-0`, which is transparent for overlay layering.
- Tokens: `color0` – `color8`, `backdrop`, `backdrop3`, `lightbox` (see `IxThemeColorToken`).

## Component & Interaction Colors
- Applied to interactive controls (buttons, cards, toggles) including hover, active, and selected states.
- `primary` colors equal the brand hue; `dynamic-alt` variants are rare and help differentiate special ranges (e.g., date pickers).
- `color-component-1` tokens target filled interactive areas such as cards and rely on semi-transparent values to adapt to most backgrounds.
- "Ghost" tokens are for controls without visible fills but with hover/active feedback; the `ghost-alt` set supports alternating table rows.
- A handful of component colors are solid/opaque and therefore require a specific background or accompanying border (outline buttons, fields, etc.).
- Some tokens are reserved for niche components such as the calendar in the date picker.
- Tokens: `component1`/`component1Active`/`component1Hover`, `component2` – `component11`, `componentError`, `componentInfo`, `componentWarning`, `primary*`, `secondary*`, `dynamic*`, `dynamicAlt*`, `ghost*`, `ghostAlt*`, `ghostPrimary*`, `focusBdr`.

## Status Colors
- Cover the states Alarm (error), Critical, Warning, Success, Info, and Neutral.
- Each status provides hover/active variants plus a matching `...-contrast` color suitable for text/icons on the status fill.
- Semi-transparent “10/40” versions exist for subtle backgrounds.
- Avoid using the standard status fills for text copy—only `color-alarm-text` is approved for messaging; otherwise use text tokens.
- Tokens: `alarm*`, `critical*`, `warning*`, `success*`, `info*`, `neutral*` (all variants listed in `IxThemeColorToken`).

## Text Colors
- `color-contrast-text` is the darkest/lightest fallback when the background is unpredictable.
- `color-std-text` is the default for body copy and icons.
- `color-soft-text` handles secondary labels, hints, or placeholders; `color-weak-text` signals disabled content.
- `color-alarm-text` is reserved for error or danger copy.
- `color-inv-*` values support inverted contexts (e.g., light text on dark backgrounds in dark mode).
- Tokens: `contrastText`, `stdText`, `softText`, `weakText`, `invStdText`, `invSoftText`, `invWeakText`, `invContrastText`, `alarmText`.

## Border Colors
- `color-contrast-bdr` is the most pronounced border for unknown backgrounds.
- `color-hard-bdr` is solid/opaque; `color-std-bdr` is the strong default (e.g., inputs).
- `color-soft-bdr`, `color-weak-bdr`, and `color-x-weak-bdr` progressively soften separation lines for cards, layout sections, or subtle structure.
- Tokens: `contrastBdr`, `hardBdr`, `stdBdr`, `softBdr`, `weakBdr`, `xWeakBdr`, `warningBdr`, `alarmBdr`.

## Effect Colors
- `color-lightbox` and `color-backdrop` drive modal/overlay treatments with blur support.
- Gradient tokens provide brand gradients (e.g., hero numbers, error pages).
- Tokens: `lightbox`, `backdrop`, `backdrop3`, `gradientEffect1`, `gradientEffect2`, plus `shadow1` – `shadow3` for elevation.

## Chart Infrastructure Colors
- Dedicated hues for axes, ticks, grid lines/fills, tooltips, and tooltip borders so chart chrome stays consistent.

## Chart Data Colors
- Recommended palette for chart series; each base color has a `...-40` (40% opacity) companion for comparisons (current vs. previous, target vs. actual, etc.).

## Color Series for Charts
- Siemens IX suggests an ordered series to maximize distinction between multiple datasets; reuse the published order for multi-series charts.
