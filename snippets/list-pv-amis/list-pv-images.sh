#!/bin/bash

set -e
set -o nounset
set -o pipefail

function usage() {
	cat <<EOM
Usage: $0 [AWS Region]"

Note: environment variables respected by the AWS cli, such as AWS_PROFILE, will
also be respected by this script.
EOM
}

if ! type aws &>/dev/null; then
	1>&2 echo "The 'aws' command is required to run this script"
	exit 1
fi
if ! type jq &>/dev/null; then
	1>&2 echo "The 'jq' command is required to run this script"
	exit 1
fi


# The account which publishes Container Linux AMIs
IMAGE_OWNER=595879546273

# Catch '-h, --help' via a regex for any flags
if [[ $# -ne 1 ]] || [[ "$1" =~ ^- ]]; then
	usage
	exit 0
fi

REGION="$1"

# Get all running PV instances, including their image-id
# The image-id is needed to figure out if it's container linux; unfortunately
# there's no describe-instances filter for that
instance_pairs=$(aws ec2 describe-instances \
                     --output=json \
                     --region=$REGION \
                     --filters "Name=virtualization-type,Values=paravirtual" "Name=instance-state-name,Values=running" | jq -r -c '.Reservations[].Instances[] | [.InstanceId, .ImageId] | join(" ")')

if [[ -z "${instance_pairs}" ]]; then
	exit 0
fi

# open-air-quote hash-table close-air-quote to only have to describe each
# image-id once
image_cache=""

while read -r instance_id image_id; do
	is_containerlinux="0"

	if grep "${image_id}=0" <(echo "${image_cache}") &>/dev/null; then
		is_containerlinux="0"
	elif grep "${image_id}=1" <(echo "${image_cache}") &>/dev/null; then
		is_containerlinux="1"
	else
		is_containerlinux=$(aws ec2 describe-images \
		                        --output=json \
		                        --region=$REGION \
		                        --image-ids="${image_id}" \
		                        	| jq ".Images[] | [select(.OwnerId == \"${IMAGE_OWNER}\")] | length")
		image_cache="${image_cache}\n${image_id}=${is_containerlinux}"
	fi
		
	if [[ "${is_containerlinux}" == "1" ]]; then
		echo "${instance_id}"
	fi
done <<< "${instance_pairs}"
