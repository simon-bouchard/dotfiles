#!/bin/bash
# Track which tmux sessions are open in a terminal tab so trestore can reopen them after a crash.
# Called from tmux.conf hooks (record, mark) and zshrc (snapshot, reopen).

set -euo pipefail

dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux"
current="$dir/attached_sessions"
previous="$current.prev"
lock="$current.lock"

# Serialise writers: trestore attaches many tabs at once, each firing record
lock() {
	mkdir -p "$dir"
	exec 9>"$lock"
	flock 9
}

# Session names of a list file. Lines are "client_pid<TAB>session"; cut keeps tab-less old lines.
sessions() {
	cut -f2 "$1" | sort -u
}

# When every recorded client is gone the window was closed or tmux died: keep that list for trestore
rotate_if_gone() {
	[[ -s $current ]] || return 0
	local pid
	while IFS=$'\t' read -r pid _; do
		[[ $pid =~ ^[0-9]+$ && -r /proc/$pid/comm && $(</proc/"$pid"/comm) == tmux* ]] && return 0
	done <"$current"
	cp "$current" "$previous"
}

record() {
	local detaching="${1:-}" tmp
	lock
	rotate_if_gone
	tmp=$(mktemp "$current.XXXXXX")
	tmux list-clients -F "#{client_name}"$'\t'"#{client_pid}"$'\t'"#{client_session}" |
		awk -F'\t' -v skip="$detaching" 'BEGIN { OFS = "\t" } $1 != skip { print $2, $3 }' |
		sort -u >"$tmp"
	if [[ -s $tmp ]]; then
		mv "$tmp" "$current"
	else
		rm -f "$tmp"
	fi
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
		tmux set-option -t "=$name:" @was_open 1
	done < <(sessions "$previous")
}

reopen() {
	lock
	rotate_if_gone
	if [[ ! -s $previous ]]; then
		echo "No sessions recorded from a closed terminal window" >&2
		return 1
	fi
	local name quoted args=()
	while IFS= read -r name; do
		if ! tmux has-session -t "=$name" 2>/dev/null; then
			echo "Skipped $name: session does not exist" >&2
		elif (($(tmux display-message -p -t "=$name:" "#{session_attached}") > 0)); then
			echo "Skipped $name: already attached" >&2
		else
			quoted=${name//\'/\'\\\'\'}
			args+=(--tab -e "zsh -ic 'tmux attach-session -t \"=\$1\"' _ '$quoted'")
		fi
	done < <(sessions "$previous")
	((${#args[@]})) || return 0
	# Pane env holds the GNOME_TERMINAL_* of the tab that started the server, often gone.
	# The attached client's env names the window trestore runs in, so the tabs land there.
	local screen=${GNOME_TERMINAL_SCREEN:-} service=${GNOME_TERMINAL_SERVICE:-} environ
	if [[ -n ${TMUX:-} ]]; then
		environ="/proc/$(tmux display-message -p '#{client_pid}')/environ"
		screen=$(tr '\0' '\n' <"$environ" | sed -n 's/^GNOME_TERMINAL_SCREEN=//p')
		service=$(tr '\0' '\n' <"$environ" | sed -n 's/^GNOME_TERMINAL_SERVICE=//p')
	fi
	local target=(-u GNOME_TERMINAL_SCREEN -u GNOME_TERMINAL_SERVICE)
	if [[ -n $screen && -n $service ]]; then
		target=(GNOME_TERMINAL_SCREEN="$screen" GNOME_TERMINAL_SERVICE="$service")
	else
		args[0]=--window
	fi
	# zsh -i applies the colours in .zshrc.local before attaching
	env -u TMUX -u TMUX_PANE "${target[@]}" gnome-terminal "${args[@]}"
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
