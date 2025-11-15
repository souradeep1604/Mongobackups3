FROM alpine:3.20  # Latest stable with ARM64 support

# Install dependencies (all available on aarch64)
RUN apk update && \
    apk add --no-cache \
        mongodb-database-tools=100.9.4-r0 \  # Latest mongodump/mongorestore
        aws-cli=2.17.20-r0 \                 # Latest AWS CLI v2 (ARM-native)
        dcron=1.5.3-r0 \                     # Lightweight cron
        bash=5.2.26-r0 && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/cron.d /var/log

# Copy script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Cron job: Daily at 2 AM UTC (edit for your needs)
RUN echo "0 2 * * * /usr/local/bin/backup.sh >/var/log/backup-cron.log 2>&1" > /etc/cron.d/backup-cron && \
    chmod 0644 /etc/cron.d/backup-cron

# Expose logs (optional, for Coolify volume mount)
VOLUME ["/var/log"]

# Health check: Verify tools
HEALTHCHECK --interval=1h --timeout=10s CMD mongodump --version && aws --version || exit 1

# Start cron
CMD ["crond", "-f", "-l", "2"]
