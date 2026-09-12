# Icon Licensing

`ix_icons_generator` is licensed under the MIT License in [LICENSE](LICENSE).
The generated SVG assets come from the official `@siemens/ix-icons` npm
package and remain subject to that selected package version's notices.

The generator copies `LICENSE.md` and `READMEOSS.html` byte-for-byte from the
selected npm package into the generated asset directory. Keep both files with
the SVGs when retaining or redistributing generated assets. Generation stops
before replacing existing SVGs when either source notice is missing or empty.

The default upstream source is pinned as follows:

- Package: `@siemens/ix-icons` 3.5.0
- Tag: `v3.5.0`
- Commit: `c46e1b13f7ccdaf66e4fcf2261f3765c55d45557`
- npm tarball SHA1: `be50b3f933c8a5e210f980245a3df9825e8bcb7b`
- Declared license: MIT; `LICENSE.md` copyright © 2022 Siemens AG
- Disclosure supplied by upstream: `READMEOSS.html`

Selecting another version with `--icons-version` uses and preserves the notice
files from that version rather than substituting the default version's text.
Siemens trademarks and brand guidelines are separate from the upstream MIT
copyright license.

This package is an independent, community-maintained adaptation. It is not
developed, maintained, endorsed, or sponsored by Siemens AG.
