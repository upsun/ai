#!/bin/bash
# Set up standard production variables for an Upsun project
# Edit values before running.
PROJECT="${1:-abc123}"
ENV="${2:-production}"

# Database
upsun variable:create -p $PROJECT -e $ENV \
  --name DB_HOST --value "database.internal" \
  --visible-runtime true

# App configuration
upsun variable:create -p $PROJECT -e $ENV \
  --name APP_ENV --value "production" \
  --visible-build true --visible-runtime true

upsun variable:create -p $PROJECT -e $ENV \
  --name APP_DEBUG --value "false" \
  --visible-runtime true

# API keys (sensitive)
upsun variable:create -p $PROJECT -e $ENV \
  --name STRIPE_SECRET_KEY --value "sk_live_xxx" \
  --visible-runtime true --sensitive true

upsun variable:create -p $PROJECT -e $ENV \
  --name SENDGRID_API_KEY --value "SG.xxx" \
  --visible-runtime true --sensitive true
