#!/bin/bash
# Start Kanata with the Moonlander config in the background

# Acquire sudo credentials upfront (needed to stop Karabiner daemons and start Kanata)
sudo -v || exit 1

# First, make sure Karabiner's remapping engine is stopped (but keep VirtualHIDDevice - Kanata needs it)
killall -9 Karabiner-Menu 2>/dev/null
killall -9 Karabiner-NotificationWindow 2>/dev/null
launchctl bootout gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server 2>/dev/null
sudo killall -9 Karabiner-Core-Service 2>/dev/null
sleep 1

# Check if Kanata is already running
if pgrep -x kanata > /dev/null; then
    echo "Kanata is already running!"
    exit 0
fi

echo "Starting Kanata with Moonlander config in background..."
# Run Kanata in the background, redirect output to log file
sudo kanata -c ~/.dotfiles/config/kanata/moonlander.kbd > /tmp/kanata.log 2>&1 &
sleep 1

# Check if it started successfully
if pgrep -x kanata > /dev/null; then
    echo "✓ Kanata started successfully!"
    echo "  Log: /tmp/kanata.log"
    echo "  Stop with: kanata-stop"
else
    echo "✗ Failed to start Kanata. Check /tmp/kanata.log for errors."
    exit 1
fi
