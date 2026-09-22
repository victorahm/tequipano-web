# The Rails team does not publish devcontainer images for Ruby 4.x yet
# (ghcr.io/rails/devcontainer/images/ruby tops out at 3.4), so base on the
# official ruby image. Toolchain extras (mise/node, postgres client, etc.)
# come from the features in devcontainer.json.
# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and mise.toml
ARG RUBY_VERSION=4.0.7
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0" \
    DEBIAN_FRONTEND=noninteractive

# Build toolchain for native gem extensions + the postgres CLI.
# Image processing libs (libvips) come from the activestorage feature.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      postgresql-client \
      sudo \
      tzdata \
    && rm -rf /var/lib/apt/lists/*
