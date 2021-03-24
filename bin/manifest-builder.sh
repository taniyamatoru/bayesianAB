#!/usr/bin/env bash

echo "このスクリプトはV1ClusterBootstrapに依存し、V1ClusterBootstrap内のmanifest-builderを実行します"
echo "application.yamlのパスと出力パス（指定がない場合は標準出力）によりmanifest-builderを実行します"
echo ""

DEFAULT_MANIFEST_PATH=manifests/application.yaml
DEFAULT_OUTPUT_PATH=.

ENV_FILE_DIRECTORY=${XDG_CONFIG_HOME:-~/.config/$GITHUB_REPO_NAME}
ENV_FILE_PATH=$ENV_FILE_DIRECTORY/manifest-builder-env.sh

[ -e $ENV_FILE_PATH ] && . $ENV_FILE_PATH

read -e -i ${MANIFEST_PATH:-$DEFAULT_MANIFEST_PATH} -p "Enter MANIFEST_PATH: " MANIFEST_PATH
read -e -i ${OUTPUT_PATH:-$DEFAULT_OUTPUT_PATH} -p "Enter OUTPUT_PATH: " OUTPUT_PATH
read -e -i "$V1CLUSTER_REPO" -p "Enter V1CLUSTER_REPO(optional): " V1CLUSTER_REPO
[ -n "$V1CLUSTER_REPO" ] || read -e -i "$GITHUB_TOKEN" -p "Enter GITHUB_TOKEN: " GITHUB_TOKEN

mkdir -p $(dirname $ENV_FILE_PATH)
cat <<EOS > $ENV_FILE_PATH
export MANIFEST_PATH=$MANIFEST_PATH
export OUTPUT_PATH=$OUTPUT_PATH
export V1CLUSTER_REPO=$V1CLUSTER_REPO
export GITHUB_TOKEN=$GITHUB_TOKEN
EOS

args=( --manifest-path $MANIFEST_PATH --output-path $OUTPUT_PATH )
[ "x$V1CLUSTER_REPO" = x ] || args+=( --v1clusterbootstrap-repo-path $V1CLUSTER_REPO )
[ "x$GITHUB_TOKEN"   = x ] || args+=( --token $GITHUB_TOKEN )

keelctl manifest-builder ${args[@]}

success=$?
if [ "$success" -eq 0 ]; then
  echo ""
  echo "作成完了"
  echo ""
  echo "tips."
  echo "  KEELではdeliveryパイプラインを提供しており、通常manifest-builderによりビルドされたmanifestsをdeliveryに利用します"
  echo "  デプロイはGitOpsを想定しており各アプリケーションへのPRを必要としますが、以下のコマンドにより生成後のmanifestsを事前に確認することが出来ます"
  echo ""
  echo "  ex. kubectl kustomize manifests/overlays/current"
fi
