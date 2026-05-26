# tmux-key-palette

A small fzf command palette for tmux prefix key bindings.

It shows a compact searchable list of:

```text
Key        Description
```

The selected binding's full tmux command appears in the preview panel and runs
when you press Enter.

## Requirements

- tmux 3.2 or newer
- fzf
- bash
- awk
- sort

On macOS:

```sh
brew install tmux fzf
```

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/john/tmux-key-palette/main/install.sh | bash
```

The installer:

- installs `tmux-key-palette` to `~/.local/bin`
- adds a managed `prefix + K` binding to `~/.tmux.conf` when that key is free
- updates an existing managed block or existing `tmux-key-palette` binding
- refuses to overwrite an unrelated `prefix + K` binding
- sources `~/.tmux.conf` when run inside tmux

## Configure Install

```sh
TMUX_KEY_PALETTE_BIND_KEY=P \
TMUX_KEY_PALETTE_POPUP_WIDTH=90 \
TMUX_KEY_PALETTE_POPUP_HEIGHT=70% \
curl -fsSL https://raw.githubusercontent.com/john/tmux-key-palette/main/install.sh | bash
```

If `prefix + K` is already used, the installer leaves that binding alone:

```text
tmux-key-palette: ~/.tmux.conf already has a binding for prefix + K:
  bind K display-popup ...
Not overwriting it. Re-run with TMUX_KEY_PALETTE_BIND_KEY=P to choose another key.
```

## Manual Binding

```tmux
bind K display-popup -E -w 80 -h 60% '~/.local/bin/tmux-key-palette'
```
