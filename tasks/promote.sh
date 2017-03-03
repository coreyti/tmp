#!/usr/bin/env bash

pushd repo/tasks > /dev/null
  found=$(git tag --list | grep ${tag})

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  if [ -n "${found}" ] ; then
    git diff ${tag} > changelog.txt
    git push origin :refs/tags/${tag}
  fi

  git tag -fa "${tag}"
  git tag -fa "${tag}-$(date '+%s')"
  git push origin master --tags
popd > /dev/null
