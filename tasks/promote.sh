#!/usr/bin/env bash

pushd repo/tasks > /dev/null
  found=$(git tag --list | grep ${tag})

  if [ -n "${found}" ] ; then
    git diff ${tag} > changelog.txt
    git push origin :refs/tags/${tag}
  fi

  git tag -fa "${tag}"
  git tag -fa "${tag}-$(date '+%s')"
  git push origin master --tags
popd > /dev/null
