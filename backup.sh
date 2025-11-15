#!/bin/bash
# Make executable: chmod +x backup.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DUMP_FILE="mongodb-dump-${TIMESTAMP}.archive.gz"
DB_URI="${MONGO_URI}"  # e.g., mongodb://user:pass@external-host:27017/dbname?authSource=admin
DB_NAME="${DB_NAME}"   # Optional: specific DB, or omit for all
S3_BUCKET="${S3_BUCKET}"
S3_PATH="${S3_PATH:-mongodb/backups/}"  # Optional prefix

# Dump (add --db=$DB_NAME for specific DB, --excludeCollection=logs for exclusions)
mongodump --uri="$DB_URI" --gzip --archive="$DUMP_FILE" ${DB_NAME:+"--db=$DB_NAME"}

# Upload to S3
aws s3 cp "$DUMP_FILE" "s3://$S3_BUCKET/$S3_PATH$$ DUMP_FILE" --region " $${AWS_REGION}"

# Cleanup local file
rm -f "$DUMP_FILE"

# Optional: Log success/failure
echo "$(date): Backup completed for $DB_NAME" >> /var/log/backup.log
