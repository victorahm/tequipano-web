# The Rails team does not publish devcontainer images for Ruby 4.x yet
# (ghcr.io/rails/devcontainer/images/ruby tops out at 3.4), so base on the
# official ruby image (full variant: comes with the build toolchain). Keep the
# slim image for production (Dockerfile at the repo root). Toolchain extras
# (postgres client, libvips, node/mise) come from the features in devcontainer.json.
# Make sure RUBY_VERSION matches the ruby version in .ruby-version and mise.toml
ARG RUBY_VERSION=4.0.10
FROM docker.io/library/ruby:$RUBY_VERSION

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0" \
    DEBIAN_FRONTEND=noninteractive

# sudo for the devcontainer user (needed to install apt packages ad hoc).
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      sudo \
      tzdata \
    && rm -rf /var/lib/apt/lists/*

# Non-root user matching the host user (uid 1000), so bind-mounted repo
# files stay writable. devcontainer.json sets remoteUser to this user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME
