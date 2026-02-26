# GitHub Copilot Instructions — IPCRAE v3.3

## Project Overview

IPCRAE (**I**nbox · **P**rojets · **C**asquettes · **R**essources · **A**rchives) is a complete life management system piloted by AI, 100% local, versionable and CLI-friendly.
It is a set of Bash shell scripts, Markdown files, and templates that implement the IPCRAE methodology.

## Key Documentation

Read these files to understand the project before making changes:
1. `README.md` — Full methodology documentation
2. `docs/conception/00_VISION.md` — Vision and goals
3. `docs/conception/01_AI_RULES.md` — AI rules for this project
4. `docs/conception/02_ARCHITECTURE.md` — Architecture
5. `docs/conception/08_COMMANDS_REFERENCE.md` — Command reference
6. `docs/workflows.md` — Operational workflows

## Repository Structure

```
IPCRAE/
├── .github/                 # GitHub configuration (Copilot instructions, workflows)
├── docs/conception/         # Design documentation (source of truth for architecture)
├── scripts/                 # Shell scripts (CLI tools: ipcrae, ipcrae-install.sh, etc.)
├── templates/               # Brain seed templates copied during installation
├── tests/                   # Bats and shell tests
├── ipcrae-install.sh        # Main installer script
├── README.md                # Full documentation of the IPCRAE method
├── CLAUDE.md                # Instructions for Claude Code CLI
├── AGENTS.md                # Instructions for Codex CLI (OpenAI)
├── GEMINI.md                # Instructions for Gemini CLI
└── .ai-instructions.md      # Project-specific AI context routing rules
```

## Language and Stack

- **Primary language**: Bash shell scripts
- **Documentation**: Markdown
- **Tests**: [bats-core](https://github.com/bats-core/bats-core) (`.bats` files) + plain shell test scripts
- **No external runtime dependencies** beyond standard Unix tools (`bash`, `git`, `python3`, `rg` optional)

## Coding Conventions

- All scripts must pass `bash -n <script>` (syntax check) and ideally `shellcheck <script>`
- Use `set -euo pipefail` at the top of scripts (already enforced in most scripts)
- Function names: lowercase with underscores (e.g., `write_safe`, `require_cmd`); CLI script names use hyphens (e.g., `ipcrae-install.sh`, `ipcrae-sync`)
- Variables: UPPERCASE for exported/global vars, lowercase for local vars
- Prefer `local` for variables inside functions
- Use `write_safe` helper for file writes (safe mode, two calling conventions supported)
- Heredoc style: `<<'EOF'` (single-quoted to prevent variable expansion unless needed)

## Commit Message Format

Follow the Conventional Commits convention (see `docs/conception/06_COMMIT_INSTRUCTIONS.md`):
```
<type>(<scope>): <subject>
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`

## Testing

Run existing tests before and after changes:
```bash
# Syntax check
bash -n ipcrae-install.sh

# Shell tests
bash tests/test_launcher_syntax.sh
bash tests/test_launcher_search_smoke.sh

# Bats tests (if bats is installed)
bats tests/test_write_safe.bats

# Full isolated smoke test
TMP_HOME=$(mktemp -d)
TMP_VAULT="$(mktemp -d)/vault"
HOME="$TMP_HOME" bash ipcrae-install.sh -y "$TMP_VAULT"
[ -f "$TMP_VAULT/.ipcrae/context.md" ]
[ -f "$TMP_VAULT/.ipcrae/config.yaml" ]
```

## Documentation Rule

**Any modification to scripts, commands, or workflows MUST be reflected in `docs/`** (specifically `docs/workflows.md` and `docs/conception/08_COMMANDS_REFERENCE.md`) before the task is considered done.

## Memory Rules

- Changes reusable across projects → document in `memory/<domain>.md`
- Changes specific to this repo → document in `.ipcrae-project/memory/`
- Volatile notes (todo/debug) → use `.ipcrae-project/local-notes/`
