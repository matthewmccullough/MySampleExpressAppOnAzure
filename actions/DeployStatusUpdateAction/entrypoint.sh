#!/bin/sh

set -e

DEPLOYMENT_STATUS_URL=$(jq -r .deployment.statuses_url $GITHUB_EVENT_PATH)
DEPLOYMENT_ENVIRONMENT=$(jq -r .deployment.environment $GITHUB_EVENT_PATH)

DESCRIPTION="Deployed in $DEPLOYMENT_ENVIRONMENT"
TARGET_URL=eval $*

echo "************"
echo $TARGET_URL

JSON_STRING=$( jq -n \
                  --arg desc "$DESCRIPTION" \
                  --arg url "$TARGET_URL" \
                  '{"state": "success", "description": $desc, "environment_url": $url}' )

curl -k -H "Authorization: token $GITHUB_TOKEN" -d "$JSON_STRING" $DEPLOYMENT_STATUS_URL
