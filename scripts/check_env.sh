#!/bin/bash

# Reports which dotfiles dependencies are already present on this machine.
# Does not install or download anything - safe to run without sudo or network access.

ok=0
missing=0

check_cmd() {
    local name="$1"
    local cmd="${2:-$1}"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[OK]      $name"
        ok=$((ok+1))
    else
        echo "[MISSING] $name"
        missing=$((missing+1))
    fi
}

check_path() {
    local name="$1"
    local path="$2"
    if [ -e "$path" ]; then
        echo "[OK]      $name"
        ok=$((ok+1))
    else
        echo "[MISSING] $name"
        missing=$((missing+1))
    fi
}

check_pip_pkg() {
    local name="$1"
    if python3 -m pip show "$name" >/dev/null 2>&1; then
        echo "[OK]      python package: $name"
        ok=$((ok+1))
    else
        echo "[MISSING] python package: $name"
        missing=$((missing+1))
    fi
}

echo "=== Shell ==="
check_cmd zsh
check_path "oh-my-zsh" "$HOME/.oh-my-zsh"
check_cmd starship
echo "  default shell: $SHELL"

echo ""
echo "=== Zsh plugins ==="
PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins"
for p in zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete zsh-history-substring-search zsh-completions; do
    check_path "$p" "$PLUGIN_DIR/$p"
done

echo ""
echo "=== Terminal / editor ==="
check_cmd tmux
check_cmd nvim

echo ""
echo "=== CLI tools ==="
check_cmd lsd
check_cmd xclip
check_cmd fzf
check_cmd direnv
check_cmd zoxide
check_cmd btop
check_cmd git
check_cmd gh

echo ""
echo "=== Python tooling ==="
check_cmd python3
check_cmd uv
check_cmd ruff
check_cmd pyright
check_cmd pre-commit
check_pip_pkg debugpy

echo ""
echo "=== Node ==="
check_cmd node
check_cmd npm

echo ""
echo "=== Fonts ==="
if fc-list 2>/dev/null | grep -qi "JetBrainsMono"; then
    echo "[OK]      JetBrainsMono Nerd Font"
    ok=$((ok+1))
else
    echo "[MISSING] JetBrainsMono Nerd Font"
    missing=$((missing+1))
fi

if ! grep -q microsoft /proc/version 2>/dev/null; then
    echo ""
    echo "=== Native Linux only ==="
    check_cmd alacritty
    check_cmd nvtop
    check_cmd timeshift
fi

echo ""
echo "=== Privileges (informational, not counted below) ==="
if id -nG "$USER" 2>/dev/null | grep -qw sudo; then
    echo "  in 'sudo' group (may still require a password / may be blocked by policy)"
else
    echo "  not in 'sudo' group"
fi

echo ""
echo "-----------------------------"
echo "Present: $ok   Missing: $missing"
