#!/usr/bin/env bash

set -o errexit

# set environment variables
export RAILS_ENV=production

bundle install
bin/rails assets:precompile
bin/rails assets:clean

bin/rails db:migrate
bin/rails tailwindcss:build