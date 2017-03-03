#!/usr/bin/env bash
set -euo pipefail

apt-get -y update
apt-get -y install vim-tiny
EDITOR=vim.tiny

BASE_DIR=$(pwd)
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

eval $(ssh-agent -s)
chmod 400 ./secrets/id_rsa
ssh-add ./secrets/id_rsa
mkdir -p ~/.ssh/
cat "${BASE_DIR}/secrets/known_hosts" >> ~/.ssh/known_hosts

pushd repo > /dev/null
  git fetch --tags

  found=$(git tag --list ${tag})
  datestamp=$(date)
  timestamp=$(date '+%s')

  git config --global user.email "coreyti+ci@gmail.com"
  git config --global user.name "Concourse Build"

  echo "Changes as of ${datestamp}"               >> ${REPO_DIR}/CHANGELOG.txt
  echo "----------------------------------------" >> ${REPO_DIR}/CHANGELOG.txt

  if [ -n "${found}" ] ; then
    git push origin :refs/tags/${tag}
    git log ${tag}...HEAD >> ${REPO_DIR}/CHANGELOG.txt
  else
    git log $(git rev-list --max-parents=0 HEAD)...HEAD \
      >> ${REPO_DIR}/CHANGELOG.txt
  fi


  git add .
  git tag -f "${tag}"
  git tag -f "${tag}-${timestamp}"
  git commit -m "CI Promote at ${datestamp}"
  git push origin HEAD:master --tags
popd > /dev/null
