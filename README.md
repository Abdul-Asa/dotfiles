# Dotfiles

Personal zsh, Cursor, and VS Code setup. Private on purpose — clone it on a work laptop after `gh auth login`.

## What's in here

- **Terminal:** Oh My Zsh + Powerlevel10k (`zsh/.zshrc`, `zsh/.p10k.zsh`)
- **Suggestions:** `zsh-autosuggestions` (ghost text from history) and `zsh-syntax-highlighting`
- **Cursor:** settings, keybindings, suggested extensions
- **VS Code:** settings, keybindings, suggested extensions, plus three look-profiles (`tabletop`, `vibes`, `icons`)
- **Git:** name/email only. Work email goes in `~/.gitconfig.local` (not in this repo)

Left out on purpose: SSH keys, `.git-credentials`, MCP/API tokens, Azure/Claude/Raycast account data, Homebrew packages that aren't fonts.

## Work laptop

```bash
gh auth login
git clone git@github.com:Abdul-Asa/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

`./install.sh` backs up anything it replaces into `~/.dotfiles-backup-<timestamp>`, then symlinks these files.

Pieces:

```bash
./install.sh shell        # zsh + p10k + git
./install.sh editor       # Cursor + VS Code settings/hotkeys
./install.sh extensions   # suggested extensions
./install.sh fonts        # JetBrains Mono, MesloLGS NF, Geist Mono
```

After shell install, open a new terminal. If the prompt looks broken, the Nerd Font isn't active yet — set the terminal font to **MesloLGS NF**.

Work git identity (not committed):

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
	email = you@work.example
EOF
```

## Cursor hotkeys (this machine)

| Keys | Action |
| --- | --- |
| `Cmd+I` | Agent (editor) / generate in terminal |
| `Cmd+L` | Toggle auxiliary bar (chat) |
| `Cmd+J` | Toggle terminal |
| `Ctrl+`` | Toggle panel |
| `Cmd+K` | Clear terminal (when focused) |
| `Cmd+Up` / `Cmd+Down` | Previous / next terminal |
| `Shift+Cmd+I` | Select all highlights (editor) or generate in terminal |

VS Code is simpler: `Cmd+J` toggles the terminal, `Cmd+N` creates a file in the explorer.

## Recommendations worth taking (not already in this repo)

**Do take**

1. **Fonts** — p10k is configured for Nerd Fonts. `./install.sh fonts` covers this.
2. **Work git email** — `~/.gitconfig.local` as above. Don't reuse the personal address on company repos if IT cares.
3. **Raycast** — you already use it. Recreate the few hotkeys you care about (clipboard history, window snipping, emoji). Don't copy `~/.config/raycast`; it has account/session data.
4. **Caps Lock remap** — System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys. Caps Lock → Escape or Control. You don't have Karabiner installed, so this one setting is enough.
5. **Faster key repeat** — System Settings → Keyboard, bump Key Repeat and Delay Until Repeat. Developers feel this all day; you don't currently have a custom value set.

**Skip**

- macOS Keyboard Shortcuts plists (`~/Library/Preferences`) — they mix Apple ID, app IDs, and machine state
- SSH keys — generate a new key on the work laptop and add that public key to GitHub
- Cursor MCP / Claude / Azure configs — tokens
- Karabiner — you don't have a layout to bring

**Maybe later**

- `fzf` + `zoxide` if the history suggestions aren't enough
- A window manager (Raycast window commands, or Rectangle) if the work laptop has no equivalent

## Profiles

Cursor's extra "Vite" profile just pointed at the default settings, so it isn't copied.

VS Code profiles are settings snapshots, not a one-click import:

- `vscode/profiles/tabletop` — Atom One Dark, vscode-icons, no minimap
- `vscode/profiles/vibes` — GitHub Dark, Material icons, pets, frontend extras
- `vscode/profiles/icons` — Nomo Dark + product icon theme experiment
