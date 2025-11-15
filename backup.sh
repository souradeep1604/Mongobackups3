#!/bin/bash
# backup.sh: Dump all MongoDB DBs to S3

set -e  # Exit on error

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DUMP_FILE="mongodb-dump-${TIMESTAMP}.archive.gz"
DB_URI="${MONGO_URI:?Error: MONGO_URI not set}"
S3_BUCKET="${S3_BUCKET:?Error: S3_BUCKET not set}"
S3_PATH="${S3_PATH:-mongodb/backups/}"  # Default if unset
AWS_REGION="${AWS_REGION:-us-east-1}"   # Default region if unset

# Debug: Echo vars (masked for secrets) - remove in prod
echo "$(date): Starting backup. Region: ${AWS_REGION}, Bucket: ${S3_BUCKET}"

# Dump all DBs (no --db flag)
mongodump --uri="$DB_URI" --gzip --archive="$DUMP_FILE"

# Upload to S3 with explicit region
aws s3 cp "$DUMP_FILE" "s3://${S3_BUCKET}/${S3_PATH}${DUMP_FILE}" --region "${AWS_REGION}"

# Cleanup local file
rm -f "$DUMP_FILE"

# Log success
echo "$(date): Backup completed and uploaded to s3://${S3_BUCKET}/${S3_PATH}${DUMP_FILE}" >> /var/log/backup.log
