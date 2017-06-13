FROM bitnami/minideb:latest

LABEL maintainer "pete@digitalidentitylabs.com"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7

RUN install_packages imagemagick libc6 libffi6 libgcc1 libgmp-dev libncurses5 libpq5 libreadline6 libsqlite3-dev \
                     libssl1.0.0 libssl1.0.0 libstdc++6 libtinfo5 libxml2-dev libxslt1-dev zlib1g zlib1g-dev \
                     apt-transport-https ca-certificates nodejs make gcc git openssl ruby-build libssl-dev  && \
  echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main > /etc/apt/sources.list.d/passenger.list && \
  echo 'install_package "ruby-2.4.1" "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.bz2#ccfb2d0a61e2a9c374d51e099b0d833b09241ee78fc17e1fe38e3b282160237c" ldflags_dirs standard verify_openssl' > /usr/share/ruby-build/druby && \
  RUBY_CONFIGURE_OPTS=--disable-install-doc ruby-build druby /opt/ruby  && \
  install_packages passenger  &&  \
  /opt/ruby/bin/gem install rack bundler --no-document && \
  rm -rfv /usr/share/ruby-build && dpkg --purge --force-all  ruby-build  && \
  dpkg --purge --force-all ruby2.1 ruby-rack libruby2.1 rubygems-integration && \
  adduser app --system --home /opt/app

ENV PATH=/opt/ruby/bin:$PATH RAILS_ENV=production

EXPOSE 3000

COPY . /opt/app

WORKDIR /opt/app

ONBUILD COPY . /opt/app
ONBUILD RUN bundle config --global silence_root_warning 1 && bundle install && \
            mkdir -p /opt/app/tmp && chown -R app /opt/app/tmp && chown -R app /opt/app/log

ENTRYPOINT passenger start --user app  --no-install-runtime --no-compile-runtime --log-file /dev/stdout --environment $RAILS_ENV
