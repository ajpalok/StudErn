#!/usr/bin/env bash

set -o errexit

echo "bundle install"
bundle install --quiet
bin/rails assets:precompile
bin/rails assets:clean

bin/rails db:migrate