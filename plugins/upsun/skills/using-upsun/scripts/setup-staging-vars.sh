#!/bin/bash
# Set up standard staging variables for an Upsun project
# Edit values before running.
PROJECT="${1:-abc123}"
ENV="${2:-staging}"

# Use test API keys in staging
upsun variable:create -p $PROJECT -e $ENV \
  --name STRIPE_SECRET_KEY --value "sk_test_xxx" \
  --visible-runtime true --sensitive true

# Enable debug mode
upsun variable:create -p $PROJECT -e $ENV \
  --name APP_DEBUG --value "true" \
  --visible-runtime true

# Verbose logging
upsun variable:create -p $PROJECT -e $ENV \
  --name LOG_LEVEL --value "debug" \
  --visible-runtime true
