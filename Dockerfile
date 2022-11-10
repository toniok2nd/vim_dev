FROM ubuntu:latest
RUN apt update && apt install git curl make clang libtool-bin python3-dev python3-pip exuberant-ctags python3-venv golang-go -y
RUN pip3 install jedi && git clone https://github.com/vim/vim.git
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN /bin/bash -c 'cat <(echo "FORCE=\"yes\"") <(curl -sL install-node.now.sh/lts) |bash'
RUN cd vim && ./configure --enable-python3interp && cd src && make && make install 
COPY vimrcFile /root/.vimrc
COPY bashrcFile /tmp
RUN /bin/bash -c 'cat /root/.bashrc /tmp/bashrcFile > /tmp/tmpbashrc && mv /tmp/tmpbashrc /root/.bashrc'
COPY coc-settings.json /root/.vim/
RUN /bin/bash -c 'echo "q" |vim  +PlugInstall +qall || true'
RUN cd /root/.vim/plugged/coc.nvim/ && npm install
RUN /bin/bash -c "vim +'CocInstall -sync coc-css' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-json' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-yaml' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-python' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-git' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-docker' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-cmake' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-xml' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-go' +qall"
RUN /bin/bash -c "vim +'CocInstall -sync coc-sh' +qall"
RUN /bin/bash -c "echo 'export GOPATH=$HOME/go' >> /root/.bash_profile"
RUN /bin/bash -c "echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /root/.bash_profile"

