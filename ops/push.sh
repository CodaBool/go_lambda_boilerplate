#!/usr/bin/env bash

# This script will upload your image to ECR

set -o errexit
set -o nounset
set -o pipefail

path_to_dockerfile="$1"
repository_url="$2"
tag="${3:-latest}"

region="$(echo "$repository_url" | cut -d. -f4)"
image_name_and_tag="$(echo "$repository_url" | cut -d/ -f2)"

# subshell
(cd "$path_to_dockerfile" && docker build -t "$image_name_and_tag" .)

aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$repository_url"
docker tag "$image_name_and_tag" "$repository_url":"$tag"
docker push "$repository_url":"$tag"