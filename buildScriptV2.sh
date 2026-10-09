#!/bin/bash

####################################
# GLOBAL(S) var
####################################

OUTPUT_FILE=nvim_installV2.sh

####################################
# Functions
####################################
# S1 => pattern
# $2 => fileName
# $3 => localFilename
addDataToFile(){
  echo 'if [ $(grep '"$1 $2"' |wc -l ) -eq 0 ]; then' >> $OUTPUT_FILE
  echo "cat >> $2 << EOF_$1" >> $OUTPUT_FILE
  # case for vimrc
  if [[ "$2" == *"vimrc"* ]]; then
  echo "\" $1" >> $OUTPUT_FILE
  else
  echo "# $1" >> $OUTPUT_FILE
  fi
  echo "<<<$1>>>" >> $OUTPUT_FILE
  echo "EOF_$1" >> $OUTPUT_FILE
  sed -i -e "/<<<$1>>>/r $3" -e "s/<<<$1>>>//g"  $OUTPUT_FILE
  echo "else" >> $OUTPUT_FILE
  echo 'echo "Nothing to do"' >> $OUTPUT_FILE
  echo "fi" >> $OUTPUT_FILE
}
addTestUserAsRoot(){
  echo 'if (whoami != root)' >> $OUTPUT_FILE
  echo 'then echo "Please run as root"' >> $OUTPUT_FILE
  echo 'exit 1' >> $OUTPUT_FILE
  echo 'fi' >> $OUTPUT_FILE
}

initFile(){
  echo "#!/bin/bash" > $OUTPUT_FILE
}

addToFile(){
  echo $1 >> $OUTPUT_FILE
}

####################################
# build OUTPUT_FILE
####################################

# Init file
initFile
addToFile "mkdir -p ~/.config/nvim/"

#addTestUserAsRoot
# add tmux conf
addDataToFile PAT1 "~/.tmux.conf" Docker_build/tmuxFile
# add vim conf
addDataToFile PAT2 "~/.config/nvim/init.lua" Docker_build/nvimInit
# add bashrc conf
addDataToFile PAT3 "~/.bashrc" Docker_build/bashrc
# add coc-settings conf
addDataToFile PAT4 "~/.config/nvim/coc-settings.json" Docker_build/cocSettings

addToFile 'sed -Ei "s/(-- )(vim.g.coc_global_extensions)/\2/g" ~/.config/nvim/init.lua'
# install apt tools
addToFile "if ! command -v sudo &> /dev/null; then"
addToFile "apt update && apt install sudo -y" 
addToFile "fi"
addToFile "sudo apt update && sudo apt install git tmux curl python3-dev python3-pip python3-venv neovim fzf jq nano -y" 

# node install
addToFile 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash'
addToFile 'if ! grep -qs NVM_DIR="$HOME/.nvm" ~/.bashrc; then'
addToFile "  cat << 'EOF' >> ~/.bashrc"
addToFile 'export NVM_DIR="~/.nvm"'
addToFile '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
addToFile '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
addToFile "EOF"
addToFile "  echo 'NVM configuration added to ~/.bashrc'"
addToFile "else"
addToFile "  echo 'NVM configuration already exists in ~/.bashrc'"
addToFile "fi"
addToFile 'export NVM_DIR="$HOME/.nvm"'
addToFile '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
addToFile "nvm install --lts" 
addToFile 'nvm alias default "lts/*"'

# 1. Install vim-plug
addToFile "curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# 2. install coc
addToFile "curl -fsSL https://cocnvim.com/install-coc.sh | bash -s -- --editor=nvim --yes --no-config"

# 3. Install coc.nvim plugins
addToFile "nvim --headless +PlugInstall +qall"
#addToFile "cd ~/.config/coc/extensions/ && npm install coc-json coc-css coc-cssmodules coc-marketplace coc-git coc-sh coc-jedi coc-snippets coc-yaml coc-html coc-explorer"

# 4. Create a dedicated venv and install jedi-language-server during the BUILD step
addToFile "cd /opt/"
addToFile 'python3 -m venv ~/.local/share/nvim/.jedi-venv && \'
addToFile '    ~/.local/share/nvim/.jedi-venv/bin/pip3 install -U pip && \'
addToFile "    ~/.local/share/nvim/.jedi-venv/bin/pip3 install 'jedi-language-server>=0.41.1'"

