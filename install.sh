#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

info() { printf '→ %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

macos() { [[ "$(uname -s)" == Darwin ]]; }

cursor_user_dir() {
  if macos; then
    echo "$HOME/Library/Application Support/Cursor/User"
  else
    echo "$HOME/.config/Cursor/User"
  fi
}

vscode_user_dir() {
  if macos; then
    echo "$HOME/Library/Application Support/Code/User"
  else
    echo "$HOME/.config/Code/User"
  fi
}

backup_then_link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP"
    mv "$dest" "$BACKUP/$(basename "$dest")"
  fi
  ln -sfn "$src" "$dest"
  info "linked $dest"
}

clone_if_missing() {
  local repo="$1" dest="$2"
  if [[ ! -d "$dest" ]]; then
    git clone --depth=1 "$repo" "$dest"
  else
    info "already present: $dest"
  fi
}

install_shell() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  clone_if_missing https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting"

  backup_then_link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
  backup_then_link "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  backup_then_link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
}

install_editor() {
  local cursor_dir vscode_dir
  cursor_dir="$(cursor_user_dir)"
  vscode_dir="$(vscode_user_dir)"

  mkdir -p "$cursor_dir" "$vscode_dir"
  backup_then_link "$DOTFILES/cursor/settings.json" "$cursor_dir/settings.json"
  backup_then_link "$DOTFILES/cursor/keybindings.json" "$cursor_dir/keybindings.json"
  backup_then_link "$DOTFILES/vscode/settings.json" "$vscode_dir/settings.json"
  backup_then_link "$DOTFILES/vscode/keybindings.json" "$vscode_dir/keybindings.json"
}

install_extensions() {
  local line

  if command -v cursor >/dev/null 2>&1; then
    info "installing Cursor extensions"
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      cursor --install-extension "$line" || warn "could not install $line"
    done < "$DOTFILES/cursor/extensions.txt"
  else
    warn "cursor CLI not found; skip Cursor extensions"
  fi

  if command -v code >/dev/null 2>&1; then
    info "installing VS Code extensions"
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      code --install-extension "$line" || warn "could not install $line"
    done < "$DOTFILES/vscode/extensions.txt"
  else
    warn "code CLI not found; skip VS Code extensions"
  fi
}

install_fonts() {
  if command -v brew >/dev/null 2>&1; then
    info "installing fonts via Homebrew"
    brew bundle --file="$DOTFILES/Brewfile" || warn "brew bundle had issues"
  else
    warn "Homebrew not found. Install MesloLGS NF + JetBrains Mono by hand for the prompt and editor."
  fi
}

usage() {
  cat <<EOF
Usage: ./install.sh [all|shell|editor|extensions|fonts]

  all          shell + editor + extensions + fonts (default)
  shell        Oh My Zsh, p10k, autosuggestions, gitconfig
  editor       Cursor + VS Code settings and keybindings
  extensions   suggested Cursor / VS Code extensions
  fonts        JetBrains Mono, MesloLGS NF, Geist Mono
EOF
}

main() {
  local target="${1:-all}"
  case "$target" in
    -h|--help) usage ;;
    all)
      install_shell
      install_editor
      install_fonts
      install_extensions
      info "done. restart the terminal (or run: exec zsh)"
      [[ -d "$BACKUP" ]] && info "previous files saved in $BACKUP"
      ;;
    shell) install_shell ;;
    editor) install_editor ;;
    extensions) install_extensions ;;
    fonts) install_fonts ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
