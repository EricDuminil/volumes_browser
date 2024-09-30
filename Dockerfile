FROM alpine:latest
RUN apk update && apk add neovim ncdu zsh exa git
COPY .zshrc /root/
COPY .vimrc /root/.config/nvim/init.vim
COPY .gitconfig /root/
WORKDIR /mnt/
CMD [ "zsh" ]
