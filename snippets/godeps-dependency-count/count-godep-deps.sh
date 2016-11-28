#!/bin/bash

set -e

[ -f Godeps/Godeps.json ] || {
  1>&2 echo "No Godeps/Godeps.json file present"
  exit 1
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
deps=$(jq -r -f "${SCRIPT_DIR}/query.jq" Godeps/Godeps.json)

echo "There are $(echo "$deps" | wc -l) dependencies. The shortest package from each is listed below:"
echo "$deps" | sort
