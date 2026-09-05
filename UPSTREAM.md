# Upstream baseline

| Source | Version | Tag | Commit | Evidence |
|---|---|---|---|---|
| `@siemens/ix` (core, source of truth) | 5.2.1 | `@siemens/ix@5.2.1` | `56dfa7514832e2c21c406a2aa3b40ab7d9f8bced` (2026-08-27) | `packages/core/package.json:10` |
| `@siemens/ix-icons` | 3.5.0 | `v3.5.0` (annotated `cfc99a850011c83f89fc71fe31bb1b7146c3629a`) | `c46e1b13f7ccdaf66e4fcf2261f3765c55d45557` (2026-08-04) | npm tarball `ix-icons-3.5.0.tgz` sha1 `be50b3f933c8a5e210f980245a3df9825e8bcb7b`, integrity `sha512-FP/7jnjoTfIvIah5OkJ7nLoXjyNy2rcUClGk29NLd4h/If/lz5liu7AMrCNKV9BTNCWQM8UI1wmoeF8xWz5d+A==`; `package.json` `license: MIT`; `LICENSE.md` MIT © 2022 Siemens AG; `READMEOSS.html` (third-party disclosure) |

Constants in code: `IxUpstream` (`packages/ix_flutter/lib/src/ix_core/ix_upstream.dart`).

## Release header format

Every `CHANGELOG.md` entry for a released version (the first section that is
not `[Unreleased]`) is immediately followed by one `Upstream:` line naming
the exact `@siemens/ix` and `@siemens/ix-icons` revisions the release was
verified against, as the tag plus the first 8 characters of the commit SHA:

```markdown
## [1.1.0] - 2026-10-01
Upstream: @siemens/ix@5.2.1 (56dfa751), @siemens/ix-icons v3.5.0 (c46e1b13)
```

`tool/upstream_check.dart` enforces that this line is present and matches
`IxUpstream`.

## Sync procedure

1. `dart run tool/sync_upstream_tokens.dart <tag>` (from `packages/ix_flutter`) → fixtures and the palette diff.
2. Update `IxUpstream` (`lib/src/ix_core/ix_upstream.dart`), the table above, and the `Upstream:` line under the release header in `CHANGELOG.md`.
3. `dart run tool/upstream_check.dart` must pass (it also runs in CI).

## Icon License

`@siemens/ix-icons` is published under MIT with no clause restricting redistribution. Redistribution requires keeping the copyright and permission notice (`LICENSE.md`) and including `READMEOSS.html`. This repository's earlier claim that icon use carried restrictive licensing and distribution terms (commit `4ebae21`, 2026-01-18) cited no source and has been removed.

**LEGAL REVIEW (open gate):** confirmation of trademark/brand-guideline usage for bundling 28 glyphs in `packages/ix_flutter/assets/icons/internal/` (the set contains no logos). Until approved, the default resolver is `IxIconResolver.material()`.

## Upcoming (main-only, not in any tag)

- PR #2632 (`0c952102075ef40aa5768488efe0198af143719a`, 2026-08-28): `scss/components/_table.scss` moved to `scss/utilities/_table.scss` (`.ix-table` with `--ix-table--*`), generated `--theme-<component>-*` replaced with `--ix-*`, `BREAKING_CHANGES/v6.md`. Watch for `IxResponsiveDataView` tokens and the component token layer.
- Migration to `--si-sys-*` tokens, icon color changes in `ix-blind`/`ix-toast`.

## Policy

Baseline = stable tag. `main` = early warning. Alpha/beta are not tracked without an explicit decision. Backport only security/a11y fixes with a reference to the upstream commit and dedicated tests.
