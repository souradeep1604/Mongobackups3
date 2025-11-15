FROM alpine:3.19
# Base image with ARM64 support and built-in busybox crond

# Install dependencies: mongodb-tools (includes mongodump), aws-cli, bash
# Busybox crond is already included—no dcron needed
RUN apk update && \
    apk add --no-cache \
        mongodb-tools \
        aws-cli \
        bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/crontabs /var/log

# Copy the backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Set up cron job for root user: Daily at 2 AM UTC (logs to file)
RUN echo "0 2 * * * /usr/local/bin/backup.sh >/var/log/backup-cron.log 2>&1" > /etc/crontabs/root && \
    chmod 0644 /etc/crontabs/root

# Optional: Persistent logs volume for Coolify
VOLUME ["/var/log"]

# Health check: Verify key tools are installed
HEALTHCHECK --interval=1h --timeout=10s CMD mongodump --version && aws --version || exit 1

# Start busybox crond in foreground (PID 1, no setpgid issues)
CMD ["/usr/sbin/crond", "-f", "-l", "2"]
