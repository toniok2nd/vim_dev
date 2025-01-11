#!/bin/sh

# Function to check if the system is Alpine
is_alpine() {
    if grep -iq "alpine" /etc/os-release; then
        return 0  # true (Alpine)
    else
        return 1  # false (not Alpine)
    fi
}
# Function to check if the system is Ubuntu
is_ubuntu() {
    if grep -iq "ubuntu" /etc/os-release; then
        return 0  # true (Ubuntu)
    else
        return 1  # false (not Ubuntu)
    fi
}

if is_ubuntu; then

  # Update package list and install necessary packages
  apt update
  apt install -y python3-dev python3-pip build-essential libncurses-dev curl jq git fzf tmux bash golang-go nodejs vim npm xclip

  # Add configuration files
  curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/vimrcFile -o ~/.vimrc
  curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/tmuxFile -o ~/.tmux.conf
  curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/bashFile -o ~/.bashrc

  # Install vim plugin
  /bin/bash -c 'echo \"q\" | vim +PlugInstall +qall || true'

  # Install yarn globally using npm and configure Coc.nvim
  npm install --global yarn && cd /root/.vim/plugged/coc.nvim/ && yarn install

  # Get and install all global coc extensions
  vim -c 'redir > /here | let g:coc_global_extensions | redir END | quitall'
  plugins=$(cat /here | sed -n 's/.*\[\(.*\)\].*/\1/p' | sed 's/,//g' | sed "s/'//g")
  vim -c "CocInstall -sync $plugins | quitall"
  rm /here

fi

if is_alpine; then

  # install package
  apk update
  apk add --no-cache python3-dev
  apk add --no-cache build-base ncurses-dev 
  apk add --no-cache curl jq yq git fzf tmux bash tmux go nodejs vim npm xclip

  # set venv
  python3 -m venv /VENV
  source /VENV/bin/activate

  # Download and install pip using get-pip.py
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
  
  # add configuration
  curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/vimrcFile -o ~/.vimrc
  curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/tmuxFile -o ~/.tmux.conf
  curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/bashFile -o ~/.bashrc

  # install vim plugin
  /bin/bash -c 'echo \"q\" |vim +PlugInstall +qall || true'

  # Install yarn globally using npm and configure Coc.nvim
  npm install --global yarn && cd /root/.vim/plugged/coc.nvim/ && yarn install
  
  # Get and install all global coc extensions
  vim -c 'redir > /here | let g:coc_global_extensions | redir END | quitall'
  plugins=$(cat /here | sed -n 's/.*\[\(.*\)\].*/\1/p' |sed 's/,//g' |sed "s/'//g")
  vim -c "CocInstall -sync $plugins | quitall"
  rm /here

fi
