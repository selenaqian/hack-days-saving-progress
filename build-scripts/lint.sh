#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'

# If there's no src directory in this project, skip linting for now, but let us know in the logs
if [ ! -d "./src" ]; then
    echo "No src directory found, skipping lint"
    exit 0
fi

# install some dependencies locally. I couldn't get this to work globally unfortunately
npm i eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser typescript

# Run lint over all JavaScript and TypeScript files, failing with exit code 3 if something went wrong.
npx eslint -c build-config/eslint.json "$(find src -name "*.js" -or -name "*.ts")" || echo "::warning file=lint.sh::Lint failed!"
