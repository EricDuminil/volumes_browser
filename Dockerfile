FROM alpine:latest
RUN apk update && apk add vim ncdu zsh exa git
# Add vimrc?
# Add gitconfig?
COPY .alias /root/.zshrc
WORKDIR /mnt/
CMD [ "zsh" ]
