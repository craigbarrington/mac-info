#!/bin/bash

clear

# --- Gather Hardware Data ---
CPU_MODEL="$(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
MODEL_ID="$(sysctl -n hw.model 2>/dev/null)"
MODEL_NUMBER="$(system_profiler SPHardwareDataType 2>/dev/null | grep "Model Number" | awk '{print $3}')"
MODEL_NAME="$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Model Name/{print $2}')"
SERIAL_NUMBER="$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Serial Number/{print $2}')"

# Memory
MEM_BYTES="$(sysctl -n hw.memsize 2>/dev/null)"
MEMORY_SIZE="$(echo "$MEM_BYTES / 1024 / 1024 / 1024" | bc)"

# macOS version
MAC_OS_VERSION="$(sw_vers -productVersion)"

# --- Disk Info ---
# Pulls physical hardware capacity from disk0
DISK_SIZE="$(diskutil info disk0 | awk -F': *' '/Disk Size/{print $2}' | sed 's/\..*//')"
SSD_CHECK="$(diskutil info disk0 | awk -F': *' '/Solid State/{print $2}')"

# --- Network Info ---
# Get Wi-Fi IP (specifically from en0)
IP_WIFI="$(ipconfig getifaddr en0 2>/dev/null)"
[ -z "$IP_WIFI" ] && IP_WIFI="Not Connected"

# Find the LAN/Adapter IP by checking the active routing table
# 1. Finds the interface used for the 'default' route
# 2. Excludes en0 (Wi-Fi) to isolate the Ethernet/USB-C adapter
ACTIVE_LAN_IF="$(route -n get default | awk '/interface/ {print $2}' | grep -v 'en0')"

if [ -n "$ACTIVE_LAN_IF" ]; then
    # Pull the IP from the active interface identified by the route
    IP_LAN="$(ifconfig "$ACTIVE_LAN_IF" | grep 'inet ' | awk '{print $2}')"
    [ -z "$IP_LAN" ] && IP_LAN="Not Connected"
else
    IP_LAN="Not Connected"
fi

# --- Output ---
echo ""
echo "  __  __              ___        __        "
echo " |  \/  | __ _  ___  |_ _|_ __  / _| ___   "
echo " | |\/| |/ _  |/ __|  | ||  _ \| |_ / _ \  "
echo " | |  | | (_| | (__   | || | | |  _| (_) | "
echo " |_|  |_|\__,_|\___| |___|_| |_|_|  \___/  "
echo "                                           "
echo "             Craig Barrington              "
echo ""
echo "==========================================="
echo ""
echo "  Model Name:      $MODEL_NAME"
echo "  Model ID:        $MODEL_ID"
echo "  Model Number:    $MODEL_NUMBER"
echo "  Serial Number:   $SERIAL_NUMBER"
echo ""
echo "  CPU:             $CPU_MODEL"
echo "  Memory:          ${MEMORY_SIZE} GB"
echo "  Disk:            ${DISK_SIZE} GB (SSD: $SSD_CHECK)"
echo "  macOS Version:   $MAC_OS_VERSION"
echo ""
echo "  Wi-Fi:           $IP_WIFI"
echo "  LAN:             $IP_LAN"
echo ""
echo "==========================================="
echo ""

exit 0
