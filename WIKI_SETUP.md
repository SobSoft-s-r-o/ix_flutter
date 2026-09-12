# Wiki Sync

The GitHub wiki at https://github.com/SobSoft-s-r-o/ix_flutter/wiki is **generated** from this repository. It is not a git submodule, it is not edited by hand, and a fresh clone of this repository never needs to initialize it.

## How it works

The [`wiki-sync.yml`](.github/workflows/wiki-sync.yml) workflow performs a **one-way** sync — repository to wiki, never the other direction — after every merge to `main`:

1. A `push` to `main` touching `doc/**`, a root `*.md`, `packages/ix_flutter/*.md`, `packages/ix_icons_generator/*.md`, or `tool/wiki_sync*` triggers the workflow.
2. A dry run needs only this repository. A real sync clones the wiki through
   the Git endpoint `https://github.com/SobSoft-s-r-o/ix_flutter.wiki.git`
   into `wiki-checkout`.
3. `tool/wiki_sync.sh wiki-checkout` copies every file listed in the mapping below into the wiki checkout. Local links are rewritten so they still work on the wiki:
   - a link to another synced document (e.g. `doc/theming.md`, `GETTING_STARTED.md`, `#anchor` included) becomes a bare wiki page name (`theming`, `Getting-Started`);
   - an **image** (`![alt](…)`) becomes a `https://raw.githubusercontent.com/SobSoft-s-r-o/ix_flutter/main/…` URL. It must not become a `blob/` URL: GitHub serves `blob/main/<path>.png` as the file-viewer HTML page (`Content-Type: text/html`), so the image renders broken;
   - a link to anything else in the repository (source under `packages/`, `example/`, `.github/`, directories, `UPSTREAM.md`, `DOCUMENTATION.md`, …) becomes an absolute `https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/…` (or `tree/main/…` for a directory) URL instead of a dead relative path.

   Because those absolute URLs name `main`, a page that links to a file added by an unmerged branch resolves only after the merge — which is also when the sync runs, so the published wiki never links to a file `main` does not have.
4. If the wiki checkout changed, the workflow commits and pushes it as `github-actions[bot]`.

The `paths:` filter in the workflow must list every directory the mapping draws from, or a change to a source file never triggers a sync.

## Mapping

The source-to-destination mapping lives in [`tool/wiki_sync_map.txt`](tool/wiki_sync_map.txt) as `source -> destination` lines, for example:

```text
README.md -> Home.md
GETTING_STARTED.md -> Getting-Started.md
doc/ix_icons.md -> ix_icons.md
```

To publish a new canonical document to the wiki, add a line to that file, and make sure the workflow's `paths:` filter covers its directory.

### Wiki-only pages

A GitHub wiki has pages with no counterpart in the repository: the navigation sidebar, the footer, and a redirect standing in for a page that moved. These are still **generated, not hand-edited** — their sources live in [`doc/wiki/`](doc/wiki/) and are mapped like any other document:

```text
doc/wiki/_Sidebar.md -> _Sidebar.md
doc/wiki/_Footer.md -> _Footer.md
doc/wiki/Installation.md -> Installation.md
```

Write their links as ordinary repository-relative paths (`../../GETTING_STARTED.md`, `../theming.md`). The sync rewrites them to wiki page names, and the repository's own link checker verifies them in place.

## Manual edits are overwritten

**Do not edit wiki pages directly.** Any push to `main` that touches a synced source file overwrites the corresponding wiki page on the next sync. Edit the canonical document in this repository instead (see the mapping above) and let the workflow publish it.

## Orphaned pages

The sync only ever writes the pages listed in `tool/wiki_sync_map.txt`; it never deletes a wiki page. Any existing wiki page that is not a sync destination is left untouched by every run and will keep drifting out of date.

Two such pages existed, and they are handled differently because they are different things:

- **`Installation.md`** was a second, hand-maintained copy of the getting-started guide, and had drifted — it still advertised the 1.0.2-era dependency constraints. It is now a sync destination generated from [`doc/wiki/Installation.md`](doc/wiki/Installation.md): a short pointer to [`GETTING_STARTED.md`](GETTING_STARTED.md). A redirect rather than a deletion, so existing links to the page keep working.
- **`copilot_colors.md`** is authored content with no canonical source in this repository (Siemens iX colour guidance notes). It is **not** deleted and not overwritten; it is linked from the generated sidebar so it stays reachable.

Prefer a generated redirect over deleting a page. If a page really must go, delete it from the wiki by hand — and only once nothing links to it.

## Secret

The workflow authenticates a real wiki Git clone and push with the
`WIKI_SYNC_TOKEN` repository secret — a GitHub personal access token with
`repo` scope. Wiki repositories are not covered by the workflow's default
`GITHUB_TOKEN`. If the secret is missing, a real sync fails immediately with
an actionable error; it does not report a successful publication. Do not copy
a personal token into source, workflow YAML, logs, or another secret name.

At the time the 1.1.0 release metadata was prepared, this repository did not
have `WIKI_SYNC_TOKEN` configured. Token-free dry runs remain available. A
maintainer with an authenticated Git credential can also perform the real
sync locally without creating or copying a repository secret.

## Dry run

Trigger the workflow manually from the Actions tab (`workflow_dispatch`) with
`dry_run: true` (the default) to print the planned copies without a wiki
checkout or credential. Use `dry_run: false` to run a real sync on demand,
outside of the `push`-to-`main` trigger; that path requires
`WIKI_SYNC_TOKEN`.

Locally, `tool/wiki_sync.sh --dry-run <unused-dir>` prints the same plan
without requiring that directory to exist and without writing anything. A
real local sync uses a disposable clone, never the user's original `wiki/`
directory:

```bash
git clone https://github.com/SobSoft-s-r-o/ix_flutter.wiki.git /private/tmp/ix-flutter-wiki-sync
tool/wiki_sync.sh /private/tmp/ix-flutter-wiki-sync
git -C /private/tmp/ix-flutter-wiki-sync diff --check
git -C /private/tmp/ix-flutter-wiki-sync add -A
git -C /private/tmp/ix-flutter-wiki-sync commit -m "docs: sync from ix_flutter"
git -C /private/tmp/ix-flutter-wiki-sync push
```

The clone and push use the maintainer's existing Git credential. Review the
diff before committing; if there are no changes, state that the remote wiki
is already current rather than claiming pages were published.

**A dry run only prints the copy plan.** It does not run the link rewriting, so it proves nothing about the generated pages. To check a change to the sync itself, clone the wiki into a throwaway directory, run the real sync into it, read the diff, and run it a second time — the second run must produce byte-identical files. `packages/ix_flutter/test/tool/wiki_sync_test.dart` covers the rewriting rules directly.
