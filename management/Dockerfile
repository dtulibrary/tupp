FROM debian:jessie
MAINTAINER docker@dtic.dk

# Create non-root user for running app
RUN useradd -U tupp

# Set up build environment
RUN apt-get -q update && \
    apt-get -yq install --no-install-recommends \
            ruby \
            ruby-dev \
            build-essential \
            bundler \
            git

# Install gem dependencies
COPY management/Gemfile /app/Gemfile
COPY lib /lib
WORKDIR /app
RUN exec bundle install

# Add application files
COPY management/app /app

USER tupp
ENTRYPOINT exec bundle exec ruby /app/app.rb 
