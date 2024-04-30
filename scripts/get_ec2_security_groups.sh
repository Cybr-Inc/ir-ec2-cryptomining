#!/bin/bash

# Arguments:
# - EC2 instance IDs: space-separated EC2 instance IDs
# - Region: the region you launched the EC2 instance in
# - Profile: the AWS CLI profile to use to access credentials

# Description:
# Retrieve security groups and permissions for a set of EC2 instances

# Check if arguments were provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <instances> <region> <profile>"
    exit 1
fi

# Assign the provided arguments to variables
instances=$1
region=$2
profile=$3

sgs=$(aws ec2 describe-instances --instance-ids "${instances}" --region us-east-1 --profile ${profile} | jq -r '.Reservations[].Instances[].NetworkInterfaces[].Groups[].GroupId')

for sg in ${sgs[@]}; do
    echo "Security group ${sg}:"
    echo "$(aws ec2 describe-security-groups --group-ids ${sg} --region us-east-1 --profile ${profile} | jq -r '.SecurityGroups[]')"
    echo "-----------"
done
