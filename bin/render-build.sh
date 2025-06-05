#!/usr/bin/env bash

set -o errexit

echo "Installing gems..."
bundle install --quiet

echo "Stimulus controllers..."
bin/rails stimulus:manifest:update

echo "Precompiling assets..."
bin/rails assets:precompile

echo "Cleaning old assets..."
bin/rails assets:clean

echo "Running database migrations..."
bin/rails db:migrate
