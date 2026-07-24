#!/bin/bash
# macOS protects the TCC database. Grant Kanata permissions through System
# Settings; a Homebrew upgrade can invalidate the prior binary authorization.

set -euo pipefail

echo "Remove stale Kanata entries, then add /opt/homebrew/bin/kanata in:"
echo "  System Settings -> Privacy & Security -> Input Monitoring"
echo "  System Settings -> Privacy & Security -> Accessibility"
echo "Restart the root daemon afterward:"
echo "  sudo launchctl bootout system/com.kanata.service"
echo "  sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.service.plist"
