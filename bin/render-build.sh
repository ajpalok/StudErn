#!/usr/bin/env bash

set -o errexit

echo "Installing gems..."
# if bundle check is not satisfied, then bundle install
if ! bundle check; then
  echo "Installing missing gems..."
  bundle install --quiet
else
  echo "All gems are already installed."
fi

echo "Installing Foreman..."
gem install foreman

echo "Stimulus controllers..."
bundle exec rake stimulus:manifest:update

echo "Running yarn install..."
yarn install

echo "Precompiling assets..."
bundle exec rake assets:precompile --trace

echo "Cleaning old assets..."
bundle exec rake assets:clean

echo "Running database migrations..."
bundle exec rails db:migrate
