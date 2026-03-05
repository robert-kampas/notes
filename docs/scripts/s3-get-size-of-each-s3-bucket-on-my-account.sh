#!/bin/bash

aws_profiles=('testing');

for profile in "${aws_profiles[@]}"; do
    echo "$profile"
    read -rd "\n" -a buckets <<< "$(aws --profile "$profile" s3 ls | cut -d " " -f3)"
    for bucket in "${buckets[@]}"; do
        echo "$bucket"
        aws --profile "$profile" s3 ls s3://"$bucket" --human-readable --summarize | awk END'{print}'
    done
done
