#!/usr/bin/env bash

set -o errexit

echo "Installing gems..."
bundle install --quiet

echo "Precompiling assets..."
bundle exec rails assets:precompile

echo "Cleaning old assets..."
bundle exec rails assets:clean

echo "Running database migrations..."
bundle exec rails db:migrate
