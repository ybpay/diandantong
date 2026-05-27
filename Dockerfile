# syntax=docker/dockerfile:1
# Phase 10: Rails 8.1 + Ruby 4.0 upgrade for diandantong (点单通) restaurant SaaS
# Multi-stage build with Ruby 4.0.5 + PostgreSQL 18 + Propshaft

# ===== Stage 1: Build dependencies =====
FROM ruby:4.0.5-slim AS build

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      build-essential \
      git \
      libpq-dev \
      libvips-dev \
      libxml2-dev \
      libxslt1-dev \
      pkg-config \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /rails

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development:test
ENV BUNDLE_DEPLOYMENT=1

# Copy gemspecs first for better Docker layer caching
COPY Gemfile Gemfile.lock DIANDANTONG_VERSION ./
COPY _core/ddt_core.gemspec ./_core/
COPY _backend/ddt_backend.gemspec ./_backend/
COPY _weixin/ddt_weixin.gemspec ./_weixin/
COPY _agentsys/ddt_agent.gemspec ./_agentsys/
COPY _webpos/ddt_webpos.gemspec ./_webpos/
COPY _oauth_api/ddt_oauth.gemspec ./_oauth_api/
COPY _common_api/ddt_common_api.gemspec ./_common_api/
COPY _inner_api/ddt_inner_api.gemspec ./_inner_api/

RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ /usr/local/bundle/cache/*.gem /usr/local/bundle/bundler/gems/*/.git

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompiling assets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ===== Stage 2: Production runtime =====
FROM ruby:4.0.5-slim

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      curl \
      libpq5 \
      libvips \
      libxml2 \
      libxslt1.1 \
      fonts-wqy-zenhei \
      postgresql-client \
      netcat-openbsd \
      tzdata && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    useradd -m -s /bin/bash app

WORKDIR /rails

ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_ROOT=/rails \
    TZ=Asia/Shanghai \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

COPY --from=build --chown=app:app /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=app:app /rails /rails

RUN mkdir -p tmp/pids log public/uploads

USER app

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
