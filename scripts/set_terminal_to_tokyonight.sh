#!/usr/bin/env bash
# Fix + reapply: the first version of this script double-prefixed a colon
# onto every path (e.g. "...profiles:/:default" instead of
# "...profiles:/default"), so GNOME Terminal never saw the new profile.
# This resets the bad entries, then writes to the correct paths.
set -euo pipefail

BASE="/org/gnome/terminal/legacy/profiles:/"

# --- Clean up whatever the buggy run left behind ---
# Reset the malformed ":default" / ":list" keys and any ":<uuid>/" dir,
# ignoring errors if they don't exist.
dconf reset "${BASE}:default" 2>/dev/null || true
dconf reset "${BASE}:list" 2>/dev/null || true
for path in $(dconf list "$BASE" 2>/dev/null || true); do
    if [[ "$path" == :*  ]]; then
        dconf reset -f "${BASE}${path}" 2>/dev/null || true
    fi
done

# --- Reuse the profile that was actually created (has real config on it) ---
# Its true UUID is whatever came after the stray colon in the old listing.
OLD_UUID="c5b0ffcf-393b-4608-9920-23b1386ff526"
NEW_UUID="$OLD_UUID"   # reuse it, no need to generate a new one

PROFILE_PATH="${BASE}${NEW_UUID}/"

dconf write "${PROFILE_PATH}visible-name" "'Tokyo Night'"
dconf write "${PROFILE_PATH}use-theme-colors" "false"
dconf write "${PROFILE_PATH}background-color" "'#1a1b26'"
dconf write "${PROFILE_PATH}foreground-color" "'#c0caf5'"
dconf write "${PROFILE_PATH}bold-color-same-as-fg" "true"
dconf write "${PROFILE_PATH}cursor-colors-set" "true"
dconf write "${PROFILE_PATH}cursor-background-color" "'#c0caf5'"
dconf write "${PROFILE_PATH}cursor-foreground-color" "'#1a1b26'"
dconf write "${PROFILE_PATH}palette" "['#15161e', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#a9b1d6', '#414868', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#c0caf5']"
dconf write "${PROFILE_PATH}audible-bell" "false"
dconf write "${PROFILE_PATH}scrollback-unlimited" "true"

# Correct paths this time — no extra colon
dconf write "${BASE}list" "['${NEW_UUID}']"
dconf write "${BASE}default" "'${NEW_UUID}'"

echo "Fixed. Verify with:"
echo "  dconf read '${BASE}default'"
echo "Then open a brand new terminal window (not just a new tab) to see it."
