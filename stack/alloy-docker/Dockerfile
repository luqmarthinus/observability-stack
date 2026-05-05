# Stage 1: Get the static health check binary
FROM ghcr.io/tarampampam/microcheck:1.4.0 AS healthcheck

# Stage 2: Build the final Alloy image
FROM grafana/alloy:v1.16.0

# Copy the static httpcheck binary (75 KB, zero dependencies)
COPY --from=healthcheck /bin/httpcheck /bin/httpcheck

# Health check using the static binary.
# Alloy’s readiness endpoint is simply /ready (not /-/ready).
HEALTHCHECK --interval=15s --timeout=5s --retries=5 --start-period=30s \
    CMD ["/bin/httpcheck", "http://localhost:12345/ready"]