#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${TMUX_KEY_PALETTE_INSTALL_DIR:-$HOME/.local/bin}"
INSTALL_PATH="$INSTALL_DIR/tmux-key-palette"
TMUX_CONF="${TMUX_KEY_PALETTE_TMUX_CONF:-$HOME/.tmux.conf}"
BIND_KEY="${TMUX_KEY_PALETTE_BIND_KEY:-K}"
POPUP_WIDTH="${TMUX_KEY_PALETTE_POPUP_WIDTH:-80}"
POPUP_HEIGHT="${TMUX_KEY_PALETTE_POPUP_HEIGHT:-60%}"
MARKER_BEGIN="# >>> tmux-key-palette >>>"
MARKER_END="# <<< tmux-key-palette <<<"
BINDING_STATUS="skipped"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "tmux-key-palette: missing required command: $1" >&2
    exit 1
  fi
}

install_palette() {
  mkdir -p "$INSTALL_DIR"

  cat > "$INSTALL_PATH" <<'TMUX_KEY_PALETTE_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

selected="$(
  awk '
    FNR == NR {
      if (NF > 1) {
        key = $1
        $1 = ""
        sub(/^ +/, "")
        notes[key] = $0
      }
      next
    }

    /^bind-key/ {
      repeat = ""
      i = 2
      if ($i == "-r") {
        repeat = "*"
        i++
      }
      if ($i == "-T") {
        key = $(i + 2)
        command_start = i + 3
      } else {
        key = $i
        command_start = i + 1
      }

      command = ""
      for (j = command_start; j <= NF; j++) {
        command = command (j == command_start ? "" : " ") $j
      }

      display_key = key
      lookup_key = key
      sub(/^\\/, "", display_key)
      sub(/^\\/, "", lookup_key)

      description = notes[lookup_key]
      if (description == "") {
        description = command
        sub(/ .*/, "", description)
        gsub(/-/, " ", description)
        description = toupper(substr(description, 1, 1)) substr(description, 2)
      }

      printf "%-10s\t%-50s\t%s\n", repeat display_key, description, command
    }
  ' <(tmux list-keys -T prefix -N) <(tmux list-keys -T prefix) |
    sort -f -t $'\t' -k2,2 |
    fzf \
      --prompt='tmux key> ' \
      --header=$'Key       \tDescription\nPrefix key bindings. Enter runs the selected command.' \
      --delimiter='\t' \
      --with-nth=1,2 \
      --no-hscroll \
      --preview='printf "%s\n" {3..}' \
      --preview-window='down:3:wrap'
)"

[[ -z "$selected" ]] && exit 0

command="${selected#*$'\t'}"
command="${command#*$'\t'}"
tmux "$command"
TMUX_KEY_PALETTE_SCRIPT

  chmod +x "$INSTALL_PATH"
}

patch_tmux_conf() {
  mkdir -p "$(dirname "$TMUX_CONF")"
  touch "$TMUX_CONF"

  local bind_line
  bind_line="bind $BIND_KEY display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT '$INSTALL_PATH'"
  local bind_pattern="^[[:space:]]*bind(-key)?([[:space:]]+(-r|-n))*[[:space:]]+(-T[[:space:]]+prefix[[:space:]]+)?$BIND_KEY([[:space:]]+|$)"
  local palette_bind_pattern="$bind_pattern.*tmux-key-palette"

  if grep -Fq "$MARKER_BEGIN" "$TMUX_CONF"; then
    local tmp
    tmp="$(mktemp)"
    awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" -v bind_line="$bind_line" '
      $0 == begin {
        print begin
        print bind_line
        print end
        in_block = 1
        next
      }
      $0 == end {
        in_block = 0
        next
      }
      !in_block { print }
    ' "$TMUX_CONF" > "$tmp"
    mv "$tmp" "$TMUX_CONF"
    BINDING_STATUS="updated managed block in $TMUX_CONF"
  elif grep -Eq "$palette_bind_pattern" "$TMUX_CONF"; then
    local tmp
    tmp="$(mktemp)"
    awk -v pattern="$palette_bind_pattern" -v line="$bind_line" '
      $0 ~ pattern {
        print line
        next
      }
      { print }
    ' "$TMUX_CONF" > "$tmp"
    mv "$tmp" "$TMUX_CONF"
    BINDING_STATUS="updated existing tmux-key-palette binding in $TMUX_CONF"
  elif grep -Eq "$bind_pattern" "$TMUX_CONF"; then
    local existing_binding
    existing_binding="$(grep -E "$bind_pattern" "$TMUX_CONF" | head -n 1)"
    cat >&2 <<EOF
tmux-key-palette: $TMUX_CONF already has a binding for prefix + $BIND_KEY:
  $existing_binding
Not overwriting it. Re-run with TMUX_KEY_PALETTE_BIND_KEY=P to choose another key.
EOF
    BINDING_STATUS="skipped binding because prefix + $BIND_KEY is already used"
  else
    printf '\n%s\n%s\n%s\n' "$MARKER_BEGIN" "$bind_line" "$MARKER_END" >> "$TMUX_CONF"
    BINDING_STATUS="added managed block to $TMUX_CONF"
  fi
}

main() {
  need tmux
  need fzf
  need awk
  need sort

  install_palette
  patch_tmux_conf

  if [[ -n "${TMUX:-}" ]]; then
    tmux source-file "$TMUX_CONF"
  fi

  echo "tmux-key-palette installed to $INSTALL_PATH"
  echo "tmux-key-palette: $BINDING_STATUS"
}

main "$@"
