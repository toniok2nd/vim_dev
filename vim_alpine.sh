#!/bin/sh

# Function to check if the system is Alpine
is_alpine() {
    if grep -iq "alpine" /etc/os-release; then
        return 0  # true (Alpine)
    else
        return 1  # false (not Alpine)
    fi
}

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
  npm install --global yarn && cd /root/.vim/plugged/coc.nvim/ && yarn install
  vim -c 'redir > /here | let g:coc_global_extensions | redir END | quitall'
  plugins=$(cat /here | sed -n 's/.*\[\(.*\)\].*/\1/p' |sed 's/,//g' |sed "s/\'//g")
  vim -c "CocInstall -sync $plugins | quitall"
  rm /here
  # vim -c 'CocInstall -sync coc-json coc-jedi coc-marketplace coc-sh coc-explorer coc-css coc-snippets coc-yaml coc-html coc-git |q'
fi
