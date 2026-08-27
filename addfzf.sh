#!/usr/bin/env bash
set -euo pipefail

BASHRC="$HOME/.bashrc"

# ---- Your functions block ----
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

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# If functions exist in ~/.bashrc already, don't add again
func_in_bashrc() {
  local fname="$1"
  # Match either "fname() {" or "function fname {" forms
  grep -Eq "^[[:space:]]*((${fname})[[:space:]]*\(\)[[:space:]]*\{|function[[:space:]]+${fname}\b)" "$BASHRC" 2>/dev/null
}

# Install packages on Ubuntu/Debian using apt-get
install_if_missing_apt() {
  local pkg="$1"
  local cmd="$2"

  if have_cmd "$cmd"; then
    echo "[+] $cmd already installed"
    return 0
  fi

  if ! have_cmd apt-get; then
    echo "[-] apt-get not found. Please install '$pkg' manually."
    exit 1
  fi

  echo "[*] Installing missing package: $pkg"
  sudo apt-get update -y
  sudo apt-get install -y "$pkg"
}

mkdir -p "$(dirname "$BASHRC")"
touch "$BASHRC"

# ---- Ensure fzf + ccze ----
# Debian/Ubuntu package names:
install_if_missing_apt "fzf" "fzf"
install_if_missing_apt "ccze" "ccze"

# ---- Append functions if missing ----
need_append=0
if ! func_in_bashrc "myfcd"; then need_append=1; fi
if ! func_in_bashrc "myfzf"; then need_append=1; fi

if [[ "$need_append" -eq 1 ]]; then
  echo "[*] Adding myfcd/myfzf to $BASHRC"
  {
    echo ""
    echo "# --- Added by addfzf.sh ---"
    echo "$FUNCTIONS_BLOCK"
    echo "# --- End Added by addfzf.sh ---"
  } >> "$BASHRC"
else
  echo "[+] myfcd/myfzf already exist in $BASHRC"
fi

echo "[*] Sourcing $BASHRC"
# shellcheck disable=SC1090
source "$BASHRC"

echo "[+] Done. Try: myfcd / myfzf"
