#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

path_to_dockerfile="$1"

# include any folders which can safely be ignore for
# if there was any changes which would cause the 
# lambda image to be rebuilt
file_hashes="$(
  cd $path_to_dockerfile \
  && find . -type f -not -path './.**' \
    -not -path '*/venv/*' \
    -not -path '*/node_modules/*' \
  | sort \
  | xargs md5sum
)"

hash="$(echo "$file_hashes" | md5sum | cut -d' ' -f1)"
echo '{ "hash": "'"$hash"'" }'