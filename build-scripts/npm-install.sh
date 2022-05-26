#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'

node --version
npm --version
grunt --version

rm -rf node_modules

npm config set unsafe-perm true && \
npm install -g grunt git+https://github.com/SpringRoll/Automated-QA#1.0.1 && \
npm config set unsafe-perm false && \

if [[ -f "package-lock.json" ]]; then
  # package-lock.json exists
  npm ci --verbose
else
  npm install --verbose
fi

rm -rf components

rm -rf new_release.json

# create the opening brace for the release JSON file
echo "{" > new_release.json
