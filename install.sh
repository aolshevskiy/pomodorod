#!/bin/bash
set -e
cd $(dirname $0)

DESTDIR=~/opt/pomodorod

rsync -av --delete ./ $DESTDIR

cd $DESTDIR
bundle config set --local path vendor/bundle
bundle config set --local without development
bundle install
