# seed/Dockerfile
# Minimal seed image: bundle mailcow nginx templates + web, then seed them into mounted volumes.

FROM alpine:3.20

RUN apk add --no-cache bash coreutils openssl

# Put your prepared assets here in the build context:
#   seed/conf-nginx/...
#   seed/web/...
COPY conf-nginx /seed/conf-nginx
COPY web       /seed/web

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
