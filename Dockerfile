FROM ubuntu:latest
RUN apt update && apt install git curl make clang libtool-bin python3-dev python3-pip exuberant-ctags python3-venv golang-go ranger -y
RUN pip3 install jedi && pip3 install console_colors && git clone https://github.com/vim/vim.git
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN cd vim && ./configure --enable-python3interp && cd src && make && make install 
RUN curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/template | /bin/bash
RUN /bin/bash -c 'echo "q" |vim +PlugInstall +qall || true'
RUN npm install --global yarn && cd /root/.vim/plugged/coc.nvim/ && yarn install
RUN timeout 2m vim +CocInstall;exit 0
