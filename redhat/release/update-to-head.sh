#!/usr/bin/env bash

# Copyright 2023 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The local git repo must have a remote "upstream" pointing
# to upstream sigstore/fulcio, and a remote "origin"
# pointing to securesign/fulcio

# Synchs the release-next branch to master and then triggers CI
# Usage: update-to-head.sh

if [ "$#" -ne 1 ]; then
    upstream_ref="master"
    midstream_ref="master"
    redhat_ref="release-next"
else
    upstream_ref=$1
    midstream_ref="midstream-${upstream_ref}" # The overlays and patches for the given version
    redhat_ref="redhat-${upstream_ref}" # The midstream repo with overlays and patches applied
fi

echo "Synchronizing ${redhat_ref} to upstream/${upstream_ref}..."

set -e
REPO_NAME=$(basename $(git rev-parse --show-toplevel))

# Custom files
custom_files=$(cat <<EOT | tr '\n' ' '
redhat
EOT
)
redhat_files_msg=":open_file_folder: update Red Hat specific files"
robot_trigger_msg=":robot: triggering CI on branch ${redhat_ref} after synching from upstream/${upstream_ref}"

# Reset release-next to upstream master or <git-ref>.
git fetch upstream $upstream_ref
if [[ "$upstream_ref" == "master" ]]; then
  git checkout upstream/master -B ${redhat_ref}
else
  git checkout $upstream_ref -B ${redhat_ref}
fi

# Update redhat's master and take all needed files from there.
git fetch origin $midstream_ref
git checkout origin/$midstream_ref $custom_files

# RHTAP writes its pipeline files to the root of ${redhat_ref}
# Fetch those from origin and apply them to the the release branch
# since we just wiped out our local copy with the upstream ref.
git fetch origin $redhat_ref
#git checkout origin/$redhat_ref .tekton

# Apply midstream patches
if [[ -d redhat/patches ]] && [ "$(ls -A redhat/patches)" ]; then
  git apply redhat/patches/*
fi

# Move overlays to root
if [[ -d redhat/overlays ]]; then
  git mv redhat/overlays/* .
fi

if [[ -d redhat/overlays ]]; then
  git mv redhat/.github/workflows* .
fi

git add . # Adds applied patches
git add $custom_files # Adds custom files
git commit -m "${redhat_files_msg}"

# Push the release-next branch
git push -f origin "${redhat_ref}"

# Trigger CI
# TODO: Set up openshift or github CI to run on release-next-ci
git checkout "${redhat_ref}" -B "${redhat_ref}"-ci
date > ci
git add ci
git commit -m "${robot_trigger_msg}"
git push -f origin "${redhat_ref}-ci"

if hash hub 2>/dev/null; then
   # Test if there is already a sync PR in
   COUNT=$(hub api -H "Accept: application/vnd.github.v3+json" repos/securesign/${REPO_NAME}/pulls --flat \
    | grep -c "${robot_trigger_msg}") || true
   if [ "$COUNT" = "0" ]; then
      hub pull-request --no-edit -l "kind/sync-fork-to-upstream" -b securesign/${REPO_NAME}:${redhat_ref} -h securesign/${REPO_NAME}:${redhat_ref}-ci -m "${robot_trigger_msg}"
   fi
else
   echo "hub (https://github.com/github/hub) is not installed, so you'll need to create a PR manually."
fi