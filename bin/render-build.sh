#!/usr/bin/env bash

set -o errexit

bundle install --quiet
bundle exec rake assets:precompile
bundle exec rake assets:clean

bin/rails db:migrate