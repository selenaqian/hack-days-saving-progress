#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

GAME_SLUG=$(cat ./build-config/game.config.json | jq -r '.game_slug')
SSM_PARAM_ENV=$(cat ./build-config/game.config.json | jq -r '.ssm_param_env')
GIT_BRANCH=$(git branch --show-current)
GIT_COMMIT=$(git rev-parse HEAD)

GIT_MSG=$(git log --format=%B -n 1)
SPRINGROLL_URL_PARAMETER_PATH="/$SSM_PARAM_ENV/SpringRoll/GameBuilder/SpringrollUrl"
SPRINGROLL_URL=$(aws ssm get-parameter --name "$SPRINGROLL_URL_PARAMETER_PATH" --with-decryption | jq -r '.Parameter.Value')
echo $SPRINGROLL_URL
URL="https://$SPRINGROLL_URL/api/release/$GAME_SLUG"
HEADERS="Content-Type: application/json"
SPRINGROLL_TOKEN_PARAMETER_PATH="/$SSM_PARAM_ENV/SpringRoll/GameBuilder/SpringrollToken"
SPRINGROLL_TOKEN=$(aws ssm get-parameter --with-decryption --name "$SPRINGROLL_TOKEN_PARAMETER_PATH" | jq -r '.Parameter.Value')

rm -f msg_dirty msg_cleaner msg_clean
echo "$GIT_MSG" >> msg_dirty
tr '\n' ' ' < msg_dirty > msg_cleaner
tr '\"' '%' < msg_cleaner > msg_clean
GIT_MSG=$(cat msg_clean)

# Trims the origin off of the $GIT_BRANCH variable. For instance
# If $GIT_BRANCH is "origin/my/branch/name"
# Then $GIT_LOCAL_BRANCH will be "my/branch/name"
GIT_LOCAL_BRANCH=$(echo "$GIT_BRANCH" | cut -d '/' -f2-)

# add the final values onto the new release
{
    echo "\"token\": \"$SPRINGROLL_TOKEN\","
    echo "\"status\": \"dev\","
    echo "\"commitId\": \"$GIT_COMMIT\","
    echo "\"notes\": \"Branch: $GIT_LOCAL_BRANCH $GIT_MSG\""
    # add the closing brace
    echo "}"
} >> new_release.json

PAYLOAD=$(tr -d '\n' < new_release.json)

curl -H "$HEADERS" -X POST --data "$PAYLOAD" --fail "$URL"
