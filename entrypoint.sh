#!/bin/bash
# entrypoint.sh: Run backup on start, then start cron

set -e  # Exit on error

echo "$(date): Starting MongoDB backup on service init..."

# Run the backup once (dumps all DBs to S3)
 /usr/local/bin/backup.sh

echo "$(date): Initial backup completed. Starting cron daemon..."

# Start busybox crond in foreground
exec /usr/sbin/crond -f -l 2
