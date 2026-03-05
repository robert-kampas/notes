#!/bin/bash

BUCKET="wsai-avatar-bucket-public"

REGIONS=(
  "us-east-1"
  "us-east-2"
  "us-west-1"
  "us-west-2"
  "eu-west-1"
  "eu-west-2"
  "eu-west-3"
  "eu-central-1"
  "eu-north-1"
  "ap-south-1"
  "ap-northeast-1"
  "ap-northeast-2"
  "ap-northeast-3"
  "ap-southeast-1"
  "ap-southeast-2"
  "ca-central-1"
  "sa-east-1"
)

echo "Testing bucket: $BUCKET"
echo "---"

for region in "${REGIONS[@]}"; do
  echo -n "Trying $region... "
  if aws s3 ls s3://$BUCKET --region $region 2>/dev/null; then
    echo "✓ SUCCESS! Bucket is in $region"
    exit 0
  else
    echo "✗"
  fi
done

echo "Bucket not found in any region"

