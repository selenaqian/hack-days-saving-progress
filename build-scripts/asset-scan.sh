#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

###############################################################################
# Runs the asset scan tool from https://github.com/SpringRoll/Automated-QA to
# check for
# - files that are too large
# - not allowed
# - invalid
# - etc.
###############################################################################

# Fetch the exit code to use for unstable builds from SSM
ssm_parameter_name="/Prod/SpringRoll/GameBuilder/UnstableReturnCode"
exit_code=$(aws ssm get-parameter --name "$ssm_parameter_name" --with-decryption | jq ".Parameter.Value" | tr -d '"')

# Run the asset scan
npx sras -p deploy/ --config build-config/sras.json -c "$exit_code" || echo "::warning file=asset-scan.sh::Asset scan failed!"
