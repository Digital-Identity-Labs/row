FROM bitnami/minideb:latest

LABEL description="A base image for Ruby on Rails containers" \
      version="0.0.1" \
      maintainer="pete@digitalidentitylabs.com"

RUN install_packages gcc-6 autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
                     libncurses5-dev libffi-dev libgdbm3 libgdbm-dev openssl ruby-build libssl-dev \
                     libxml2-dev libxslt1-dev apt-transport-https ca-certificates procps net-tools gosu && \
  echo 'install_package "ruby-2.4.2" "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.bz2#08e72d0cbe870ed1317493600fbbad5995ea3af2d0166585e7ecc85d04cc50dc" ldflags_dirs standard verify_openssl' > /usr/share/ruby-build/druby && \
  RUBY_CONFIGURE_OPTS=--disable-install-doc ruby-build druby /opt/ruby && \
  /opt/ruby/bin/gem install rack bundler puma --no-document  && \
  rm -rf /usr/share/ruby-build && dpkg --purge --force-all  ruby-build && \
  adduser app --system --home /opt/app

ENV BUNDLE_PATH=/opt/app/vendor/bundle \
    RUBY_EXTRA_BINSTUBS="" \
    RAILS_ENV=production \
    PUMA_CONTROL_TOKEN=c349f507261c2b \
    PUMA_WORKERS=1

ENV PATH=/opt/app/bin:$BUNDLE_PATH/bin:/opt/ruby/bin:$PATH

EXPOSE 3000 9293

COPY optfs /opt

WORKDIR /opt/app

STOPSIGNAL INT

RUN chmod a+x /opt/admin/*.sh && sync && /opt/admin/prepare_apps.sh

ENTRYPOINT exec gosu app puma -e $RAILS_ENV -p 3000 -w $PUMA_WORKERS --preload --control tcp://0.0.0.0:9293 --control-token $PUMA_CONTROL_TOKEN


