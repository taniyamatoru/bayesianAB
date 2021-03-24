#!/usr/bin/env bash

GITHUB_REPO_NAME=keel-application-template
DEFAULT_STAGE=production
DEFAULT_GITHUB_BRANCH=master
DEFAULT_SLACK_WORKSPACE_ID=T2N7WFETS

ENV_FILE_DIRECTORY=${XDG_CONFIG_HOME:-~/.config/$GITHUB_REPO_NAME}
ENV_FILE_PATH=$ENV_FILE_DIRECTORY/create-cfn-stack-env.sh

[ -e $ENV_FILE_PATH ] && . $ENV_FILE_PATH

read -e -i ${STAGE:-$DEFAULT_STAGE} -p "Enter STAGE: " STAGE
read -e -i ${GITHUB_BRANCH:-$DEFAULT_GITHUB_BRANCH} -p "Enter GITHUB_BRANCH: " GITHUB_BRANCH
read -e -i "$GITHUB_TOKEN" -p "Enter GITHUB_TOKEN: " GITHUB_TOKEN
read -e -i ${SLACK_WORKSPACE_ID:-$DEFAULT_SLACK_WORKSPACE_ID} -p "Enter SLACK_WORKSPACE_ID: " SLACK_WORKSPACE_ID
read -e -i "$SLACK_CHANNEL_ID" -p "Enter SLACK_CHANNEL_ID: " SLACK_CHANNEL_ID

mkdir -p $(dirname $ENV_FILE_PATH)
cat <<EOS > $ENV_FILE_PATH
export STAGE=$STAGE
export GITHUB_BRANCH=$GITHUB_BRANCH
export GITHUB_TOKEN=$GITHUB_TOKEN
export SLACK_WORKSPACE_ID=$SLACK_WORKSPACE_ID
export SLACK_CHANNEL_ID=$SLACK_CHANNEL_ID
EOS

aws cloudformation deploy \
  --template-file templates/delivery.yaml \
  --stack-name keel-application-template-${STAGE} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      GitHubRepoName=${GITHUB_REPO_NAME} \
      GitHubBranch=${GITHUB_BRANCH} \
      GitHubToken=${GITHUB_TOKEN} \
      SlackWorkspaceId=${SLACK_WORKSPACE_ID} \
      SlackChannelId=${SLACK_CHANNEL_ID} \
      Stage=${STAGE} \
      CacheVersion=$(date +%Y%m%d%H%M)
