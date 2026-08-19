# WezTerm  Keyboard Shortcuts, Commands and Setup Notes

Prepared for this machine: `wezterm 20240203-110809`
Keyboard layout: **Turkish-Q (tr, pc105)**

All keyboard shortcuts below were verified using `wezterm show-keys` rather than relying on memory or the documentation.

---

## 0. The One Shortcut You Really Need to Remember

**`Ctrl+Shift+P` → Command Palette**

You don't really need to memorize everything below. Open the Command Palette and search for what you want:

* `split`
* `tab`
* `font`
* `search`
* etc.

It will show the available action and its keyboard shortcut.

If a shortcut doesn't work, the Command Palette is usually the easiest way to find the correct one.

Another useful command is:

```bash
wezterm show-keys
```

This prints the actual key bindings for the current configuration.

If this document becomes outdated, `wezterm show-keys` should be considered the source of truth.

---

## 1. Tabs

| Action                            | Shortcut                                    |
| --------------------------------- | ------------------------------------------- |
| New tab                           | `Ctrl+Shift+T`                              |
| Close tab (asks for confirmation) | `Ctrl+Shift+W`                              |
| Go to tab 1–9                     | `Ctrl+Shift+1` … `Ctrl+Shift+9`             |
| Go to last tab                    | `Ctrl+Shift+9`                              |
| Next / previous tab               | `Ctrl+Tab` / `Ctrl+Shift+Tab`               |
| Move tab left / right             | `Ctrl+Shift+PageUp` / `Ctrl+Shift+PageDown` |
| New window                        | `Ctrl+Shift+N`                              |

---

## 2. Panes

### Turkish-Q Keyboard Layout

The official documentation shows the split shortcuts as:

* `Ctrl+Shift+Alt+"`
* `Ctrl+Shift+Alt+%`

On a Turkish-Q keyboard, however:

* `Shift+2 = '`
* `Shift+5 = %`

So the actual working shortcuts on this machine are:

| Action                  | Shortcut              |
| ----------------------- | --------------------- |
| **Split horizontally**  | `Ctrl+Shift+Alt+2`    |
| **Split vertically**    | `Ctrl+Shift+Alt+5`    |
| Switch between panes    | `Ctrl+Shift+←↑↓→`     |
| Resize pane             | `Ctrl+Shift+Alt+←↑↓→` |
| Maximize / restore pane | `Ctrl+Shift+Z`        |
| Close pane              | `exit` or `Ctrl+D`    |

**Note:** In this version there is no dedicated keyboard shortcut for closing a pane. Use `exit` or `Ctrl+D`.

`Ctrl+Shift+W` closes the entire tab, including all panes inside it.

---

## 3. Copy, Paste and Search

| Action            | Shortcut                          |
| ----------------- | --------------------------------- |
| Copy / paste      | `Ctrl+Shift+C` / `Ctrl+Shift+V`   |
| Search scrollback | `Ctrl+Shift+F`                    |
| Enter copy mode   | `Ctrl+Shift+X`                    |
| Quick Select      | `Ctrl+Shift+Space`                |
| Clear scrollback  | `Ctrl+Shift+K`                    |
| Page up / down    | `Shift+PageUp` / `Shift+PageDown` |

### Copy Mode

Copy mode works similarly to Vim:

* `h j k l` — movement
* `w b e` — word movement
* `0 ^ $` — beginning / end of line
* `g` / `G` — top / bottom
* `v` — character selection
* `V` — line selection
* `Ctrl+V` — block selection
* `y` — copy and exit
* `q` or `Esc` — exit

### Search Mode

Inside search mode:

* `Ctrl+N` / `Ctrl+P` — next / previous match
* `Ctrl+R` — change matching mode (regex / case sensitivity)
* `Ctrl+U` — clear search
* `Esc` — exit search mode

---

## 4. Appearance and Display

| Action                        | Shortcut            |
| ----------------------------- | ------------------- |
| Increase / decrease font size | `Ctrl++` / `Ctrl+-` |
| Reset font size               | `Ctrl+0`            |
| Full screen                   | `Alt+Enter`         |
| Reload configuration          | `Ctrl+Shift+R`      |
| Emoji / character selector    | `Ctrl+Shift+U`      |
| Debug overlay                 | `Ctrl+Shift+L`      |

---

## 5. Persistence and Mux

This machine is configured to use the WezTerm mux as a persistent service.

In:

```text
~/.config/wezterm/wezterm.lua
```

the following is configured:

```lua
default_domain = 'main'
```

This means that every WezTerm window connects to the `main` domain, which is backed by a `wezterm-mux-server` running as a systemd user service.

The daemon is independent of the graphical session, so the terminal sessions continue running even after logging out.

I tested this with a real logout on **2026-08-19**, and the sessions remained alive.

### What happens when you do different things?

| Action                              | Result                                    |
| ----------------------------------- | ----------------------------------------- |
| Close the WezTerm window (X button) | **Detach** — processes continue running   |
| `exit` / `Ctrl+D` inside a shell    | **Actually terminates** that shell        |
| `Ctrl+Shift+W`                      | **Actually closes** the tab and its panes |

When you open a new WezTerm window, your existing panes and sessions are automatically available again.

If they don't appear for some reason:

```bash
wezterm connect main
```

---

## 6. Important Mux Socket Gotcha

There is an important detail when working with the mux from inside a pane.

Every `wezterm-gui` instance can run its own embedded mux and sets `WEZTERM_UNIX_SOCKET` inside its panes.

Because of this, running:

```bash
wezterm cli list
```

from inside a pane may show the mux belonging to that particular GUI instance instead of the systemd-managed daemon.

To explicitly target the persistent daemon, set its socket:

```bash
export WEZTERM_UNIX_SOCKET=/run/user/1000/wezterm/sock
```

Then:

```bash
wezterm cli list
```

Lists all panes in the daemon.

```bash
wezterm cli list-clients
```

Lists connected clients.

```bash
wezterm cli spawn
```

Creates a new tab/pane in the daemon.

```bash
wezterm cli split-pane --right
```

Splits the current pane to the right.

```bash
wezterm cli kill-pane --pane-id N
```

Kills a specific pane.

---

## 7. Check the Mux Service

To check whether the persistent mux service is running:

```bash
systemctl --user status wezterm-mux.service
```

For example, you can also use:

```bash
systemctl --user restart wezterm-mux.service
```

when you need to restart the service.

---

## 8. Useful WezTerm Commands

### Show current keyboard shortcuts

```bash
wezterm show-keys
```

This is the best way to see the actual key bindings currently in use.

### Show shortcuts in Lua format

```bash
wezterm show-keys --lua
```

Useful when you want to copy the output into `wezterm.lua`.

### Check version

```bash
wezterm --version
```

### List available fonts

```bash
wezterm ls-fonts
```

### Display an image inside the terminal

```bash
wezterm imgcat image.png
```

### Start a command in a new window

```bash
wezterm start -- <command>
```

For example:

```bash
wezterm start -- htop
```

### Connect to the persistent mux domain

```bash
wezterm connect main
```

Useful if the existing daemon session doesn't automatically appear.

### Record / replay a terminal session

```bash
wezterm record
wezterm replay
```

This can be used to record and replay terminal sessions as asciicasts.

---

## 9. Reading and Controlling Panes Programmatically

You can use `wezterm cli` to interact with panes from scripts or other tools.

First, point the CLI at the persistent mux:

```bash
export WEZTERM_UNIX_SOCKET=/run/user/1000/wezterm/sock
```

### Get pane contents

```bash
wezterm cli get-text --pane-id 0
```

This prints the current pane contents to stdout.

This is useful for capturing terminal output programmatically.

### Send text to a pane

```bash
wezterm cli send-text --pane-id 0 'ls'
```

This sends the text to the pane, effectively like pasting it into the terminal.

---

## 10. Useful Things to Keep in Mind

### Command Palette

If you forget a shortcut:

```text
Ctrl+Shift+P
```

Search for the action instead of trying to remember the key combination.

### Check the actual bindings

```bash
wezterm show-keys
```

This is especially important when using a non-US keyboard layout.

### Persistent sessions

With the systemd mux setup:

```text
Close window ≠ kill session
```

Closing the GUI window detaches from the session. The processes continue running in the background.

To actually terminate a shell or pane, use:

```bash
exit
```

or:

```text
Ctrl+D
```

---

## 11. Official Documentation

* Default key bindings: https://wezterm.org/config/default-keys.html
* Copy mode: https://wezterm.org/copymode.html
* `wezterm cli`: https://wezterm.org/cli/cli/
* Multiplexing and domains: https://wezterm.org/multiplexing.html
* Configuration reference: https://wezterm.org/config/files.html
