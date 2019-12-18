#!/bin/bash
set -e
cd $(dirname $0)

DESTDIR=~/opt/pomodorod

rsync -av --delete ./ $DESTDIR

cd $DESTDIR
bundle config --local path bundle
bundle install --standalone --without development
