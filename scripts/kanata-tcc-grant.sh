#!/bin/bash
# Grant kanata Input Monitoring (kTCCServiceListenEvent) permission by writing
# directly to the system TCC database. Required because macOS 26 doesn't allow
# adding non-app-bundle binaries via the System Settings UI.
#
# Run as: sudo bash ~/.dotfiles/scripts/kanata-tcc-grant.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root: sudo bash $0"
  exit 1
fi

TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"
KANATA_REAL="$(readlink -f /opt/homebrew/bin/kanata)"
KANATA_LINK="/opt/homebrew/bin/kanata"
NOW="$(date +%s)"

echo "System TCC database: $TCC_DB"
echo "Kanata binary (real): $KANATA_REAL"
echo "Kanata binary (link): $KANATA_LINK"
echo ""

# Show current schema so we can see what columns exist
echo "==> TCC access table schema:"
sqlite3 "$TCC_DB" "SELECT name FROM pragma_table_info('access');" | tr '\n' ' '
echo ""
echo ""

# Check if already granted
EXISTING=$(sqlite3 "$TCC_DB" \
  "SELECT client, auth_value FROM access WHERE service='kTCCServiceListenEvent' AND (client='$KANATA_REAL' OR client='$KANATA_LINK');" 2>/dev/null || true)
if [[ -n "$EXISTING" ]]; then
  echo "Existing TCC entries for kanata:"
  echo "$EXISTING"
  echo ""
fi

echo "==> Inserting kTCCServiceListenEvent grants..."

# Insert for the real resolved path
sqlite3 "$TCC_DB" \
  "INSERT OR REPLACE INTO access
     (service, client, client_type, auth_value, auth_reason, auth_version,
      indirect_object_identifier, last_modified, boot_uuid, last_reminded)
   VALUES
     ('kTCCServiceListenEvent', '$KANATA_REAL', 1, 2, 4, 1,
      'UNUSED', $NOW, 'UNUSED', 0);"
echo "  Granted for: $KANATA_REAL"

# Insert for the symlink path too (macOS might check either)
sqlite3 "$TCC_DB" \
  "INSERT OR REPLACE INTO access
     (service, client, client_type, auth_value, auth_reason, auth_version,
      indirect_object_identifier, last_modified, boot_uuid, last_reminded)
   VALUES
     ('kTCCServiceListenEvent', '$KANATA_LINK', 1, 2, 4, 1,
      'UNUSED', $NOW, 'UNUSED', 0);"
echo "  Granted for: $KANATA_LINK"

# Verify the inserts
echo ""
echo "==> Verification:"
sqlite3 "$TCC_DB" \
  "SELECT client, auth_value, auth_reason FROM access WHERE service='kTCCServiceListenEvent' AND (client='$KANATA_REAL' OR client='$KANATA_LINK');"

echo ""
echo "==> Restarting tccd to reload the database..."
pkill -9 tccd 2>/dev/null || true
sleep 2
echo "  tccd restarted."

echo ""
echo "==> Restarting kanata..."
launchctl bootout system/com.kanata.service 2>/dev/null || true
pkill -9 kanata 2>/dev/null || true
sleep 1

if [[ -f "/Library/LaunchDaemons/com.kanata.service.plist" ]]; then
  launchctl bootstrap system /Library/LaunchDaemons/com.kanata.service.plist
  sleep 3
fi

echo ""
echo "==> Result:"
if pgrep -x kanata > /dev/null; then
  echo "Kanata is running. Check /tmp/kanata.err — if the IOHIDDeviceOpen errors"
  echo "are gone, remapping is now active."
else
  echo "Kanata is not running. Check /tmp/kanata.log and /tmp/kanata.err."
fi

cat /tmp/kanata.err 2>/dev/null | tail -5
