#!/usr/bin/env bash

# Get WiFi info using system_profiler (more reliable)
WIFI_INFO=$(system_profiler SPAirPortDataType 2>/dev/null)

# Extract SSID
SSID=$(echo "$WIFI_INFO" | awk -F': ' '/Current Network Information:/{getline; gsub(/^[ \t]+|:$/, ""); print; exit}')

# Check if WiFi is connected
if [ -z "$SSID" ] || [ "$SSID" = "Off" ]; then
  # Not connected
  sketchybar --set wifi icon="󰖪" label="Disconnected"
else
  # Get signal strength (RSSI) - extract first number after "Signal / Noise:"
  RSSI=$(echo "$WIFI_INFO" | grep "Signal / Noise:" | head -1 | awk '{print $4}')
  
  # Determine icon based on signal strength
  # RSSI ranges: excellent (-50 to 0), good (-60 to -50), fair (-70 to -60), weak (-80 to -70), very weak (below -80)
  if [ -z "$RSSI" ]; then
    # No RSSI available, use default icon
    ICON="󰤨"
  elif [ "$RSSI" -ge -50 ]; then
    ICON="󰤨"  # Full signal
  elif [ "$RSSI" -ge -60 ]; then
    ICON="󰤥"  # Good signal
  elif [ "$RSSI" -ge -70 ]; then
    ICON="󰤢"  # Fair signal
  elif [ "$RSSI" -ge -80 ]; then
    ICON="󰤟"  # Weak signal
  else
    ICON="󰤯"  # Very weak signal
  fi
  
  sketchybar --set wifi icon="$ICON" label="$SSID"
fi

  
  sketchybar --set wifi icon="$ICON" label="$SSID"
fi
