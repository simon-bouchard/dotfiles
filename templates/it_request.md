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
- nvtop (apt)

## Curl-piped installers (write to $HOME, no root, but fetched via curl)
- starship
- uv
- zoxide

## Not an IT ask - self-serviceable if `git clone` reaches GitHub (same path as cloning this repo)
- oh-my-zsh: `git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh`
  (skip the curl installer - it just does this clone plus copies a template .zshrc we don't need,
  since our zshrc already points ZSH at this path and sources it directly)
- zsh-autosuggestions
- fast-syntax-highlighting
- zsh-autocomplete
- zsh-history-substring-search
- zsh-completions

## pip installs (needs PyPI reachability)
- ruff
- pyright

## Shell change
- `chsh -s $(which zsh)` - needs zsh already listed in /etc/shells; may or may not need root
  depending on whether zsh is already registered there
