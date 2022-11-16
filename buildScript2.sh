#!/bin/bash
# S1 => pattern
# $2 => fileName
# $3 => localFilename
addDataToFile(){
  echo 'if [ $(grep '"EOF_$1 $2"' |wc -l ) -eq 0 ]; then' >> template
  echo "cat >> $2 << EOF_$1" >> template
  echo "<<<$1>>>" >> template
  echo "EOF_$1" >> template
  sed -i -e "/<<<$1>>>/r $3" -e "s/<<<$1>>>//g"  template
  echo "else" >> template
  echo 'echo "Nothing to do"' >> template
  echo "fi" >> template
}
addTestUserAsRoot(){
  echo 'if (whoami != root)' >> template
  echo 'then echo "Please run as root"' >> template
  echo 'exit 1' >> template
  echo 'fi' >> template
}

echo "#!/bin/bash" > template
addTestUserAsRoot
addDataToFile PAT1 "/root/.tmux.conf" tmuxFile
addDataToFile PAT2 "/root/.vimrc" vimrcFile
addDataToFile PAT3 "/root/.bashrc" bashrcFile
addDataToFile PAT4 "/root/.vim/coc-settings.json" coc-settings.json

echo "apt update && apt install git curl make clang libtool-bin python3-dev python3-pip exuberant-ctags python3-venv golang-go ranger -y" >> template
echo "pip3 install jedi && pip3 install console_colors && git clone https://github.com/vim/vim.git" >> template
echo "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" >> template
echo "/bin/bash -c \"cat <(echo 'FORCE'='yes') <(curl -sL install-node.now.sh/lts) |bash\"" >> template
echo "cd vim && ./configure --enable-python3interp && cd src && make && make install" >> template
#COPY vimrcFile /root/.vimrc
echo "/bin/bash -c 'echo \"q\" |vim  +PlugInstall +qall || true'" >> template
echo "npm install --global yarn && cd /root/.vim/plugged/coc.nvim/ && yarn install" >> template
echo "vim -c 'CocInstall -sync coc-json coc-go coc-sh coc-git coc-xml coc-python coc-cmake coc-snippets coc-yaml coc-docker coc-html|q'" >> template
echo "source /root/.bashrc" >> template
echo "/bin/bash -c \"echo 'export GOPATH=$HOME/go' >> /root/.bash_profile\"" >> template
echo "/bin/bash -c \"echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /root/.bash_profile\"" >> template
