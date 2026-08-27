#!/usr/bin/env bash
set -euo pipefail

BASHRC="${HOME}/.bashrc"

# --- The code to ensure exists in ~/.bashrc ---
FUNCTIONS_BLOCK=$(cat <<'EOF'

myfcd() {
    local start_dir
    start_dir="${1:-$(pwd)}"
    local selected
    selected=$(find "$start_dir" -mindepth 1 -type d 2>/dev/null |
        fzf -m \
            --preview 'ls -al --color=always {}' \
            --bind 'enter:execute(echo "cd $(printf %q {})")+abort')
    if [[ -n $selected ]]; then
        eval -- "$selected"
    fi
}


myfzf() {
    ls "$@" | fzf -m | fzf --sync -x -m \
        --preview-window=right:70%:border \
        --bind "ctrl-space:preview([ -x \"\$(command -v bat)\" ] && bat --style=numbers --color=always {} || [ -x \"\$(command -v batcat)\" ] && batcat --style=numbers --color=always {} || cat {})" \
        --bind "ctrl-g:preview(git log --oneline --decorate --graph --all 2>&1 || echo 'Not a git repo')" \
        --bind "alt-i:preview(ls -al --color=always)" \
        --bind "ctrl-s:preview([ -x \"\$(command -v ccze)\" ] && stat {} | ccze -A || stat {})" \
        --bind "enter:execute(vim -p {+})" \
        --header "tab: select | ctrl‑space: preview | ctrl‑g: git log | alt‑i: ls | ctrl‑s: stat | enter: edit"
}

export -f myfcd
export -f myfzf
EOF
)

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Check whether a function name already exists in ~/.bashrc
has_func_in_bashrc() {
  local fn="$1"
  # Matches: "fn() {" or "function fn {" (also tolerates leading spaces)
  grep -Eq "^[[:space:]]*((${fn})[[:space:]]*\(\)[[:space:]]*\{|function[[:space:]]+${fn}\b)" "$BASHRC" 2>/dev/null
}

append_block_if_missing() {
  local missing=0
  if ! has_func_in_bashrc "myfcd"; then missing=1; fi
  if ! has_func_in_bashrc "myfzf"; then missing=1; fi

  if [[ "$missing" -eq 1 ]]; then
    echo "[*] Functions not found in $BASHRC. Appending..."
    touch "$BASHRC"
    {
      echo ""
      echo "# --- Added by installer ---"
      echo "$FUNCTIONS_BLOCK"
      echo "# --- End Added by installer ---"
    } >> "$BASHRC"
  else
    echo "[*] Functions already exist in $BASHRC. Skipping append."
  fi
}

install_pkg() {
  local pkg="$1"

  # Debian/Ubuntu
  if have_cmd apt-get; then
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
    return 0
  fi

  # Fedora/RHEL/CentOS
  if have_cmd dnf; then
    sudo dnf install -y "$pkg"
    return 0
  fi
  if have_cmd yum; then
    sudo yum install -y "$pkg"
    return 0
  fi

  # Arch/Manjaro
  if have_cmd pacman; then
    sudo pacman -Sy --noconfirm "$pkg"
    return 0
  fi

  echo "[-] No supported package manager found to install '$pkg'. Please install it manually."
  return 1
}

install_deps() {
  if ! have_cmd fzf; then
    echo "[*] fzf not installed. Installing..."
    # Package name is typically "fzf" on most distros
    install_pkg "fzf"
  else
    echo "[*] fzf already installed."
  fi

  if ! have_cmd ccze; then
    echo "[*] ccze not installed. Installing..."
    # Package name is typically "ccze" on most distros
    install_pkg "ccze"
  else
    echo "[*] ccze already installed."
  fi
}

main() {
  # Ensure ~/.bashrc exists
  touch "$BASHRC"

  append_block_if_missing
  install_deps

  echo "[*] Sourcing $BASHRC ..."
  # shellcheck disable=SC1090
  source "$BASHRC"
  echo "[+] Done. Try: myfcd  (or myfzf)"
}

main "$@"
