#!/bin/bash

set -e
set -o nounset
set -o pipefail

# The account which publishes Container Linux AMIs
IMAGE_OWNER=595879546273

REGION="${1:?Please provide the AWS region to search as an argument}"

# Get all running PV instances, including their image-id
# The image-id is needed to figure out if it's container linux; unfortunately
# there's no describe-instances filter for that
instance_pairs=$(aws ec2 describe-instances \
                     --output=json \
                     --region=$REGION \
                     --filters Name=virtualization-type,Values=paravirtual,Name=instance-state-name,Values=running | jq -r -c '.Reservations[].Instances[] | [.InstanceId, .ImageId] | join(" ")')

# Poor man's hash-table to only have to describe each image-id once
image_cache=""

while read -r instance_id image_id; do
	is_containerlinux="0"

	if grep "${image_id}=0" <(echo "${image_cache}") &>/dev/null; then
		is_containerlinux="0"
	elif grep "${image_id}=1" <(echo "${image_cache}") &>/dev/null; then
		is_containerlinux="1"
	else
		is_containerlinux=$(aws ec2 describe-images --region=$REGION \
			--image-ids="${image_id}" \
			| jq ".Images[] | [select(.OwnerId == \"${IMAGE_OWNER}\")] | length")
		image_cache="${image_cache}\n${image_id}=${is_containerlinux}"
	fi
		
	if [[ "${is_containerlinux}" == "1" ]]; then
		echo "${instance_id}"
	fi
done <<< "${instance_pairs}"
