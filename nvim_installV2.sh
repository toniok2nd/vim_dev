#!/bin/bash
mkdir -p ~/.config/nvim/
if [ $(grep PAT1 ~/.tmux.conf |wc -l ) -eq 0 ]; then
cat >> ~/.tmux.conf << EOF_PAT1
# PAT1

# to write on user directory as .tmux.conf
# remap prefix from 'C-b' to 'C-space'
unbind C-b
set-option -g prefix C-space
bind-key C-space send-prefix
 
# set mode-keys vi
set -g mode-keys vi

# set mouse
#set -g mouse on

# copy past options
bind-key -T copy-mode-vi C-c send-keys -X copy-pipe-and-cancel "wl-copy"
bind-key -n C-v run "wl-paste -n | tmux load-buffer - ; tmux paste-buffer"
 
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

unbind '%'
unbind '"'
bind '%' split-window -h -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"

set -g status-style bg=red,fg=white,bold
set -g window-status-current-style bg=green,fg=red,bold
EOF_PAT1
else
echo "Nothing to do"
fi
if [ $(grep PAT2 ~/.config/nvim/init.lua |wc -l ) -eq 0 ]; then
cat >> ~/.config/nvim/init.lua << EOF_PAT2
# PAT2

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

-- ==========================================================================
-- 2. NVIM custom
-- ==========================================================================
-- Automatically install these extensions if they are missing
-- vim.g.coc_global_extensions = { 'coc-json', 'coc-css', 'coc-cssmodules', 'coc-marketplace', 'coc-git', 'coc-sh', 'coc-jedi', 'coc-snippets', 'coc-yaml', 'coc-html', 'coc-explorer'}

-- Safely check if coc.nvim is installed before calling its functions
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
-- 3. GENERAL SETTINGS
-- ==========================================================================
vim.g.clipboard = "tmux"
vim.opt.mouse = ""
vim.opt.clipboard = "unnamedplus"
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
-- 4. COC.NVIM KEYMAPPINGS & CONFIGURATION
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
-- 5. COCLIST MAPPINGS
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
EOF_PAT2
else
echo "Nothing to do"
fi
if [ $(grep PAT3 ~/.bashrc |wc -l ) -eq 0 ]; then
cat >> ~/.bashrc << EOF_PAT3
# PAT3

alias BASHRC='source ~/.bashrc'
alias VBASHRC='vim ~/.bashrc'
alias VENV='if [ -d VENV ]; then echo -e '\'' => '\''[32m'\''VENV found'\''; else echo -e '\'' => '\''[34m'\''NEW VENV'\''; python3 -m venv VENV; fi && source VENV/bin/activate'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gitC='git log --graph --format="%C(auto) %h %d %Cblue %cn (%cr) %n %Creset %s %n" --all'
alias gitL='git log --graph --oneline --decorate --all'
alias grep='grep --color=auto'
alias hf='history | fzf --tac --no-sort'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alth'
alias ls='ls --color=auto'
export PS1='\[\033[1;37;44m\][DEV]\[\033[0m\]\[\033[1;32m\]\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\] \$ '
EOF_PAT3
else
echo "Nothing to do"
fi
if [ $(grep PAT4 ~/.config/nvim/coc-settings.json |wc -l ) -eq 0 ]; then
cat >> ~/.config/nvim/coc-settings.json << EOF_PAT4
# PAT4

{
  "jedi.executable.command": "~/.local/share/nvim/.jedi-venv/bin/jedi-language-server",
  "snippets.ultisnips.pythonPrompt": false,
  "explorer.keyMappings.global": {
    "t": ["open:tab", "quit"],
    "<cr>": "toggleSelection",
    "<space>": false    
  }
}
EOF_PAT4
else
echo "Nothing to do"
fi
sed -Ei "s/(-- )(vim.g.coc_global_extensions)/\2/g" ~/.config/nvim/init.lua
if ! command -v sudo &> /dev/null; then
apt update && apt install sudo -y
fi
sudo apt update && sudo apt install git tmux curl python3-dev python3-pip python3-venv neovim fzf jq nano -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
if ! grep -qs NVM_DIR="$HOME/.nvm" ~/.bashrc; then
cat << 'EOF' >> ~/.bashrc
export NVM_DIR="~/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
echo 'NVM configuration added to ~/.bashrc'
else
echo 'NVM configuration already exists in ~/.bashrc'
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default "lts/*"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fsSL https://cocnvim.com/install-coc.sh | bash -s -- --editor=nvim --yes --no-config
nvim --headless +PlugInstall +qall
cd /opt/
python3 -m venv ~/.local/share/nvim/.jedi-venv && \
~/.local/share/nvim/.jedi-venv/bin/pip3 install -U pip && \
~/.local/share/nvim/.jedi-venv/bin/pip3 install 'jedi-language-server>=0.41.1'
