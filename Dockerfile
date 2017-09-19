FROM bitnami/minideb:latest

LABEL maintainer="pete@digitalidentitylabs.com"

RUN install_packages gnupg dirmngr && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    install_packages imagemagick libc6-dev libffi6 libgcc1 libgmp-dev libncurses5 libpq5 libreadline7 libsqlite3-dev \
                     libssl1.1 libstdc++6 libtinfo5 libxml2-dev libxslt1-dev zlib1g zlib1g-dev build-essential\
                     apt-transport-https ca-certificates nodejs make gcc git openssl ruby-build libssl-dev gosu && \
  echo deb https://oss-binaries.phusionpassenger.com/apt/passenger stretch main > /etc/apt/sources.list.d/passenger.list && \
  echo 'install_package "ruby-2.4.2" "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.bz2#08e72d0cbe870ed1317493600fbbad5995ea3af2d0166585e7ecc85d04cc50dc" ldflags_dirs standard verify_openssl' > /usr/share/ruby-build/druby && \
  RUBY_CONFIGURE_OPTS=--disable-install-doc ruby-build druby /opt/ruby  && \
  install_packages passenger  &&  \
  /opt/ruby/bin/gem install rack bundler --no-document && \
  rm -rf /usr/share/ruby-build && dpkg --purge --force-all  ruby-build  && \
  dpkg --purge --force-all ruby2.3 ruby-rack libruby2.3 rubygems-integration dirmngr perl git-man perl-modules libldap-common libldap && \
  adduser app --system --home /opt/app

ENV PATH=/opt/ruby/bin:$PATH RAILS_ENV=production

EXPOSE 3000

COPY . /opt/app

WORKDIR /opt/app

ONBUILD COPY . /opt/app
ONBUILD RUN bundle config --global silence_root_warning 1 && bundle install && \
            mkdir -p /opt/app/tmp && chown -R app /opt/app/tmp && chown -R app /opt/app/log && \
            chmod a+w /dev/stdout

#ENTRYPOINT passenger start --user app --no-install-runtime --no-compile-runtime --log-file /proc/self/fd/1 --environment $RAILS_ENV
CMD /bin/sh
