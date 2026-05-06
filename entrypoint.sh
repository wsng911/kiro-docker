#!/bin/bash
chmod 666 /dev/pts/ptmx 2>/dev/null || true
exec gosu kiro bash
