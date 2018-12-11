FROM node:10.12.0-alpine

RUN apk add --update --no-cache git tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone && \
    npm i -g hexo-cli

WORKDIR /web
