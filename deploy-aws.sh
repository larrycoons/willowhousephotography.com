#!/usr/bin/env bash
set -euo pipefail

DOMAIN_NAME="${DOMAIN_NAME:-willowhousephotography.com}"
HOSTED_ZONE_ID="${HOSTED_ZONE_ID:-}"
CERTIFICATE_ARN="${CERTIFICATE_ARN:-}"
CONTACT_FROM_EMAIL="${CONTACT_FROM_EMAIL:-}"
NOTIFICATION_EMAILS="${NOTIFICATION_EMAILS:-larrycoons@larrycoons.com,lynseycoons@gmail.com}"
STACK_NAME="${STACK_NAME:-willow-house-photography}"
REGION="${AWS_REGION:-us-east-1}"

if [[ -z "${HOSTED_ZONE_ID}" ]]; then
  echo "HOSTED_ZONE_ID is required"
  exit 1
fi

if [[ -z "${CERTIFICATE_ARN}" ]]; then
  echo "CERTIFICATE_ARN is required"
  exit 1
fi

CONTACT_FROM_EMAIL="${CONTACT_FROM_EMAIL:-larrycoons@larrycoons.com}"

if [[ -z "${NOTIFICATION_EMAILS}" ]]; then
  echo "NOTIFICATION_EMAILS is required"
  exit 1
fi

aws cloudformation deploy \
  --region "${REGION}" \
  --stack-name "${STACK_NAME}" \
  --template-file aws-hosting-template.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    DomainName="${DOMAIN_NAME}" \
    HostedZoneId="${HOSTED_ZONE_ID}" \
    CertificateArn="${CERTIFICATE_ARN}" \
    ContactFromEmail="${CONTACT_FROM_EMAIL}" \
    NotificationEmails="${NOTIFICATION_EMAILS}"
