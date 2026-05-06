#!/bin/bash
# Fix /dev/pts/ptmx permissions for kiro-cli-term
chmod 666 /dev/pts/ptmx 2>/dev/null || true
exec "$@"
