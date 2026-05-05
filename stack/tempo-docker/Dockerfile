# Stage 1: Get the static health check binary
FROM ghcr.io/tarampampam/microcheck:1.4.0 AS healthcheck

# Stage 2: Build the final Tempo image
FROM grafana/tempo:2.10.5

# Copy the static httpcheck binary (75 KB, no dependencies)
COPY --from=healthcheck /bin/httpcheck /bin/httpcheck

# Health check using the static binary
HEALTHCHECK --interval=15s --timeout=5s --retries=5 --start-period=30s \
    CMD ["/bin/httpcheck", "http://localhost:3200/ready"]