#!/usr/bin/env bash

NOW=$(date)
BASE_DIR=$(pwd)
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

eval $(ssh-agent -s)
chmod 400 ./secrets/id_rsa
ssh-add ./secrets/id_rsa
cat "${BASE_DIR}/secrets/known_hosts" >> ~/.ssh/known_hosts

pushd repo > /dev/null
  git fetch --tags

  found=$(git tag --list | grep ${tag})
  timestamp=$(date '+%s')

  git config --global user.email "coreyti+ci@gmail.com"
  git config --global user.name "Concourse Build"

  if [ -n "${found}" ] ; then
    git push origin :refs/tags/${tag}

    echo "Changes as of ${NOW}"                     >> ${REPO_DIR}/CHANGELOG.txt
    echo "----------------------------------------" >> ${REPO_DIR}/CHANGELOG.txt
    git log ${tag}...HEAD                           >> ${REPO_DIR}/CHANGELOG.txt
  fi

  git tag -fa "${tag}"
  git tag -fa "${tag}-${timestamp}"
  git commit -m "CI Promote at ${timestamp}"
  git push origin master --tags
popd > /dev/null
