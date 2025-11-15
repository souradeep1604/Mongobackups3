FROM alpine:3.19
# Base image with ARM64 support and all required packages available

# Install dependencies: mongodb-tools (includes mongodump), aws-cli, dcron, bash
RUN apk update && \
    apk add --no-cache \
        mongodb-tools \
        aws-cli \
        dcron \
        bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/cron.d /var/log

# Copy the backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Set up cron job: Daily at 2 AM UTC (logs to file)
RUN echo "0 2 * * * /usr/local/bin/backup.sh >/var/log/backup-cron.log 2>&1" > /etc/cron.d/backup-cron && \
    chmod 0644 /etc/cron.d/backup-cron

# Optional: Persistent logs volume for Coolify
VOLUME ["/var/log"]

# Health check: Verify key tools are installed
HEALTHCHECK --interval=1h --timeout=10s CMD mongodump --version && aws --version || exit 1

# Start the cron daemon in foreground
CMD ["crond", "-f", "-l", "2"]
