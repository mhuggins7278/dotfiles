#!/bin/bash
# Start Kanata with the Moonlander config via LaunchDaemon.
# Disables Karabiner-Core-Service (which would otherwise grab the keyboard),
# while keeping Karabiner-VirtualHIDDevice-Daemon running (kanata needs it).

set -euo pipefail

KANATA_BIN="/opt/homebrew/bin/kanata"
KANATA_CONFIG="$HOME/.dotfiles/config/kanata/moonlander.kbd"
KANATA_PLIST_SRC="$HOME/.dotfiles/config/kanata/com.kanata.service.plist"
KANATA_PLIST_DEST="/Library/LaunchDaemons/com.kanata.service.plist"

# Acquire sudo credentials upfront
sudo -v || exit 1

echo "Disabling Karabiner-Core-Service..."

# Disable + stop the system daemon that grabs the keyboard (keep VirtualHIDDevice-Daemon)
sudo launchctl disable system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
sudo launchctl bootout system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true

# Disable + stop user-level Karabiner agents
for label in \
  org.pqrs.service.agent.Karabiner-Core-Service \
  org.pqrs.service.agent.karabiner_console_user_server \
  org.pqrs.service.agent.Karabiner-NotificationWindow \
  org.pqrs.service.agent.Karabiner-Menu \
  org.pqrs.service.agent.karabiner_session_monitor; do
  launchctl disable "gui/$(id -u)/${label}" 2>/dev/null || true
  launchctl bootout "gui/$(id -u)/${label}" 2>/dev/null || true
done

sleep 1

# Install rendered kanata plist to LaunchDaemons if present
if [[ -f "$KANATA_PLIST_SRC" && ! -f "$KANATA_PLIST_DEST" ]]; then
  echo "Installing kanata LaunchDaemon plist..."
  sudo cp "$KANATA_PLIST_SRC" "$KANATA_PLIST_DEST"
  sudo chown root:wheel "$KANATA_PLIST_DEST"
  sudo chmod 644 "$KANATA_PLIST_DEST"
fi

# Restart kanata via LaunchDaemon (bootout first in case it's already loaded)
if [[ -f "$KANATA_PLIST_DEST" ]]; then
  echo "Starting Kanata LaunchDaemon..."
  sudo launchctl bootout system/com.kanata.service 2>/dev/null || true
  sleep 1
  sudo launchctl bootstrap system "$KANATA_PLIST_DEST"
  sleep 2
  if pgrep -x kanata > /dev/null; then
    echo "Kanata started via LaunchDaemon."
    echo "  Config: $KANATA_CONFIG"
    echo "  Log:    /tmp/kanata.log"
    echo "  Stop:   kanata-stop"
  else
    echo "LaunchDaemon start failed. Falling back to direct launch..."
    sudo "$KANATA_BIN" -c "$KANATA_CONFIG" > /tmp/kanata.log 2>&1 &
    sleep 2
    if pgrep -x kanata > /dev/null; then
      echo "Kanata started directly."
    else
      echo "Failed to start kanata. Check /tmp/kanata.err for details."
      exit 1
    fi
  fi
else
  echo "No LaunchDaemon plist found at $KANATA_PLIST_DEST."
  echo "Run 'dotfiles' (ansible-playbook) to install it, or run kanata directly:"
  echo "  sudo $KANATA_BIN -c $KANATA_CONFIG"
  echo ""
  echo "Falling back to direct launch..."
  sudo pkill kanata 2>/dev/null || true
  sleep 1
  sudo "$KANATA_BIN" -c "$KANATA_CONFIG" > /tmp/kanata.log 2>&1 &
  sleep 2
  if pgrep -x kanata > /dev/null; then
    echo "Kanata started directly."
    echo "  Log: /tmp/kanata.log"
  else
    echo "Failed to start kanata. Check /tmp/kanata.err for details."
    exit 1
  fi
fi
