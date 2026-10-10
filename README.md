# Dotfiles

Terminal-focused development environment for Ubuntu/Debian with Python, Zsh, and Neovim.

## Quick Start

```bash
# Clone repo
git clone https://github.com/simon-bouchard/dotfiles ~/dotfiles
cd ~/dotfiles

# First time setup (installs tools)
chmod +x setup.sh
./setup.sh

# Load dotfiles (safe to re-run)
chmod +x symlink.sh
./symlink.sh

# Restart shell
source ~/.zshrc
```

## What's Included

**Shell**: Zsh (vi mode) + Oh-My-Zsh + zsh-autocomplete + Starship prompt + Zoxide (smart cd) +
Atuin (searchable history)
**Terminal**: Tmux with sensible defaults
**Editor**: Neovim with LSP, debugging, format-on-save, Telescope, oil.nvim, which-key, Treesitter
**Python**: Ruff (linting/formatting, import sorting), Pyright (LSP), uv (package manager), pre-commit
**Tools**: lsd, btop, glow (markdown viewer), fzf, xclip utilities

## Machine-specific Config

Tracked files are shared by every machine. Per-machine settings live in untracked files that
`symlink.sh` creates once from `templates/`:

| File | For |
|---|---|
| `~/.zshrc.local` | Extra PATH entries, secrets, terminal workarounds, `STARSHIP_CONFIG=~/.config/starship-ascii.toml` without a Nerd Font |
| `~/.config/nvim/local.lua` | `nerd_font = false` for plain icons, `lsp_servers` to limit installed LSPs |
| `~/.gitconfig.local` | Git identity, credential helpers |
| `~/.claude/CLAUDE.local.md` | Machine context for Claude Code (OS, terminal, work tools) |

Neovim version differences are detected automatically: 0.10 vs 0.11+ (LSP API, Telescope and
gitsigns versions) and 0.12+ (nvim-treesitter `main` branch, which builds parsers with the
`tree-sitter` CLI installed by `setup.sh`; older versions use the frozen `master` branch).

## Key Bindings

### Tmux
- Prefix: `Ctrl+a` (not Ctrl+b); press it twice to send `Ctrl+a` to the shell
- Split: `|` horizontal, `-` vertical
- Panes: `Alt+arrows`
- Reload: `prefix + r`

### Shell prompt (vi mode)
- `Up`: Atuin history list, exact text (type part of a command first to filter)
- `Ctrl+r`: Atuin history list, fuzzy. In either list: `Enter` runs, `Tab` edits, `Ctrl+s` switches
  matching mode
- `Down`: completion menu (zsh-autocomplete)
- `Tab`: accept the grey autosuggestion if shown, otherwise complete
- `Ctrl+a` / `Ctrl+e`: start / end of line (insert mode)

### Neovim
- Leader: `Space`. Pause after a key like `<leader>` or `g` and which-key lists what can follow
- Files: `-` opens the current file's directory in oil (edit names and `:w` to create, rename,
  move or delete files; `g?` for help)
- Find (Telescope): `<leader>ff` files, `<leader>fg` grep, `<leader>fw` word under cursor,
  `<leader>f/` in current file, `<leader>fb` buffers, `<leader>fr` recent, `<leader>fd` diagnostics,
  `<leader>fk` keymaps, `<leader>f.` reopen last search. `Ctrl+s` opens a result in a split
- Symbols: `<leader>fs` / `<leader>fS` classes and functions in file / project,
  `<leader>fa` / `<leader>fA` all symbols
- LSP: `gd` (definition), `gr` (references, in Telescope), `K` (hover), `<leader>rn` (rename),
  `<leader>lf` (format; also runs on save)
- Diagnostics: `[d` / `]d` (navigate), `<leader>e` (open)
- Completion: `Tab` / `Shift+Tab` to move or jump through snippet fields, `Enter` to accept,
  `Ctrl+e` to close
- Scrolling: `Ctrl+d` / `Ctrl+u` half page, cursor kept centered
- Debug: `<leader>b` (breakpoint), `<leader>dc` (continue), `<leader>di` (step in), `<leader>do` (step over)
- Practice: `:VimBeGood`

### Zoxide
- `z <directory>` - Jump to frequently used directory
- `zi` - Interactive directory picker

## Python Workflow

### Setup New Project
```bash
# Create project directory
mkdir my-project && cd my-project

# Create virtual environment with uv
uv venv
source .venv/bin/activate

# Install dependencies
uv pip install numpy pandas

# Copy template files
cp ~/dotfiles/templates/pyproject.toml .
cp ~/dotfiles/templates/.pre-commit-config.yaml .

# Setup pre-commit hooks
pre-commit install

# Edit pyproject.toml with your project details
nvim pyproject.toml
```

### Daily Workflow
- Files auto-format on save (via Ruff)
- Linting shows inline (via Ruff)
- Type checking via Pyright LSP
- Pre-commit runs checks before commits
- Debug with `<leader>b` to set breakpoints

### Manual Commands
```bash
# Format code manually
ruff format .

# Check linting
ruff check .

# Fix auto-fixable issues
ruff check --fix .

# Type checking
pyright
```

## Files

- `config/zshrc` - Shell config with aliases, zoxide, uv, Atuin and key bindings
- `config/atuin.toml` - Atuin history search settings
- `config/tmux.conf` - Tmux configuration
- `config/init.lua` - Neovim setup (LSP, DAP, format-on-save, Telescope, oil, Treesitter)
- `config/starship.toml` - Prompt styling
- `config/ruff.toml` - Global Ruff config (via `RUFF_CONFIG`)
- `git/gitconfig` - Git aliases and settings (identity goes in `~/.gitconfig.local`)
- `claude/` - Global Claude Code instructions and commands
- `templates/pyproject.toml` - Python project template
- `templates/.pre-commit-config.yaml` - Git hooks template

## LSP Servers (Auto-installed via Mason)

- Pyright (Python - type checking)
- lua_ls (Lua)
- ts_ls (TypeScript/JavaScript)
- bashls (Bash)
- clangd (C/C++)
- html, cssls (Web)
- jsonls, yamlls (Config files)

## Debugging Python

1. Open Python file in Neovim
2. Set breakpoint: `<leader>b`
3. Run debugger: `<leader>dc`
4. Step through: `<leader>di` (into), `<leader>do` (over)
5. Inspect variables: hover over them with cursor
6. Continue: `<leader>dc`
7. Stop: `<leader>dt`

## Tools Reference

### uv (Python Package Manager)
```bash
uv venv                    # Create virtual environment
uv pip install <package>   # Install package
uv pip list                # List installed packages
uv pip freeze              # Export requirements
```

### Ruff (Linter + Formatter)
```bash
ruff check .               # Lint current directory
ruff check --fix .         # Fix auto-fixable issues
ruff format .              # Format code
```

### Pre-commit
```bash
pre-commit install         # Install hooks (run once per repo)
pre-commit run --all-files # Run manually on all files
```

### Zoxide
```bash
z <partial-name>           # Jump to directory
zi                         # Interactive picker
z -                        # Go back to previous directory
```

## System Monitor

Run `btop` in a tmux pane to monitor CPU, memory, disk, network while coding.

## Notes

- Run `setup.sh` once per machine (idempotent)
- Run `symlink.sh` after updating dotfiles
- Neovim packages and Treesitter parsers auto-install on first launch
- Python files format and sort imports automatically on save
- Atuin imports `~/.zsh_history` once at install; history stays local (no sync account)
- Pre-commit runs before each git commit
- Use `uv` instead of `pip` for faster installs

