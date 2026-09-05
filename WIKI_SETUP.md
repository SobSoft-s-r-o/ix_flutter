# Wiki Sync

The GitHub wiki at https://github.com/SobSoft-s-r-o/ix_flutter/wiki is **generated** from this repository. It is not a git submodule, it is not edited by hand, and a fresh clone of this repository never needs to initialize it.

## How it works

The [`wiki-sync.yml`](.github/workflows/wiki-sync.yml) workflow performs a **one-way** sync — repository to wiki, never the other direction — after every merge to `main`:

1. A `push` to `main` touching `doc/**`, a root `*.md`, `packages/ix_flutter/*.md`, or `tool/wiki_sync*` triggers the workflow.
2. The workflow checks out this repository and, separately, `SobSoft-s-r-o/ix_flutter.wiki` (into `wiki-checkout`).
3. `tool/wiki_sync.sh wiki-checkout` copies every file listed in the mapping below into the wiki checkout. Local links are rewritten so they still work on the wiki: a link to another synced document (e.g. `doc/theming.md`, `GETTING_STARTED.md`, `#anchor` included) becomes a bare wiki page name (`theming`, `Getting-Started`); a link to anything else in the repository (source under `packages/`, `example/`, `.github/`, images, directories, `UPSTREAM.md`, `DOCUMENTATION.md`, …) becomes an absolute `https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/…` (or `tree/main/…` for a directory) URL instead of a dead relative path.
4. If the wiki checkout changed, the workflow commits and pushes it as `github-actions[bot]`.

## Mapping

The source-to-destination mapping lives in [`tool/wiki_sync_map.txt`](tool/wiki_sync_map.txt) as `source -> destination` lines, for example:

```text
README.md -> Home.md
GETTING_STARTED.md -> Getting-Started.md
doc/ix_icons.md -> ix_icons.md
```

To publish a new canonical document to the wiki, add a line to that file — the workflow and `tool/wiki_sync.sh` need no other changes.

## Manual edits are overwritten

**Do not edit wiki pages directly.** Any push to `main` that touches a synced source file overwrites the corresponding wiki page on the next sync. Edit the canonical document in this repository instead (see the mapping above) and let the workflow publish it.

## Orphaned pages

The sync only ever writes the pages listed in `tool/wiki_sync_map.txt`; it never deletes a wiki page. Any existing wiki page that is not a sync destination — currently `Installation.md` (superseded; its unique steps are now in [`GETTING_STARTED.md`](GETTING_STARTED.md)) and `copilot_colors.md` (no canonical source in this repository) — is left untouched by every run and will keep drifting out of date. Delete pages like these from the wiki by hand once their replacement content has synced.

## Secret

The workflow authenticates to the wiki repository with the `WIKI_SYNC_TOKEN` repository secret — a GitHub personal access token with `repo` scope. It is required because wiki repositories are not covered by the workflow's default `GITHUB_TOKEN`.

## Dry run

Trigger the workflow manually from the Actions tab (`workflow_dispatch`) with `dry_run: true` (the default) to print the planned copies without touching the wiki repository. Use `dry_run: false` to run a real sync on demand, outside of the `push`-to-`main` trigger.

Locally, `tool/wiki_sync.sh --dry-run <wiki-checkout-dir>` prints the same plan against any wiki checkout on disk without writing anything; `tool/wiki_sync.sh <wiki-checkout-dir>` performs the sync.
