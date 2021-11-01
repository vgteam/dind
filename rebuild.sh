#!/usr/bin/env bash
# rebuild.sh: run periodically to make Quay rebuild the image.
set -ex
git fetch git@github.com:vgteam/dind.git master
git checkout FETCH_HEAD
git branch -D quay-rebuild || true
git checkout -b quay-rebuild
date > dind-build-timestamp.txt
git add dind-build-timestamp.txt
git commit -m "Update build timestamp to $(cat dind-build-timestamp.txt)"
git push git@github.com:vgteam/dind.git quay-rebuild:master


