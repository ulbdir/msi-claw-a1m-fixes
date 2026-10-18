# msi-claw-a1m-fixes

AUR package providing essential hardware, power management, and driver fixes for the **MSI Claw A1M** (Intel Meteor Lake Core Ultra 7 155H / Ultra 5 135H) running **CachyOS** or **Arch Linux**.

---

## What this package does

### 1. Switches GPU Driver to `xe` (Modern Intel Xe Driver)
- **Why:** Meteor Lake's integrated Intel Arc graphics (`8086:7d55`) defaults to the legacy `i915` driver on many installations. Switching to Intel's modern `xe` driver significantly improves Vulkan (Mesa ANV) performance, reduces CPU overhead, and fixes Gamescope/Steam presentation stuttering.
- **Implementation:** Shipped in `/usr/lib/modprobe.d/msi-claw-xe.conf`:
  ```ini
  options i915 force_probe=!7d55
  options xe force_probe=7d55
  ```
- **Post-Install:** Re-generates initramfs (`mkinitcpio -P` or `limine-mkinitcpio`) so `xe` is loaded during early boot.

### 2. Disables S3 Deep Sleep (Forces `s2idle` / Modern Standby)
- **Why:** The MSI Claw A1M firmware does not properly handle S3 (`deep`) sleep. Resuming from S3 causes a black screen, controller/input lockups, or kernel panics. The Claw is designed for ACPI `s2idle` (Suspend-to-Idle).
- **Implementation:**
  - `/usr/lib/tmpfiles.d/msi-claw-sleep.conf`: Automatically sets `/sys/power/mem_sleep` to `s2idle` on boot.
  - `/usr/lib/systemd/sleep.conf.d/10-msi-claw-s2idle.conf`: Sets `MemorySleepMode=s2idle` for systemd suspend.

### 3. Fixes Wi-Fi Sleep/Wake & Reloads `iwlwifi` Module on Resume
- **Why:** The Intel Killer BE1750x / BE200 Wi-Fi 7 chip (`8086:272b`) enters a `D3cold` low-power state during sleep from which the firmware often fails to wake up on Linux, breaking Wi-Fi after suspend.
- **Implementation:**
  - `/usr/lib/udev/rules.d/99-msi-claw-wifi.rules`: Disables `d3cold_allowed` on the PCI device (`8086:272b`).
  - `/usr/lib/systemd/system-sleep/msi-claw-wifi-reload.sh`: On wakeup from suspend or hibernate, cleanly unloads and reloads the wireless modules (`iwlmld` and `iwlwifi`) and re-enables wireless links.

---

## Installation

To build and install this package locally:

```bash
cd ~/msi-claw-a1m-fixes
makepkg -si
```

Then **reboot** your device:

```bash
systemctl reboot
```

---

## Verification after Reboot

1. **Verify GPU driver (`xe`):**
   ```bash
   lspci -nnk | grep -iA3 'vga\|3d'
   ```
   *Expected:* `Kernel driver in use: xe`

2. **Verify Sleep mode (`s2idle`):**
   ```bash
   cat /sys/power/mem_sleep
   ```
   *Expected:* `[s2idle] deep`

3. **Verify Wi-Fi D3cold status:**
   ```bash
   cat /sys/bus/pci/drivers/iwlwifi/*/d3cold_allowed
   ```
   *Expected:* `0`
