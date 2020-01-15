FROM alpine:latest as builder
RUN apk add --update --no-cache --force-overwrite \
               crystal shards openssl-libs-static openssl-dev g++ gc-dev \
               libc-dev libevent-dev libevent-static libxml2-dev llvm llvm-dev \
               llvm-static make pcre-dev readline-dev readline-static \
               yaml-dev zlib-dev zlib-static ca-certificates xz-dev \
               pkgconf sqlite-dev libexif-dev
WORKDIR /src
COPY ./src ./src
COPY ./lib ./lib

RUN crystal build --release ./src/indexer.cr -o /tmp/ncotd-indexer
RUN crystal build --release ./src/web.cr -o /tmp/ncotd-web

FROM alpine
RUN apk add --update --no-cache tzdata ca-certificates pcre libevent libgcc sqlite-dev libexif

WORKDIR /app
COPY --from=builder /tmp/ncotd-indexer /app/ncotd-indexer
COPY --from=builder /tmp/ncotd-web /app/ncotd-web
COPY db /app/db
COPY public /app/public

ENTRYPOINT ["/app/ncotd-web"]
