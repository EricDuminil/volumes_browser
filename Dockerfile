FROM alpine:latest
RUN apk update && apk add vim ncdu zsh exa git
COPY .alias /root/.zshrc
WORKDIR /mnt/
CMD [ "zsh" ]
