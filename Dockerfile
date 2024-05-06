FROM alpine:latest
RUN apk update && apk add vim ncdu zsh exa
COPY .alias /root/.zshrc
CMD [ "zsh" ]
