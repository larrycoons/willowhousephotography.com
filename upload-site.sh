#!/usr/bin/env bash
set -euo pipefail

DOMAIN_NAME="${DOMAIN_NAME:-willowhousephotography.com}"
REGION="${AWS_REGION:-us-east-1}"
STACK_NAME="${STACK_NAME:-willow-house-photography}"

WEBSITE_BUCKET="$(aws cloudformation describe-stacks \
  --region "${REGION}" \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='WebsiteBucketName'].OutputValue" \
  --output text)"

IMAGES_BUCKET="$(aws cloudformation describe-stacks \
  --region "${REGION}" \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='ImagesBucketName'].OutputValue" \
  --output text)"

if [[ -z "${WEBSITE_BUCKET}" || -z "${IMAGES_BUCKET}" ]]; then
  echo "Unable to determine bucket names from the stack outputs."
  exit 1
fi

aws s3 sync . "s3://${WEBSITE_BUCKET}" \
  --delete \
  --exclude ".git/*" \
  --exclude ".git/**" \
  --exclude ".gitignore" \
  --exclude ".DS_Store" \
  --exclude "*.md" \
  --exclude "*.yaml" \
  --exclude "aws-hosting*" \
  --exclude "deploy-aws.sh" \
  --exclude "deploy-and-push.sh" \
  --exclude "upload-site.sh" \
  --exclude "images/*"

if [[ -d images ]]; then
  aws s3 sync images/ "s3://${IMAGES_BUCKET}/images/" --delete --exclude ".DS_Store"
fi

DIST_ID="$(aws cloudformation describe-stacks \
  --region "${REGION}" \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" \
  --output text)"

if [[ -n "${DIST_ID}" ]]; then
  aws cloudfront create-invalidation --distribution-id "${DIST_ID}" --paths '/*'
fi
