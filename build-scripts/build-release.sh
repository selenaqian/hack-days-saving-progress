#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

GAME_SLUG=$(cat ./build-config/game.config.json | jq -r '.game_slug')
SSM_PARAM_ENV=$(cat ./build-config/game.config.json | jq -r '.ssm_param_env')
GIT_COMMIT=$(git rev-parse HEAD)

if [ -f "Gruntfile.js" ]
then
  # Gruntfile exists, SpringRoll v1
  grunt --verbose
else
  # no grunt file, SpringRoll v2
  npm run build:release
fi

rm -f release.zip debug.zip
cd deploy
zip -r ../release.zip ./*
cd ../

if [[ $SSM_PARAM_ENV == "Prod" ]]; then
  aws s3 sync ./deploy s3://springroll-dev-binaries/"$GAME_SLUG"/"$GIT_COMMIT"/release
  aws s3 cp ./release.zip s3://springroll-dev-binaries/"$GAME_SLUG"/"$GIT_COMMIT"/release.zip
else
  echo "Skipping file upload as this isn't prod"
fi


# add the release size to the JSON file
{
  echo "\"releaseCompressedSize\": \"$(wc -c release.zip | cut -f1 -d' ')\","
  echo "\"releaseUncompressedSize\": \"$(du -d0 -b deploy/ | cut -f1)\","
} >> new_release.json
