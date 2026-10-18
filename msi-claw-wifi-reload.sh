#!/bin/sh
# Systemd sleep hook to reload Intel Wi-Fi 7 (iwlwifi / iwlmld) on resume

case "$1/$2" in
  post/*)
    # 1. Disable D3cold on all active iwlwifi PCI devices
    for dev in /sys/bus/pci/drivers/iwlwifi/*:*; do
      if [ -w "$dev/d3cold_allowed" ]; then
        echo 0 > "$dev/d3cold_allowed"
      fi
    done

    # 2. Reload Wi-Fi modules if iwlwifi is loaded
    if lsmod | grep -q "^iwlwifi"; then
      # Bring wireless interfaces down cleanly to prevent module lockups
      for iface in /sys/class/net/*/wireless; do
        if [ -d "$iface" ]; then
          devname=$(basename "$(dirname "$iface")")
          ip link set "$devname" down 2>/dev/null || true
        fi
      done

      # Unload Wi-Fi modules (iwlmld depends on iwlwifi on Wi-Fi 7)
      modprobe -r iwlmld iwlmvm iwlwifi 2>/dev/null || true
      sleep 0.5

      # Reload modules
      modprobe iwlwifi 2>/dev/null || true
      modprobe iwlmld 2>/dev/null || true

      # Bring wireless interfaces back up
      for iface in /sys/class/net/*/wireless; do
        if [ -d "$iface" ]; then
          devname=$(basename "$(dirname "$iface")")
          ip link set "$devname" up 2>/dev/null || true
        fi
      done
    fi

    # 3. Re-verify D3cold remains disabled after module reload
    for dev in /sys/bus/pci/drivers/iwlwifi/*:*; do
      if [ -w "$dev/d3cold_allowed" ]; then
        echo 0 > "$dev/d3cold_allowed"
      fi
    done
    ;;
esac

exit 0
