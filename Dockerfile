# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.3.2
ARG NODE_VERSION=20

FROM ruby:${RUBY_VERSION}-slim AS build
ARG NODE_VERSION=20
ENV LANG=C.UTF-8 TZ=Asia/Tokyo BUNDLE_JOBS=4 BUNDLE_RETRY=3
WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential git pkg-config \
      libpq-dev \
      ca-certificates curl gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends nodejs && \
    corepack enable && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN corepack enable && yarn install --frozen-lockfile

COPY . .
RUN yarn build:css && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

FROM ruby:${RUBY_VERSION}-slim AS runtime
ENV LANG=C.UTF-8 TZ=Asia/Tokyo
WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      libpq5 postgresql-client curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

COPY bin/docker-entrypoint /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://localhost:3000/up || exit 1

ENTRYPOINT ["docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
