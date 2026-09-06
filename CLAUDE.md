# Repository rules for AI assistants

## Language

- Everything committed to this repository is written in **English**: source code comments and dartdoc, tests and their comments, documentation (`README.md`, `doc/`, `docs/`, `CHANGELOG.md`, `CONTRIBUTING.md`, …), commit messages, pull request descriptions, CI workflow comments, tool scripts, and every Superpowers document (`docs/superpowers/specs/`, `docs/superpowers/plans/`).
- No other language may appear in the repository. The only exception is translation/localization files (for example `*.arb`, `*.po`, `*.json` message catalogues, or a `translations/` directory), which carry the target language of the translation.
- User-facing strings in the library default to English; localized copies belong to consumers through the `Ix*Strings` classes.
- When a task brief, plan or conversation is written in another language, treat it as a specification: the artefacts you produce (code, docs, comments, plans, reports committed to the repo) are still English.

## Subagent models

- Use **Sonnet** for ordinary subagent work: mechanical implementation from a complete brief, single-file fixes, scoped re-reviews, verification probes, transcription and formatting tasks.
- Use **Opus** only for genuinely complex tasks: multi-file changes that need design judgment, subtle concurrency/focus/semantics work, large-diff reviews, and fix rounds where a Sonnet implementer got stuck.
- Use **Haiku** for trivial lookups and tiny re-reviews. Always name the model explicitly when dispatching a subagent; never let it default to the session's model.

## Verification before completion

- Run the package suites (`packages/ix_flutter`, `packages/ix_icons_generator`, `example`, `doc/snippets`), `flutter analyze`, `dart format --set-exit-if-changed`, `dart pub publish --dry-run` and the `tool/*.sh` checks before claiming a change is done.
