FROM node:10.12.0-alpine

RUN apk add --update git && \
    npm i -g hexo-cli

WORKDIR /web
