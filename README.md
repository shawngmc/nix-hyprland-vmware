# NixOS aarch64 + Hyprland on VMware Fusion

Starter flake config for running Hyprland in an ARM-native VMware Fusion VM
on Apple Silicon. Provides OpenGL 4.3 via the vmwgfx/SVGA3 driver — no GL
workarounds needed for kitty or other GPU-accelerated apps.

## VMware Fusion VM Settings

| Setting | Value |
|---|---|
| OS | Linux > Other Linux 5.x kernel 64-bit ARM |
| Memory | ≥8 GB (16 GB recommended) |
| CPU Cores | ≥4 |
| **Graphics** | **Full acceleration** |
| **Graphics RAM** | **Maximum (8 GB)** |
| Hardware Version | **20 or later** (required for OpenGL 4.3) |
| Network | Shared with Mac |
| Sound card | Remove |
| Camera | Remove |
| Printer | Remove |

> Hardware version 20+ is required. Check via VM Settings → Compatibility.
> If you have an older VM, upgrade: Virtual Machine menu → Upgrade VM Compatibility.

## NixOS ISO

Download the minimal aarch64 ISO from https://nixos.org/download
Choose **Minimal ISO, aarch64**.

Or from Hydra (latest unstable):
https://hydra.nixos.org/job/nixos/trunk-combined/nixos.iso_minimal.aarch64-linux/latest

## Installation

Boot the ISO in Fusion. The disk will appear as `/dev/sda` (SATA) in Fusion.

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MB 100%

mkfs.fat -F 32 /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

nixos-generate-config --root /mnt
```

## Deploying This Config

```bash
cd /mnt/etc/nixos
# Copy or clone flake.nix, configuration.nix, home.nix here
# Replace "shawn" with your actual username throughout

nixos-install --flake .#hypr-vmware
reboot
```

After reboot, greetd + tuigreet presents a login prompt. Log in and Hyprland
starts automatically via UWSM.

## Post-Boot Checks

```bash
# Confirm vmwgfx driver is active
lspci -k | grep -A2 -i vga          # should show vmwgfx

# Verify OpenGL version — should report 4.3
glxinfo | grep "OpenGL version"      # expect: OpenGL version string: 4.3

# Confirm Wayland display is set
echo $WAYLAND_DISPLAY                # should be "wayland-1"

# Check Hyprland version
hyprctl version
```

## What Changed vs UTM Config

| | UTM | VMware Fusion |
|---|---|---|
| GPU driver | virtio_gpu (virgl) | vmwgfx (SVGA3) |
| OpenGL | 2.1 (virgl cap) | 4.3 |
| Guest tools | N/A | `virtualisation.vmware.guest.enable = true` |
| Disk device | `/dev/vda` | `/dev/sda` |
| GL workarounds | `WLR_RENDERER`, `WLR_NO_HARDWARE_CURSORS`, `LIBGL_ALWAYS_SOFTWARE` | None needed |
| Blur / shadows | Disabled | Enabled |
| kitty issues | EGL context failure | None |

## Troubleshooting

**vmwgfx not loading / black screen**
- Confirm hardware version is 20+ in VM settings
- Confirm "Full acceleration" is selected in display settings
- Check `dmesg | grep vmwgfx` for driver errors

**Dynamic resolution not working (VM stays fixed size)**
- `open-vm-tools` must be running: `systemctl status vmware-vmblock-fuse`
- May need a reboot after first install of guest tools

**Tearing / vblank issues**
- `vfr = true` is set in hyprland.lua; if tearing persists also try:
  `misc.no_vfr = false` and add `WLR_DRM_NO_ATOMIC=1` to sessionVariables

**Blur causing visual glitches**
- Set `blur.enabled = false` in hyprland.lua as a quick test;
  if that fixes it, reduce `blur.passes` to 1

## Key Bindings

| Binding | Action |
|---|---|
| Super + Return | Terminal (kitty) |
| Super + Q | Close window |
| Super + Space | App launcher (rofi) |
| Super + F | Fullscreen |
| Super + V | Toggle floating |
| Super + H/J/K/L | Move focus |
| Super + Shift + H/J/K/L | Move window |
| Super + Ctrl + H/J/K/L | Resize window |
| Super + 1–9 | Switch workspace |
| Super + Shift + 1–9 | Move window to workspace |
| Print | Screenshot (full) |
| Shift + Print | Screenshot (region) |
