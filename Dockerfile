# Phase 5: Rails 8.1 + Ruby 4.0 upgrade for diandantong (点单通) restaurant SaaS
# Multi-stage build with Ruby 4.0 + PostgreSQL 18 + Propshaft

# ===== Stage 1: Build dependencies =====
FROM ruby:4.0-slim AS builder

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libmagickwand-dev \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
COPY DIANDANTONG_VERSION .

# Copy engine gemspecs and source for local path dependencies
COPY _core/ _core/
COPY _backend/ _backend/
COPY _weixin/ _weixin/
COPY _agentsys/ _agentsys/
COPY _webpos/ _webpos/
COPY _oauth_api/ _oauth_api/
COPY _common_api/ _common_api/
COPY _inner_api/ _inner_api/

RUN bundle install --jobs 4 --retry 3 --without development test && \
    rm -rf /usr/local/bundle/cache/*.gem

# ===== Stage 2: Runtime =====
FROM ruby:4.0-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq5 \
    libxml2 \
    libxslt1.1 \
    libmagickwand-6.q16-6 \
    nodejs \
    imagemagick \
    fonts-wqy-zenhei \
    tzdata \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_ROOT=/app \
    TZ=Asia/Shanghai \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/usr/local/bundle

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . .

RUN mkdir -p tmp/pids log public/uploads

EXPOSE 9000

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
