#!/bin/bash
set -e

echo "===================================="
echo "CM Container Starting"
echo "===================================="

# Add local binaries to PATH for SSH sessions
echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/me/.bashrc

# Fix permissions on authorized_keys if mounted (ignore errors for read-only mounts)
if [ -f /home/me/.ssh/authorized_keys ]; then
    chmod 600 /home/me/.ssh/authorized_keys 2>/dev/null || true
    chown me:me /home/me/.ssh/authorized_keys 2>/dev/null || true
fi

# Start SSH daemon
/usr/sbin/sshd -D &

# Keep container running
exec tail -f /dev/null
