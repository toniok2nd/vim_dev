#!/bin/bash

####################################
# GLOBAL(S) var
####################################

OUTPUT_FILE=template

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


addTestUserAsRoot
# add tmux conf
addDataToFile PAT1 "~/.tmux.conf" tmuxFile
# add vim conf
addDataToFile PAT2 "~/.vimrc" vimrcFile
# add bashrc conf
addDataToFile PAT3 "~/.bashrc" bashrcFile
# add coc-settings conf
addDataToFile PAT4 "~/.vim/coc-settings.json" coc-settings.json
# add profile conf
addDataToFile PAT5 "~/.profile" profileFile
# add snippets conf
addToFile "mkdir -p ~/.config/coc/ultisnips/"
addDataToFile PAT6 "~/.config/coc/ultisnips/yaml.snippets" yaml.snippets

# install apt tools
addToFile "if ! command -v sudo &> /dev/null; then"
addToFile "apt update && apt install sudo -y" 
addToFile "fi"
addToFile "sudo apt update && sudo apt install git curl make clang libtool-bin python3-dev python3-pip exuberant-ctags python3-venv golang-go ranger -y" 

# install python
addToFile "pip3 install jedi && pip3 install console_colors" 


#----------
# VIM
#----------
# test if vim is installed
addToFile "if ! command -v vim &> /dev/null; then"
addToFile 'if ! [ $(vim --version | grep -q "+python";echo $?) -eq 0 ];then '
# clone vim REPO
addToFile "git clone https://github.com/vim/vim.git" 
# configure and compile vim
addToFile "cd vim && ./configure --enable-python3interp && cd src && make && make install" 
addToFile "fi"
addToFile "fi"

# install nodejs
addToFile "cat <(echo 'FORCE'='yes') <(curl -sL install-node.now.sh/lts) |bash" 
addToFile "npm install --global yarn" 

# install plug for vim
#addToFile "curl -fLo ~/.var/app/io.neovim.nvim/data/nvim/site/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
#addToFile "mkdir -p ~/.vim/plugged/coc.nvim/"
#addToFile "cd ~/.vim/plugged/coc.nvim/ && yarn install" 
#addToFile "vim  +PlugInstall +qall" 
