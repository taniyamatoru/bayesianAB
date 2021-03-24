#!/usr/bin/env bash

TEMPLATE_NAME="keel-application-template"

echo "${TEMPLATE_NAME}を書き換えるためのアプリケーション名を入力してください。"
echo ""

[[ -n "$APPLICATION_NAME" ]]  || read -p "Enter APPLICATION_NAME [e.g. homes-neo]: " APPLICATION_NAME
if [[ ! -n "$APPLICATION_NAME" ]]; then
  echo "正しいアプリケーション名を入力してください。" 1>&2
  exit 1
fi

ENTRYPOINT=$(cd $(dirname $BASH_SOURCE[0]); pwd)/..

files=($(find ${ENTRYPOINT} -type f -name rewrite-template-name.sh -prune -o -type d -name '.git' -prune -o -type f -print))
for file in "${files[@]}"; do
  sed -ri 's/'${TEMPLATE_NAME}'/'${APPLICATION_NAME}'/' ${file}
  filename=$(basename ${file})
  if [[ "${filename}" = "${TEMPLATE_NAME}" ]]; then
    dest="$(dirname ${file})/$(echo ${filename} | sed 's/'${TEMPLATE_NAME}'/'${APPLICATION_NAME}'/')"
    if [[ -e "$dest" ]]; then
      echo "${dest}: 書き換え先のファイルが既に存在します。" 1>&2
      exit 1
    fi
    mv ${file} ${dest}
  fi
done

directories=($(find ${ENTRYPOINT} -type d -name '.git' -prune -o -type d -print))
for directory in "${directories[@]}"; do
  dirname=$(basename ${directory})
  if [[ "${dirname}" = "${TEMPLATE_NAME}" ]]; then
    # I don't know why, but there are cases mv doesn't work.
    dest="$(dirname ${directory})/$(echo ${dirname} | sed 's/'${TEMPLATE_NAME}'/'${APPLICATION_NAME}'/')"
    if [[ -e "$dest" ]]; then
      echo "${dest}: 書き換え先のディレクトリが既に存在します。" 1>&2
      exit 1
    fi
    cp -r ${directory} ${dest}
    rm -rf ${directory}
  fi
done

echo ""
echo "${TEMPLATE_NAME}という名前を持つファイルとディレクトリを${APPLICATION_NAME}に変更し、ファイル内に存在する${TEMPLATE_NAME}という文字列もすべて${APPLICATION_NAME}に書き換えました。"
echo "変更内容を \`git add . && git commit\` して保存してください"
