#!/bin/bash
# Track which tmux sessions are open in a terminal tab so trestore can reopen them after a crash.
# Called from tmux.conf hooks (record, mark) and zshrc (snapshot, reopen).

set -euo pipefail

dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux"
current="$dir/attached_sessions"
previous="$current.prev"

record() {
	local detaching="${1:-}"
	mkdir -p "$dir"
	tmux list-clients -F "#{client_name}"$'\t'"#{client_session}" |
		awk -F'\t' -v skip="$detaching" '$1 != skip { print $2 }' |
		sort -u >"$current.tmp"
	mv "$current.tmp" "$current"
}

snapshot() {
	[[ -s $current ]] || return 0
	cp "$current" "$previous"
}

mark() {
	[[ -f $previous ]] || return 0
	local name
	while IFS= read -r name; do
		tmux has-session -t "=$name" 2>/dev/null || continue
		tmux set-option -t "=$name" @was_open 1
	done <"$previous"
}

reopen() {
	if [[ ! -s $previous ]]; then
		echo "No sessions recorded from before the last tmux start" >&2
		return 1
	fi
	local name
	while IFS= read -r name; do
		if ! tmux has-session -t "=$name" 2>/dev/null; then
			echo "Skipped $name: session does not exist" >&2
		elif (($(tmux display-message -p -t "=$name" "#{session_attached}") > 0)); then
			echo "Skipped $name: already attached" >&2
		else
			gnome-terminal --tab -- tmux attach-session -t "=$name"
		fi
	done <"$previous"
}

case "${1:-}" in
record) record "${2:-}" ;;
snapshot) snapshot ;;
mark) mark ;;
reopen) reopen ;;
*)
	echo "usage: $(basename "$0") record [detaching-client]|snapshot|mark|reopen" >&2
	exit 1
	;;
esac
