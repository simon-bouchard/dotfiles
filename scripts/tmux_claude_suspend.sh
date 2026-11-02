#!/bin/bash
# Stop idle Claude Code panes in tmux sessions detached for 5 minutes, keeping the conversation id
# on the pane, and resume them on attach. Called from tmux.conf status-right, hooks and resurrect.

set -euo pipefail

grace=300
dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux"
store="$dir/claude_panes"
tab=$'\t'

# Print "claude" or "claudea" (zshrc), depending on whether the Artifact tool was denied.
launcher() {
	if grep -qxzF -- --settings "/proc/$1/cmdline"; then echo claude; else echo claudea; fi
}

# Print pane id, resurrect target, pid, status, session id and launcher of each Claude pane,
# optionally only for the newline-separated session names in $1.
claude_panes() {
	local filter="${1:-}" pane target ppid cmd session pid info
	tmux list-panes -a -F "#{pane_id}$tab#{session_name}:#{window_index}.#{pane_index}$tab#{pane_pid}$tab#{pane_current_command}$tab#{session_name}" |
		while IFS=$tab read -r pane target ppid cmd session; do
			[[ $cmd == claude ]] || continue
			[[ -z $filter ]] || grep -qxF -- "$session" <<<"$filter" || continue
			pid=$(pgrep -P "$ppid" -x claude | head -n1) || continue
			[[ -n $pid ]] || continue
			info=$(jq -r '[.status, .sessionId] | @tsv' "$HOME/.claude/sessions/$pid.json" 2>/dev/null) ||
				continue
			printf '%s\t%s\t%s\t%s\t%s\n' "$pane" "$target" "$pid" "$info" "$(launcher "$pid")"
		done
}

suspend_sessions() {
	local pane target pid status id cmd
	claude_panes "$1" | while IFS=$tab read -r pane target pid status id cmd; do
		[[ $status == idle ]] || continue
		tmux set-option -p -t "$pane" @claude_session "$id"
		tmux set-option -p -t "$pane" @claude_cmd "$cmd"
		kill -TERM "$pid"
	done
}

# Relaunch suspended Claude panes of attached sessions that are back at a shell prompt.
resume() {
	local attached pane session current in_mode cmd id
	attached=$(tmux list-clients -F "#{client_session}" | sort -u)
	[[ -n $attached ]] || return 0
	tmux list-panes -a -F "#{pane_id}$tab#{session_name}$tab#{pane_current_command}$tab#{pane_in_mode}$tab#{@claude_cmd}$tab#{@claude_session}" |
		while IFS=$tab read -r pane session current in_mode cmd id; do
			[[ -n $id && $current == zsh && $in_mode == 0 ]] || continue
			grep -qxF -- "$session" <<<"$attached" || continue
			tmux set-option -pu -t "$pane" @claude_session
			tmux set-option -pu -t "$pane" @claude_cmd
			tmux send-keys -t "$pane" "${cmd:-claude} --resume $id" Enter
		done
}

sweep() {
	local now name attached since expired=""
	now=$(date +%s)
	while IFS=$tab read -r name attached since; do
		if ((attached > 0)); then
			[[ -z $since ]] || tmux set-option -u -t "=$name:" @detached_since
		elif [[ -z $since ]]; then
			tmux set-option -t "=$name:" @detached_since "$now"
		elif ((now - since >= grace)); then
			expired+="$name"$'\n'
		fi
	done < <(tmux list-sessions -F "#{session_name}$tab#{session_attached}$tab#{@detached_since}")
	[[ -z $expired ]] || suspend_sessions "$expired"
	resume
}

# Record running and suspended Claude panes so restore can reattach their conversations.
save() {
	local tmp pane target pid status id cmd
	tmp=$(mktemp "$store.XXXXXX")
	{
		claude_panes | while IFS=$tab read -r pane target pid status id cmd; do
			printf '%s\t%s\t%s\n' "$target" "$cmd" "$id"
		done
		tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}$tab#{@claude_cmd}$tab#{@claude_session}" |
			awk -F'\t' '$3 != ""'
	} >"$tmp"
	mv "$tmp" "$store"
}

restore() {
	[[ -f $store ]] || return 0
	local target cmd id
	while IFS=$tab read -r target cmd id; do
		tmux set-option -p -t "=$target" @claude_session "$id" 2>/dev/null || continue
		tmux set-option -p -t "=$target" @claude_cmd "$cmd"
	done <"$store"
	resume
}

mkdir -p "$dir"
exec 9>"$dir/claude_suspend.lock"
case "${1:-}" in
sweep) flock -n 9 || exit 0; sweep ;;
resume) flock -w 30 9; resume ;;
save) flock -w 30 9; save ;;
restore) flock -w 30 9; restore ;;
*)
	echo "usage: $(basename "$0") sweep|resume|save|restore" >&2
	exit 1
	;;
esac
