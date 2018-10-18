#!/bin/bash

# SPDX: MIT
# Copyright 2018 Euan Kemp
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# Usage:
# ./fetch-version-stats.sh < line-separated-list-of-matrix-servers > output.csv
#
# This script will get the matrix server version of a list of servers and
# collect them into one csv file.

set -eu
set -o pipefail

# number of concurrent 'get_server_version's to run
num_procs=20

debug() {
  1>&2 echo "$*"
}

# Function to print a server's name + version to stdout, comma separated.
# It does its best to support matrix srv records.
get_server_version() {
  server=${1:?server name}

  server_url="https://${server}:8448"

  dig_resp="$(dig +short -t srv _matrix._tcp."${server}" | head -n 1 || echo "")"
  if [[ "$dig_resp" != "" ]]; then
    # prio weight port target, we only care about port+target
    server_url="$(awk '{gsub(/.$/, "", $4); print "https://"$4":"$3}' <<<"$dig_resp")"
  fi

  server_version="$(curl -sSLk --max-time 3 "${server_url}/_matrix/federation/v1/version" | jq '.server | [.name, .version] | join(" ")' -rc || echo 'unknown')"

  echo "$server, \"${server_version:-unknown}\""
}

tmp="$(mktemp -d)"
id=0
wait_countdown=$num_procs

while read -r line; do
  debug "Processing $line"
  # note: backgrounded
  $( get_server_version "$line" > "$tmp/server_$id" ) &

  (( id += 1 ))
  # Fun fact, (( wait_countdown -= 1 )) will trigger a 'set -e' exit once it
  # tries to decrement 1 to 0. It returns 0 for other -= 1 operations, but if
  # the var is 1, it returns 1 instead. Gotta love bash.
  wait_countdown=$(( wait_countdown-1 ))

  if [[ "${wait_countdown}" -eq "0" ]]; then
    wait
    wait_countdown=$num_procs
  fi
done

wait

echo "Server Name, Server Version"
cat "$tmp"/server_*

rm -rf "$tmp"
