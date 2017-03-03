#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NOW=$(date)

ssh-add ${DIR}/secrets/id_rsa

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
