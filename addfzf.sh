#!/usr/bin/env bash
set -euo pipefail

BASHRC="${HOME}/.bashrc"

read -r -d '' FUNCTIONS_BLOCK <<'EOF'
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

# --- helpers ---
have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Detect if function exists in ~/.bashrc (rough but practical)
func_exists() {
  local fname="$1"
  grep -Eq "^[[:space:]]*${fname}[[:space:]]*\(" "$BASHRC" 2>/dev/null
}

install_if_missing_apt() {
  local pkg="$1"
  local cmd="$2"

  if have_cmd "$cmd"; then
    echo "[+] ${cmd} already installed"
    return 0
  fi

  echo "[*] ${cmd} not found. Installing ${pkg}..."
  sudo apt-get update -y
  sudo apt-get install -y "$pkg"
}

# --- ensure apt exists (Ubuntu/Debian case) ---
if ! have_cmd apt-get; then
  echo "[-] apt-get not found. This script currently installs using apt (Ubuntu/Debian)."
  exit 1
fi

# --- ensure dependencies ---
# Package names on Ubuntu/Debian are usually:
#   fzf  -> fzf
#   ccze -> ccze
install_if_missing_apt "fzf" "fzf"
install_if_missing_apt "ccze" "ccze"

# --- ensure functions in ~/.bashrc ---
touch "$BASHRC"

need_append=0
if ! func_exists "myfcd"; then
  need_append=1
fi
if ! func_exists "myfzf"; then
  need_append=1
fi

if [[ "$need_append" -eq 1 ]]; then
  echo "[*] Appending functions to $BASHRC ..."
  {
    echo ""
    echo "# --- Added by installer: myfcd/myfzf ---"
    echo "$FUNCTIONS_BLOCK"
    echo "# --- End added by installer ---"
  } >> "$BASHRC"
else
  echo "[+] Functions already exist in $BASHRC"
fi

# --- source bashrc ---
echo "[*] Sourcing $BASHRC ..."
# shellcheck disable=SC1090
source "$BASHRC"

echo "[+] Done."
