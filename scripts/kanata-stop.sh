#!/bin/bash
# Stop Kanata

if ! pgrep -x kanata > /dev/null; then
    echo "Kanata is not running."
    exit 0
fi

echo "Stopping Kanata..."
sudo pkill kanata
sleep 1

if ! pgrep -x kanata > /dev/null; then
    echo "✓ Kanata stopped successfully."
else
    echo "✗ Failed to stop Kanata. Trying force kill..."
    sudo pkill -9 kanata
fi
