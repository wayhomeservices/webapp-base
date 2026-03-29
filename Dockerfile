FROM ruby:3-slim

# ImageMagick from Debian packages (multi-arch safe under buildx). Slim omits curl/gnupg — add
# explicitly for apt repos.
# Node.js from NodeSource (not Debian's nodejs metapackage): avoids stale node-undici / node-minimatch /
# node-brace-expansion Debian packages that lag npm security fixes.
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN apt-get update -qq && apt-get upgrade -y -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      gnupg \
      git \
      ghostscript \
      imagemagick \
      libmagickwand-dev \
      libyaml-dev \
      pkg-config \
      postgresql-client \
      vim \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@11 \
    && corepack enable \
    && corepack prepare yarn@1.22.22 --activate \
    && rm -rf /var/lib/apt/lists/*

RUN gem update --system && gem install bundler
