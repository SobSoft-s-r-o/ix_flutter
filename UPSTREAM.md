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
`IxUpstream`; it accepts the header with or without `[...]` brackets around
the version (see below).

`cider release` (run by the **Version Bump (Manual)** workflow) needs a
keep-a-changelog [link reference definition](https://spec.commonmark.org/0.31.2/#link-reference-definition)
for `[Unreleased]` and for every bracketed released version at the bottom of
each `CHANGELOG.md` -- without one, its markdown parser cannot tell a version
header (`## [1.0.2]`) from a literal, unresolved link, and `release` appends
an empty, bracket-less section at the end of the file instead of turning
`[Unreleased]` into the new release in place. Both `CHANGELOG.md`s carry
these already:

```markdown
[Unreleased]: https://github.com/SobSoft-s-r-o/ix_flutter/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/SobSoft-s-r-o/ix_flutter/releases/tag/v1.0.2
```

**After every release**, update these: point `[Unreleased]` at
`compare/v<new>...HEAD` and add a `[<new>]` definition for the version just
released (`compare/v<previous>...v<new>`, or `releases/tag/v<new>` for the
first one) -- otherwise the *next* cycle's `[Unreleased]` has no definition
and the mangling above returns. The header `cider release` writes for the new
section itself has no brackets (`## 1.1.0 - 2026-09-06`, not `## [1.1.0]`);
that is what `tool/upstream_check.dart`'s regex tolerating both forms is for
-- it is not worth fighting cider's own output shape.

`cider release`'s markdown round-trip is not fully lossless beyond that: it
can drop or reflow content outside the keep-a-changelog release structure it
recognizes (this project's trailing `## Versioning`/`## Breaking
Changes`/`## Migration Guides`/`## Contributors`/`## License` sections and
the closing links), and it backslash-escapes stray `_`/`~` characters in
plain prose it re-serializes. **Diff `CHANGELOG.md` carefully** in the
Version Bump pull request (not just the new release section) and restore
anything it dropped from git history before merging.

## Sync procedure

1. `dart run tool/sync_upstream_tokens.dart <tag>` (from `packages/ix_flutter`) → fixtures and the palette diff. `--tag <tag>` is equivalent; `--repo <url-or-local-path>` overrides the cloned source (default `https://github.com/siemens/ix`).
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
