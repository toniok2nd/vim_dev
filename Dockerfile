FROM ubuntu:latest
RUN apt update && apt install -y curl 
RUN curl  https://raw.githubusercontent.com/toniok2nd/vim_dev/master/template | /bin/bash
RUN timeout 2m vim +CocInstall;exit 0
