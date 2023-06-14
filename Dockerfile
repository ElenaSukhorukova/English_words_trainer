ARG RUBY_VERSION=3.2.2
ARG DISTRO_NAME=bullseye

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME

ARG DISTRO_NAME
ARG RUBY_VERSION

LABEL maintainer="https://www.linkedin.com/in/elenasukhorukova/"

# Common dependencies
RUN echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache; \
  apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential apt-transport-https  gnupg2 curl wget less nano

ARG NODE_MAJOR=18

RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash - && \
  apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends nodejs

ARG PG_MAJOR=15
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    gpg --dearmor -o /usr/share/keyrings/postgres-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/postgres-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt/" \
    $DISTRO_NAME-pgdg main $PG_MAJOR | tee /etc/apt/sources.list.d/postgres.list > /dev/null
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    libpq-dev \
    postgresql-client-$PG_MAJOR

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
# COPY package.json ./

ENV BUNDLE_APP_CONFIG=.bundle

COPY . /app

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
    
RUN gem update --system && \
    gem install bundler

RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]