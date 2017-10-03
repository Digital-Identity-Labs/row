FROM bitnami/minideb:latest

LABEL description="A base image for Ruby on Rails containers" \
      version="0.0.1" \
      maintainer="pete@digitalidentitylabs.com"

RUN install_packages imagemagick libc6-dev libffi6 libgcc1 libgmp-dev libncurses5 libpq5 libreadline7 libsqlite3-dev \
                     libssl1.1 libstdc++6 libtinfo5 libxml2-dev libxslt1-dev zlib1g zlib1g-dev build-essential \
                     apt-transport-https ca-certificates nodejs make gcc git openssl ruby-build libssl-dev libpq-dev  \
                     procps net-tools gosu && \
  echo 'install_package "ruby-2.4.2" "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.bz2#08e72d0cbe870ed1317493600fbbad5995ea3af2d0166585e7ecc85d04cc50dc" ldflags_dirs standard verify_openssl' > /usr/share/ruby-build/druby && \
  RUBY_CONFIGURE_OPTS=--disable-install-doc ruby-build druby /opt/ruby  && \
  /opt/ruby/bin/gem install rack bundler puma --no-document  && \
  rm -rf /usr/share/ruby-build && dpkg --purge --force-all  ruby-build  && \
  dpkg --purge --force-all ruby2.3 ruby-rack libruby2.3 rubygems-integration dirmngr perl git-man perl-modules libldap-common libldap && \
  adduser app --system --home /opt/app

ENV PATH=/opt/app/bin:/opt/ruby/bin:$PATH \
    RAILS_ENV=production \
    PUMA_CONTROL_TOKEN=c349f507261c2b \
    PUMA_WORKERS=1

EXPOSE 3000 9293

COPY optfs /opt

WORKDIR /opt/app

RUN chmod a+x /opt/admin/*.sh && sync && /opt/admin/prepare_apps.sh

ENTRYPOINT gosu app puma -e $RAILS_ENV -p 3000 -w $PUMA_WORKERS --preload --control tcp://0.0.0.0:9293 --control-token $PUMA_CONTROL_TOKEN


