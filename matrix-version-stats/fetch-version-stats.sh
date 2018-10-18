#!/bin/bash

set -eu
set -o pipefail

debug() {
  1>&2 echo "$*"
}

get_server_version() {
  server=${1:?server name}

  server_url="https://${server}:8448"

  dig_resp="$(dig +short -t srv _matrix._tcp."${server}" || echo "")"
  if [[ "$dig_resp" != "" ]]; then
    server_url="$(awk '{gsub(/.$/, "", $4); print "https://"$4":"$3}' <<<"$dig_resp")"
  fi

  server_version="$(curl -sSLk --max-time 3 "${server_url}/_matrix/federation/v1/version" | jq '.server | [.name, .version] | join(" ")' -rc || echo 'unknown')"

  echo "$server, \"${server_version:-unknown}\""
}

wait_countdown=20
id=0
tmp="$(mktemp -d)"

pids=()
while read -r line; do
  debug "Processing $line"
  $( get_server_version "$line" > "$tmp/server_$id" ) &
  pids+=($!)

  (( id += 1 ))

  wait_countdown=$(( wait_countdown-1 ))
  if [[ "${wait_countdown}" -eq "0" ]]; then
    wait || true
    wait_countdown=20
  fi
done

wait

echo "Server Name, Server Version"
cat "$tmp"/server_*

rm -rf "$tmp"
