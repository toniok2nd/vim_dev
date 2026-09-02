#!/usr/bin/env bash
set -e

echo "==========================================================="
echo " Starting Thales Assistant System & Dev Environment Setup..."
echo "==========================================================="

# Helper to use sudo only if it's available (Alpine often runs as root without sudo)
SUDO_CMD=""
if command -v sudo >/dev/null 2>&1; then
    SUDO_CMD="sudo"
fi

# 1. Detect OS and Install Dependencies
echo "[1/7] Detecting OS and installing dependencies..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS from /etc/os-release. Exiting."
    exit 1
fi

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo "Detected Ubuntu/Debian."
    $SUDO_CMD apt-get update -y
    $SUDO_CMD apt-get install -y tmux python3-pip python3-venv curl git bash neovim nodejs npm nano openssl tzdata fzf jq
    
    # Historically reliable method to install yarn on Ubuntu
    $SUDO_CMD npm install --global yarn

elif [ "$OS" = "alpine" ]; then
    echo "Detected Alpine Linux."
    $SUDO_CMD apk update
    $SUDO_CMD apk --no-cache add tmux py3-pip curl git bash neovim nodejs npm nano yarn openssl tzdata fzf jq python3
else
    echo "Unsupported OS: $OS. This script supports Ubuntu/Debian and Alpine."
    exit 1
fi

# 2. Setup Directories
echo "[2/7] Creating directory structures..."
mkdir -p "$HOME/.local/share/nvim/site/autoload" "$HOME/.config/nvim"

# 3. Install vim-plug
echo "[3/7] Installing vim-plug..."
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 4. Install coc.nvim environment 
echo "[4/7] Running coc.nvim install script..."
curl -fsSL https://cocnvim.com/install-coc.sh | bash -s -- --editor=nvim

# 5. Write Configuration Files
echo "[5/7] Writing configuration files..."

# Write .tmux.conf
cat << 'EOF' > "$HOME/.tmux.conf"
# to write on user directory as .tmux.conf
# remap prefix from 'C-b' to 'C-q'
unbind C-b
set-option -g prefix C-q
bind-key C-q send-prefix
 
# set mode-keys vi
set -g mode-keys vi
 
# https://github.com/dminca/dotfiles/tree/master/dotfiles
# vim style
###########
# vim-like pane switching
bind -r k select-pane -U
bind -r j select-pane -D
bind -r h select-pane -L
bind -r l select-pane -R
 
# vim-like pane resizing
bind -r C-k resize-pane -U
bind -r C-j resize-pane -D
bind -r C-h resize-pane -L
bind -r C-l resize-pane -R
 
# unbind
unbind Up
unbind Down
unbind Left
unbind Right
 
unbind C-Up
unbind C-Down
unbind C-Left
unbind C-Right

unbind %
unbind '"'
bind % split-window -h -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"

set -g status-style bg=red,fg=white
set -g window-status-current-style bg=green
EOF

# Write init.lua
cat << 'EOF' > "$HOME/.config/nvim/init.lua"
-- ==========================================================================
-- 1. PLUGIN MANAGER (vim-plug)
-- ==========================================================================
vim.cmd [[
  call plug#begin('~/.local/share/nvim/plugged')
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'honza/vim-snippets'
  
  " Add your custom colorscheme here:
  Plug 'ellisonleao/gruvbox.nvim' 
  call plug#end()
]]
-- Automatically install these extensions if they are missing
vim.g.coc_global_extensions = { 'coc-json', 'coc-pyright', 'coc-css', 'coc-cssmodules', 'coc-marketplace', 'coc-git', 'coc-sh', 'coc-jedi', 'coc-snippets', 'coc-yaml', 'coc-html', 'coc-explorer'}

-- FIX 1: Safely check if coc.nvim is installed before calling its functions
vim.cmd([[
  if exists('*coc#config')
    call coc#config('snippets.ultisnips.enable', v:false)
  endif
]])

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme vim]])

-- Menu color conf
vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, "Pmenu", { bg = "white", fg = "black", bold = true })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "lightgreen", fg = "black", bold = true })
vim.api.nvim_set_hl(0, "CocMenuSel", { bg = "lightgreen", fg = "black", bold = true })
vim.api.nvim_set_hl(0, "CocListLine", { bg = "lightgreen", fg = "black", bold = true })

-- ==========================================================================
-- 2. GENERAL SETTINGS
-- ==========================================================================
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.ruler = true
vim.opt.fileencoding = "utf-8"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.laststatus = 1
vim.opt.listchars:append({ space = '.', tab = '>-' })
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmatch = true
vim.opt.belloff = "all"

-- FIX: Added 'jj' back as the trigger key! 
vim.keymap.set({'i', 'c'}, 'jj', '<ESC>', { noremap = true })

-- ==========================================================================
-- 3. COC.NVIM KEYMAPPINGS & CONFIGURATION
-- ==========================================================================
-- Show coc.nvim status 
vim.opt.statusline:prepend('%{coc#status()}')

local keyset = vim.keymap.set
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Trigger completion with Tab and navigate the completion menu
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
keyset('i', '<TAB>', 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset('i', '<S-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
keyset('i', '<CR>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], { silent = true, expr = true })

-- Diagnostics and code navigation
keyset('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
keyset('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })
keyset('n', 'gd', '<Plug>(coc-definition)', { silent = true })
keyset('n', 'gy', '<Plug>(coc-type-definition)', { silent = true })
keyset('n', 'gi', '<Plug>(coc-implementation)', { silent = true })
keyset('n', 'gr', '<Plug>(coc-references)', { silent = true })
keyset('n', '<leader>rn', '<Plug>(coc-rename)', { silent = true })

-- ==========================================================================
-- 4. COCLIST MAPPINGS
-- ==========================================================================
local list_opts = {silent = true, nowait = true}
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", list_opts)
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", list_opts)
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", list_opts)
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", list_opts)
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", list_opts)
keyset("n", "<space>j", ":<C-u>CocNext<CR>", list_opts)
keyset("n", "<space>k", ":<C-u>CocPrev<CR>", list_opts)
keyset("n", "<space>p", ":<C-u>CocListResume<CR>", list_opts)
keyset("n", "<space>m", ":<C-u>CocList marketplace<CR>", list_opts)
keyset("n", "<space>ns", ":<C-u>CocList snippets<CR>", list_opts)
keyset("n", "<space>h", ":<C-u>wincmd h<CR>", list_opts)
keyset("n", "<space>l", ":<C-u>wincmd l<CR>", list_opts)
keyset("n", "<space><Right>", ":<C-u>wincmd h<CR>", list_opts)
keyset("n", "<space><Left>", ":<C-u>wincmd l<CR>", list_opts)
keyset("n", "<space><space>", ":<C-u>CocCommand explorer<CR>", list_opts)
EOF

# Write coc-settings.json
cat << 'EOF' > "$HOME/.config/nvim/coc-settings.json"
{
  "jedi.executable.command": "/opt/jedi-venv/bin/jedi-language-server",
  "snippets.ultisnips.pythonPrompt": false,
  "explorer.keyMappings.global": {
    "t": ["open:tab", "quit"],
    "<cr>": "toggleSelection",
    "<space>": false    
  }
}
EOF

# 6. Setup Jedi Language Server
echo "[6/7] Setting up python venv and jedi-language-server in /opt..."
$SUDO_CMD mkdir -p /opt/jedi-venv
$SUDO_CMD chown -R $(whoami) /opt/jedi-venv
python3 -m venv /opt/jedi-venv
/opt/jedi-venv/bin/pip3 install -U pip
/opt/jedi-venv/bin/pip3 install jedi-language-server==0.41.1

# 7. Install Neovim Plugins and CoC Extensions
echo "[7/7] Installing Neovim plugins and coc.nvim extensions..."
nvim --headless +PlugInstall +qall
nvim --headless -c "CocInstall -sync coc-json coc-pyright coc-css coc-cssmodules coc-marketplace coc-git coc-sh coc-jedi coc-snippets coc-yaml coc-html coc-explorer" -c "qa"

echo "==========================================================="
echo " Setup complete! Enjoy your unified development environment."
echo "==========================================================="
