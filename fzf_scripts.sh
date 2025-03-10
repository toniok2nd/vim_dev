#!/bin/bash

# Install fzf, ripgrep, and bat (batcat)
echo "Installing fzf, ripgrep, and bat..."
if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y fzf ripgrep bat
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y fzf ripgrep bat
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm fzf ripgrep bat
elif command -v brew >/dev/null 2>&1; then
    brew install fzf ripgrep bat
elif command -v apk >/dev/null 2>&1; then
    apk update && apk add --no-cache bash fzf ripgrep bat
else
    echo "Unsupported package manager. Please install fzf, ripgrep, and bat manually."
    exit 1
fi

# Create the fzf multi-line preview script
echo "Creating ~/.fzf-multi-line-preview.sh..."
cat << 'EOF' > ~/.fzf-multi-line-preview.sh
#!/bin/bash
file="$1"
line="$2"
if [[ -f "$file" ]]; then
    if command -v batcat >/dev/null 2>&1; then
        batcat --style=numbers -r "$line:" --color=always --highlight-line "$line" --paging=never  -- "$file"
    else
        bat --style=numbers -r "$line:" --color=always --highlight-line "$line" --paging=never -- "$file"
    fi
else
    echo "File not found"
fi

EOF
chmod +x ~/.fzf-multi-line-preview.sh

# Add fzf options and function to .bashrc
echo "Updating ~/.bashrc..."
cat << 'EOF' >> ~/.bashrc

# Set FZF default options
export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --height=50% --border"

# Function to search lines in multiple files with fzf
fzf_multi_line_search() {
    rg --line-number --no-heading "$@" |
    fzf --preview="~/.fzf-multi-line-preview.sh {1} {2}" --preview-window=left,50% --delimiter=':' --with-nth=1,2
}
EOF

echo "Installation complete. Restart your terminal or run 'source ~/.bashrc' to apply changes."
