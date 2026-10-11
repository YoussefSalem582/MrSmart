# CLAUDE.md

Before planning or any work, read the newest session handoff in
[tech_readme_files/handoff/](tech_readme_files/handoff/). Conventions for this
repo live in [AGENTS.md](AGENTS.md) — read that first, always. This file
only covers tool-use rules specific to working here.

- **This repository is PUBLIC.** Follow "PUBLIC REPOSITORY" in AGENTS.md:
  before every commit read `git diff --cached` for secrets, real IPs/hosts,
  emails, absolute paths and private/work project names. Machine-specific
  notes go in `CLAUDE.local.md` (git-ignored), never in tracked files.
  Ensure the hook is on: `git config core.hooksPath tool/hooks`.
- Run `dart format lib test && flutter analyze && flutter test` before
  calling any task done. It is the only gate (no CI).
- Reference projects (listed in `CLAUDE.local.md` if present) are
  read-only. Copy patterns, never code.
- Home Assistant API facts come from developers.home-assistant.io, not
  memory. Re-read the REST/WebSocket pages before changing
  `lib/features/home_assistant/data/`.
- Never claim something was verified against a real Home Assistant or a
  physical device unless it was. Say what was run and where.
- All docs (`plan.md`, `TODO.md`, `CURRENT_STATUS.md`, `docs/`, decisions,
  guides, handoff) live under `tech_readme_files/` — see
  [tech_readme_files/INDEX.md](tech_readme_files/INDEX.md). Only `AGENTS.md`,
  `CLAUDE.md`, `README.md` and `CHANGELOG.md` stay at the root.
- Strings: edit `tool/gen_arb.py`, then `python3 tool/gen_arb.py && flutter gen-l10n`.
  Never hand-edit the ARB files.
- Git: `develop` integrates, `main` releases. Branch `<type>/<slug>` off
  `develop` (`feat/`, `fix/`, `chore/`, `docs/`, `test/`, `refactor/`),
  Conventional Commits, `git merge --no-ff` back into `develop`. Release =
  `git merge --no-ff develop` into `main` + annotated tag `vX.Y.Z`. Never
  commit straight to `main`, never force-push, never push unless asked.
