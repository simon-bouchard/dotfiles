# IT install request (work machine)

Everything I need installed that I can't get myself without sudo/curl access.
(zsh, xclip, python3, and git are already on this machine.)

## Standard apt packages (no special repo needed)
- tmux
- fzf
- direnv
- btop

## Needs a third-party repo added first (`add-apt-repository`)
- neovim (`ppa:neovim-ppa/unstable`)

## Native-Ubuntu extras
- nvtop (apt) - TUI (terminal-based, not a GUI) GPU monitor, same idea as btop but for the GPU
- caps-lock -> escape remap (user-level `gsettings`, no install needed, but check it isn't locked down by policy)

## Curl-piped installers (write to $HOME, no root, but fetched via curl)
- oh-my-zsh
- starship
- uv
- zoxide
- Node.js (nodesource setup script, then apt install nodejs - also needs root for the apt step)

## git clone from GitHub (oh-my-zsh plugins, no root, needs GitHub reachability)
- zsh-autosuggestions
- zsh-syntax-highlighting
- fast-syntax-highlighting
- zsh-autocomplete
- fzf-tab
- zsh-history-substring-search
- zsh-completions

## pip installs (needs PyPI reachability)
- ruff
- pyright

## Shell change
- `chsh -s $(which zsh)` - needs zsh already listed in /etc/shells; may or may not need root
  depending on whether zsh is already registered there

## Worth asking IT/security about
- Internal package mirror or approved software catalog that might already cover uv/starship/zoxide
- Whether I'm allowed to just execute a static binary someone hands me in my home directory
  (no install, no root) - much lighter ask than "please install this"
