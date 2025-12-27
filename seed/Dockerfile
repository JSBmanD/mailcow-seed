FROM alpine:3.22

RUN apk add --no-cache bash git rsync openssl coreutils

# Pull mailcow repo at build-time and stash required static assets
RUN git clone --depth 1 https://github.com/mailcow/mailcow-dockerized.git /src \
 && mkdir -p /seed/data/conf /seed/data/assets /seed/data \
 && cp -a /src/data/conf/nginx /seed/data/conf/nginx \
 && cp -a /src/data/web /seed/data/web \
 && rm -rf /src

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
