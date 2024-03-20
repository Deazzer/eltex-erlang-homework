# Build stage 0
FROM erlang:21-alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Add git for nksip
RUN apk add --no-cache git build-base

# Copy webrtp application
COPY . webrtp

# And build the release
WORKDIR webrtp

RUN rebar3 as prod release

# Build stage 1
FROM alpine:3.13

# Install some libs
RUN apk add git && \
    apk add make gcc musl-dev && \
    apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++ && \
    apk add --no-cache ffmpeg && \
    apk add --no-cache ortp-dev && \
    apk add --no-cache bctoolbox-dev


COPY --from=0 /buildroot/webrtp/apps/webrtp/priv /webrtp/priv/

COPY --from=0 /buildroot/webrtp/c_src /webrtp/c_src

COPY --from=0 /buildroot/webrtp/_build/prod/rel/webrtp /webrtp

# Compile rtpsend.c
RUN make -C /webrtp/c_src
# Expose relevant ports
EXPOSE 8080

# The command to launch the application in the interactive console mode
CMD ["/webrtp/bin/webrtp", "foreground"]