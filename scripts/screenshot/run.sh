#!/usr/bin/env bash
# Regenerate assets/screenshot.png: real nvim in a detached tmux pane, captured
# with its colors, rendered to HTML, shot by headless Chrome.
# Needs: nvim, tmux, python3, Google Chrome (or CHROME=/path/to/chrome), tree-sitter
# parsers for TypeScript and Rust. Run from anywhere.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
out="$repo/assets/screenshot.png"
chrome=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
cols=160 rows=36 scale=2
shot_rows=$(( rows - 1 )) # the last row is the empty command line
font_px=14 row_px=20 pad_px=28

work=$(mktemp -d)
sock="oz-theme-shot-$$"
trap 'tmux -L "$sock" kill-server 2>/dev/null || true; rm -rf "$work"' EXIT

printf '%s\n' 'set -g default-terminal tmux-256color' 'set -g status off' >"$work/tmux.conf"
tmux -L "$sock" -f "$work/tmux.conf" new-session -d -x "$cols" -y "$rows" \
  -e "OZ_THEME_REPO=$repo" -e "OZ_THEME_READY=$work/ready" -e COLORTERM=truecolor \
  "nvim --clean -u '$here/init.lua'"

for _ in $(seq 100); do [ -s "$work/ready" ] && break; sleep 0.1; done
[ -s "$work/ready" ] || { echo "nvim never signalled ready" >&2; exit 1; }

tmux -L "$sock" capture-pane -e -p >"$work/screen.ansi"
read -r fg bg <"$work/ready"
python3 -I "$here/ansi2html.py" "$work/screen.ansi" "$fg" "$bg" "$cols" "$shot_rows" >"$work/page.html"

width=$(( cols * font_px * 6 / 10 + 2 * pad_px ))
height=$(( shot_rows * row_px + 2 * pad_px ))
mkdir -p "$repo/assets"
"$chrome" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor="$scale" \
  --window-size="$width,$height" --screenshot="$out" "file://$work/page.html" >/dev/null 2>&1
echo "wrote $out (${width}x${height} @${scale}x)"
