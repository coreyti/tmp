#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NOW=$(date)

chmod 400 ./secrets/id_rsa
eval $(ssh-agent -s)
ssh-add ./secrets/id_rsa

pushd repo > /dev/null
echo "yes" | git fetch --tags

  found=$(git tag --list | grep ${tag})
  timestamp=$(date '+%s')

  git config --global user.email "coreyti+ci@gmail.com"
  git config --global user.name "Concourse Build"

  if [ -n "${found}" ] ; then
    git push origin :refs/tags/${tag}

    echo "Changes as of ${NOW}"                     >> ${DIR}/CHANGELOG.txt
    echo "----------------------------------------" >> ${DIR}/CHANGELOG.txt
    git log ${tag}...HEAD                           >> ${DIR}/CHANGELOG.txt
  fi

  git tag -fa "${tag}"
  git tag -fa "${tag}-${timestamp}"
  git commit -m "CI Promote at ${timestamp}"
  git push origin master --tags
popd > /dev/null
