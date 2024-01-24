# Stage 2: Create the final image
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add \
                    tmux \
                    py3-pip \
                    curl \
                    git \
                    bash \
                    vim

# Install additional dependencies for coc.vim
RUN apk --no-cache add \
                    nodejs \
                    npm \
                    yarn

# Install vim-plug for plugin management
RUN mkdir -p ~/.vim/autoload ~/.vim/plugged \
    && wget -O ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy conf files 
COPY vimrcFile /root/.vimrc
COPY tmuxFile /root/.tmux.conf
COPY requirements.txt /

# Install coc.vim plugins
RUN vim +PlugInstall +qall

# Install dependencies, including yarn
RUN vim -c 'CocInstall -sync coc-json coc-jedi coc-marketplace coc-sh coc-explorer coc-css coc-snippets coc-yaml coc-html coc-git |q'

# Install jedi ls 
RUN python3 -m venv /root/.config/coc/extensions/node_modules/coc-jedi/.venv
RUN /root/.config/coc/extensions/node_modules/coc-jedi/.venv/bin/pip3 install jedi-language-server==0.41.1

RUN /root/.config/coc/extensions/node_modules/coc-jedi/.venv/bin/pip3 install -r requirements.txt

# install python3 lib
RUN pip3 install -r requirements.txt

# Run Vim when the container starts
CMD ["vim"]

