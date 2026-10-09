#!/bin/bash
# Keep each tmux session's original creation date across tmux-resurrect restores.
# "save" runs from @resurrect-hook-post-save-all, "restore" from @resurrect-hook-post-restore-all.
# Restored sessions get @created_at, which the list-sessions alias in tmux.conf displays.

set -euo pipefail

store="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/session_created"

save() {
	mkdir -p "$(dirname "$store")"
	tmux list-sessions -F "#{session_name}"$'\t'"#{?@created_epoch,#{@created_epoch},#{session_created}}" \
		>"$store.tmp"
	mv "$store.tmp" "$store"
}

restore() {
	[[ -f $store ]] || return 0
	local name epoch
	while IFS=$'\t' read -r name epoch; do
		tmux has-session -t "=$name" 2>/dev/null || continue
		tmux set-option -t "$name" @created_epoch "$epoch"
		tmux set-option -t "$name" @created_at "$(date -d "@$epoch" '+%a %b %e %H:%M:%S %Y')"
	done <"$store"
}

case "${1:-}" in
save) save ;;
restore) restore ;;
*)
	echo "usage: $(basename "$0") save|restore" >&2
	exit 1
	;;
esac
