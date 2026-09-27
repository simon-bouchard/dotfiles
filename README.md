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

**Shell**: Zsh + Oh-My-Zsh + Starship prompt + Zoxide (smart cd)
**Terminal**: Tmux with sensible defaults
**Editor**: Neovim with LSP, debugging, format-on-save
**Python**: Ruff (linting/formatting), Pyright (LSP), uv (package manager), pre-commit
**Tools**: lsd, btop, glow (markdown viewer), xclip utilities

## Machine-specific Config

Tracked files are shared by every machine. Per-machine settings live in untracked files that
`symlink.sh` creates once from `templates/`:

| File | For |
|---|---|
| `~/.zshrc.local` | Extra PATH entries, secrets, terminal workarounds, `STARSHIP_CONFIG=~/.config/starship-ascii.toml` without a Nerd Font |
| `~/.config/nvim/local.lua` | `nerd_font = false` for plain icons, `lsp_servers` to limit installed LSPs |
| `~/.gitconfig.local` | Git identity, credential helpers |
| `~/.claude/CLAUDE.local.md` | Machine context for Claude Code (OS, terminal, work tools) |

Neovim 0.10 vs 0.11+ differences (LSP API, telescope version) are detected automatically.

## Key Bindings

### Tmux
- Prefix: `Ctrl+a` (not Ctrl+b)
- Split: `|` horizontal, `-` vertical
- Panes: `Alt+arrows`
- Reload: `prefix + r`

### Neovim
- Leader: `Space`
- LSP: `gd` (definition), `K` (hover), `gr` (references)
- Format: `<leader>f` (manual format, auto-formats on save)
- Diagnostics: `[d` / `]d` (navigate), `<leader>e` (open)
- Debug: `<leader>b` (breakpoint), `<leader>dc` (continue), `<leader>di` (step in), `<leader>do` (step over)

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

- `config/zshrc` - Shell config with aliases, zoxide, uv
- `config/tmux.conf` - Tmux configuration
- `config/init.lua` - Neovim setup (LSP, DAP, format-on-save)
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
- Neovim packages auto-install on first launch
- Python files format automatically on save
- Pre-commit runs before each git commit
- Use `uv` instead of `pip` for faster installs

