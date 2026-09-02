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
                    nodejs \
                    npm \
                    nano \
                    yarn \
                    openssl \
                    tzdata \
                    fzf \
                    jq && \
                    # Neovim standard paths
                    mkdir -p ~/.local/share/nvim/site/autoload ~/.config/nvim

# 0. Install vim-plug
RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 1. install neovim
RUN curl -fsSL https://cocnvim.com/install-coc.sh | bash -s -- --editor=nvim

# 2. Copy conf files (Assumes you renamed 'vimrcFile' to 'init.lua' on your host)
COPY nvimInit /root/.config/nvim/init.lua
COPY tmuxFile /root/.tmux.conf
COPY requirements.txt /

# 3. Install coc.nvim plugins
RUN nvim --headless +PlugInstall +qall && \
    nvim --headless -c "CocInstall -sync coc-json coc-pyright coc-css coc-cssmodules coc-marketplace coc-git coc-sh coc-jedi coc-snippets coc-yaml coc-html coc-explorer" -c "qa"

# 4. Create a dedicated venv and install jedi-language-server during the BUILD step
RUN python3 -m venv /opt/jedi-venv && \
    /opt/jedi-venv/bin/pip3 install -U pip && \
    /opt/jedi-venv/bin/pip3 install jedi-language-server==0.41.1

# 5. Tell coc-jedi to use this specific installation so it doesn't try to download it again
RUN mkdir -p /root/.config/nvim && \
    echo '{"jedi.executable.command": "/opt/jedi-venv/bin/jedi-language-server"}' > /root/.config/nvim/coc-settings.json

# 6. Set config for coc
COPY cocSettings /root/.config/nvim/coc-settings.json

# 7. Venv install 
python3 -m venv /opt/VENV
/opt/VENV/bin/pip3 install -r requirements.txt
