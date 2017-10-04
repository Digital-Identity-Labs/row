#!/usr/bin/env bash

## Fail unless all env variables are set
set -u

## Carry out all steps as one command, to return a failure code if something goes wrong
chmod a+x /opt/admin/*.sh && \
mkdir -p /opt/app/bin && \
mkdir -p $BUNDLE_PATH && \
mkdir -p /opt/app/vendor/cache && \
mkdir -p /opt/app/tmp && chown -R app /opt/app/tmp && \
mkdir -p /opt/app/log && chown -R app /opt/app/log && \
bundle config --global silence_root_warning 1 && \
bundle install && bundle binstubs --force puma $RUBY_EXTRA_BINSTUBS && \
sync
