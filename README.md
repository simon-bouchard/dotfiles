# Dotfiles

Terminal-focused development environment for Ubuntu/Debian with Python, Zsh, and Neovim.

## Quick Start

```bash
# Clone repo
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# First time setup (installs tools)
chmod +x machine_init.sh
./machine_init.sh

# Load dotfiles (safe to re-run)
chmod +x load_dotfiles.sh
./load_dotfiles.sh

# Restart shell or source
source ~/.zshrc
```

## What's Included

**Shell**: Zsh + Oh-My-Zsh + Starship prompt
**Terminal**: Tmux with sensible defaults
**Editor**: Neovim with LSP (Python, JS/TS, HTML/CSS, Bash, JSON, YAML)
**Tools**: lsd (fancy ls), meld (visual diff), pyperclip utilities

## Key Bindings

### Tmux
- Prefix: `Ctrl+a` (not Ctrl+b)
- Split: `|` horizontal, `-` vertical
- Panes: `Alt+arrows`
- Reload: `prefix + r`

### Neovim
- Leader: `Space`
- LSP: `gd` (definition), `K` (hover), `gr` (references)
- Format: `<leader>f`
- Diagnostics: `[d` / `]d` (navigate), `<leader>e` (open)

## Files

- `zshrc` - Shell config with aliases
- `tmux.conf` - Tmux configuration
- `init.lua` - Neovim setup (lazy.nvim)
- `gitconfig` - Git aliases and settings
- `starship.toml` - Prompt styling

## Utilities

**tree.py** - Copy project structure to clipboard
**extract_kaggle_code.py** - Extract code from Kaggle notebooks
**extract_kaggle_cells.py** - Extract all cells from notebooks

## Notes

- Run `machine_init.sh` once per machine (idempotent, safe to re-run)
- Run `load_dotfiles.sh` after updating dotfiles
- Terminal font: JetBrainsMono Nerd Font (auto-installed)
- Neovim packages auto-install on first launch via `:Mason`
