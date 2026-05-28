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

tmux uses a prefix key before most key bindings. The default prefix is `Ctrl-b`.

On macOS:

```sh
brew install tmux fzf
```

On Debian/Ubuntu:

```sh
sudo apt install tmux fzf
```

On Arch Linux:

```sh
sudo pacman -S tmux fzf
```

## Quick Start

After installing, press your tmux prefix, then `K` to open the palette. With the
default tmux prefix, that is `Ctrl-b`, then `K`.

Search for a binding and press Enter. The selected tmux command runs.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/programbo/tmux-key-palette/main/install.sh | bash
```

To inspect the installer before running it:

```sh
curl -fsSL https://raw.githubusercontent.com/programbo/tmux-key-palette/main/install.sh -o install.sh
less install.sh
bash install.sh
```

The installer:

1. installs `tmux-key-palette` to `~/.local/bin`
2. adds a managed `prefix + K` binding to `~/.tmux.conf` when that key is free
3. updates an existing managed block or existing `tmux-key-palette` binding
4. refuses to overwrite an unrelated `prefix + K` binding
5. sources `~/.tmux.conf` when run inside tmux

## Configure Install

The default binding is `K`. Set `TMUX_KEY_PALETTE_BIND_KEY` to choose another
prefix key.

```sh
TMUX_KEY_PALETTE_BIND_KEY=P \
TMUX_KEY_PALETTE_POPUP_WIDTH=90 \
TMUX_KEY_PALETTE_POPUP_HEIGHT=70% \
curl -fsSL https://raw.githubusercontent.com/programbo/tmux-key-palette/main/install.sh | bash
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

If `~/.local/bin` is not in your `PATH`, either add it or bind tmux to the full
install path as shown above.

## Uninstall

Remove the installed script:

```sh
rm -f ~/.local/bin/tmux-key-palette
```

Remove the managed block from `~/.tmux.conf`:

```sh
perl -0pi -e 's/\n?# >>> tmux-key-palette >>>\n.*?\n# <<< tmux-key-palette <<<\n?/\n/s' ~/.tmux.conf
```

Then reload tmux config or restart tmux:

```sh
tmux source-file ~/.tmux.conf
```

## Troubleshooting

- If the palette does not appear, confirm `display-popup` is available with
  `tmux -V`. tmux 3.2 or newer is required.
- If `fzf` is not found, check that it is installed and on your `PATH` with
  `which fzf`.
- If the binding was not created, read the installer message. It refuses to
  overwrite an existing unrelated binding for the same prefix key. Re-run with
  `TMUX_KEY_PALETTE_BIND_KEY=P` or add a manual binding.
