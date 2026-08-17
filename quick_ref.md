# Quick Reference

## Essential New Commands

### Zoxide (Smart Directory Navigation)
```bash
z project        # Jump to ~/code/my-project
z doc            # Jump to ~/Documents
zi               # Interactive picker
z -              # Previous directory
```

### uv (Python Package Manager)
```bash
uv venv                     # Create venv (fast!)
source .venv/bin/activate   # Activate venv
uv pip install pandas       # Install package
uv pip install -r requirements.txt
uv pip freeze > requirements.txt
```

### Ruff (Lint + Format)
```bash
ruff check .              # Check for issues
ruff check --fix .        # Auto-fix issues
ruff format .             # Format code (auto on save in nvim)
```

### Pre-commit
```bash
pre-commit install        # Setup hooks (once per repo)
pre-commit run --all-files   # Run manually
git commit                # Hooks run automatically
```

## Neovim Keybindings

### LSP
```
gd          - Go to definition
K           - Hover documentation
gr          - Find references
<leader>rn  - Rename symbol
<leader>ca  - Code actions
<leader>f   - Format (manual, auto on save)
<leader>e   - Show diagnostics
[d / ]d     - Navigate diagnostics
```

### Debugging
```
<leader>b   - Toggle breakpoint
<leader>dc  - Start/Continue debugging
<leader>di  - Step into
<leader>do  - Step over
<leader>dO  - Step out
<leader>dt  - Terminate debugger
<leader>dr  - Toggle REPL
```

### General
```
<Space>     - Leader key
<leader>p   - Toggle paste mode
```

## Python Project Setup (30 seconds)

```bash
mkdir my-project && cd my-project
uv venv && source .venv/bin/activate
cp ~/dotfiles/pyproject.toml .
cp ~/dotfiles/.pre-commit-config.yaml .
nvim pyproject.toml  # Edit name/description
pre-commit install
```

Done! Now you have:
- Virtual environment
- Auto-formatting on save
- Pre-commit hooks
- Type checking
- Linting

## Common Workflows

### Debugging Python Script
```bash
nvim script.py
# Set breakpoint: <leader>b
# Start debug: <leader>dc
# Step through: <leader>di / <leader>do
# Hover over variables to inspect
```

### Code Review Before Commit
```bash
ruff check .              # Check issues
ruff check --fix .        # Fix auto-fixable
git add .
git commit                # Pre-commit runs automatically
```

### Monitor System While Running Code
```bash
# In tmux
tmux
tmux split-window -h
# Left pane: run code
# Right pane: btop
```

## Aliases (from zshrc)

### Python
```bash
py          = python3
pip         = pip3
ca          = conda activate
cdv         = conda deactivate
```

### Navigation
```bash
..          = cd ..
...         = cd ../..
ls          = lsd (fancy ls)
la          = ls -a
```

### Git
```bash
gs          = git status
ga          = git add
gaa         = git add -A
gc          = git commit -m
gps         = git push
gpl         = git pull
gl          = git log --oneline --graph
```

### Tmux
```bash
t           = tmux
ta          = tmux attach
```

### Tools
```bash
v           = nvim
```

## File Locations

```
~/dotfiles/                 - Your dotfiles repo
~/.config/nvim/init.lua     - Neovim config
~/.zshrc                    - Shell config
~/.tmux.conf               - Tmux config
~/dotfiles/pyproject.toml   - Python project template
~/dotfiles/.pre-commit-config.yaml - Pre-commit template
```

## Cheat Sheet URL

Print this and keep it handy:
```
Neovim LSP:  https://github.com/neovim/nvim-lspconfig
DAP:         https://github.com/mfussenegger/nvim-dap
Ruff:        https://docs.astral.sh/ruff
Zoxide:      https://github.com/ajeetdsouza/zoxide
```

