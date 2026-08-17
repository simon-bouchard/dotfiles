# IT install request (work machine)

Draft list of everything `setup.sh` normally installs, for a machine where I don't have
sudo/curl access. Run `scripts/check_env.sh` first and cross out anything it reports `[OK]`
before sending this along.

## Standard apt packages (no special repo needed)
- zsh
- tmux
- meld
- xclip
- fzf
- direnv
- btop
- python3, python3-pip, python3-venv

## Needs a third-party repo added first (`add-apt-repository`)
- neovim (`ppa:neovim-ppa/unstable`)
- alacritty (`ppa:aslatter/ppa`)

## snap install
- lsd

## Native-Ubuntu extras
- nvtop (apt)
- timeshift (apt)
- caps-lock -> escape remap (user-level `gsettings`, no install needed, but check it isn't locked down by policy)

## Curl-piped installers (write to $HOME, no root, but fetched via curl)
- oh-my-zsh
- starship
- uv
- zoxide
- JetBrainsMono Nerd Font (GitHub release zip)
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
- pre-commit
- debugpy
- pyperclip

## Shell change
- `chsh -s $(which zsh)` - needs zsh already listed in /etc/shells; may or may not need root
  depending on whether zsh is already registered there

## Worth asking IT/security about
- Internal package mirror or approved software catalog that might already cover uv/starship/zoxide
- Whether I'm allowed to just execute a static binary someone hands me in my home directory
  (no install, no root) - much lighter ask than "please install this"
