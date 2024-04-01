# Install build dependencies
FROM alpine:latest AS build-base

ENV TZ="America/Chicago"

RUN apk --quiet --no-cache add \
  git \
  build-base \
  clang \
  cmake \
  make \
  zlib-dev \
  curl-dev \
  lua-dev \
  && rm -rf /var/cache/apk/* \
  ;

# Clone pvpgn repository, and build
ARG REPO=https://github.com/pvpgn/pvpgn-server.git
ARG BRANCH=master

RUN git clone --depth 1 --single-branch --branch ${BRANCH} ${REPO} /src
RUN mkdir /src/build /usr/local/pvpgn
WORKDIR /src

RUN cmake -G "Unix Makefiles" -H./ -B./build \
  -D WITH_LUA=true \
  -D CMAKE_INSTALL_PREFIX=/ \
  ../ && cd build && make install && chown -R 1001:1001 /var/pvpgn /etc/pvpgn

############################################################################################ 

# Runner image with dependencies
FROM node:iron-alpine  AS runner
# FROM alpine:latest AS runner

RUN apk --quiet --no-cache add \
  ca-certificates \
  libstdc++ \
  libgcc \
  libcurl \
  lua5.1-libs \
  && rm -rf /var/cache/apk/* \
  ;

# Copy binaries and configurations
COPY --from=build-base \
  /sbin/bnetd \
  /sbin/bntrackd \
  /sbin/d2cs \
  /sbin/d2dbs \
  /sbin/

COPY --from=build-base \
  /bin/bn* \
  /bin/sha1hash \
  /bin/tgainfo \
  /bin/

COPY --from=build-base --chown=1001:1001 /etc/pvpgn /etc/pvpgn 
COPY --from=build-base --chown=1001:1001 /var/pvpgn /var/pvpgn 

# Prepare user
RUN addgroup --gid 1001 pvpgn \
  && adduser \
  --home /usr/local/pvpgn \
  --gecos "" \
  --shell /sbin/nologin \
  --ingroup pvpgn \
  --system \
  --disabled-password \
  --no-create-home \
  --uid 1001 \
  pvpgn

# Expose ports
# EXPOSE 6112 4000 3002
EXPOSE 6112 6112/udp 6200 6200/udp 3002

# Set working directory
RUN mkdir -p /usr/local/pvpgn/web && \
  npm install pm2 -g

#  break the cache hack
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

COPY --chown=root entrypoint.sh /entrypoint.sh

# Copy web files and make sure it builds
COPY web /usr/local/pvpgn/web
RUN chown -R 1001:1001 /usr/local/pvpgn

WORKDIR /usr/local/pvpgn/web
RUN cd /usr/local/pvpgn/web/backend && npm ci && npm run build
RUN cd /usr/local/pvpgn/web/frontend && npm ci && npm run build

# Set user
USER 1001:1001

# Run command
CMD ["/entrypoint.sh"]
ENTRYPOINT ["sh"]