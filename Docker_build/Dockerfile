FROM alpine:latest
LABEL maintainer="MAINTAINER toniok"
LABEL version="0.0.1"

# Install runtime dependencies and neovim
RUN apk --no-cache add \
                    tmux \
                    py3-pip \
                    curl \
                    git \
                    bash \
                    neovim \
                    neovim-doc \
                    nodejs \
                    npm \
                    nano \
                    openssl \
                    tzdata \
                    fzf \
                    wayland \
                    jq && \
                    # Neovim standard paths
                    mkdir -p ~/.local/share/nvim/site/autoload ~/.config/nvim

# 0. Copy conf files (Assumes you renamed 'vimrcFile' to 'init.lua' on your host)
COPY nvimInit /root/.config/nvim/init.lua
COPY tmuxFile /root/.tmux.conf
COPY cocSettings /root/.config/nvim/coc-settings.json
COPY requirements.txt /

# 1. Install vim-plug
RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 2. install coc
RUN curl -fsSL https://cocnvim.com/install-coc.sh | bash -s -- --editor=nvim --yes --no-config

# 3. Install coc.nvim plugins
RUN nvim --headless +PlugInstall +qall
WORKDIR /root/.config/coc/extensions/
RUN npm install coc-json coc-css coc-cssmodules coc-marketplace coc-git coc-sh coc-jedi coc-snippets coc-yaml coc-html coc-explorer

# 4. Create a dedicated venv and install jedi-language-server during the BUILD step
WORKDIR /opt/
RUN python3 -m venv /root/.local/share/nvim/.jedi-venv && \
    /root/.local/share/nvim/.jedi-venv/bin/pip3 install -U pip && \
    /root/.local/share/nvim/.jedi-venv/bin/pip3 install 'jedi-language-server>=0.41.1'

# 5. Venv install 
RUN python3 -m venv /opt/VENV && \
   /opt/VENV/bin/pip3 install -r /requirements.txt

# 6. Bashrc var
COPY bashrc /tmp/.bashrc
RUN cat /tmp/.bashrc >> /root/.bashrc && cp /tmp/.bashrc /root/.profile && rm /tmp/.bashrc
