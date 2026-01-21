FROM cm-base:latest

USER root

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
