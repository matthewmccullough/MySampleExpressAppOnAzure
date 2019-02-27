#!/bin/sh

set -e

DEPLOYMENT_STATUS_URL=$(jq -r .deployment.statuses_url $GITHUB_EVENT_PATH)
DEPLOYMENT_ENVIRONMENT=$(jq -r .deployment.environment $GITHUB_EVENT_PATH)

DESCRIPTION="Deployed in $DEPLOYMENT_ENVIRONMENT"
TARGET_URL=$(eval $*)

JSON_STRING=$( jq -n \
                  --arg desc "$DESCRIPTION" \
                  --arg url "$TARGET_URL" \
                  '{"state": "success", "description": $desc, "environment_url": $url}' )

curl -k -H "Authorization: token $GITHUB_TOKEN" -H "accept: application/vnd.github.ant-man-preview+json,application/vnd.github.flash-preview+json" -d "$JSON_STRING" $DEPLOYMENT_STATUS_URL
