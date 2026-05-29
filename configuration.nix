# configuration.nix
# NixOS aarch64 VMware Fusion VM — system-level config
# Requires: VMware Fusion hardware version 20+, Full acceleration, max graphics RAM

{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # vmwgfx — VMware's SVGA3 virtual GPU driver
  # Do NOT load virtio_gpu here; that's UTM-specific
  boot.initrd.kernelModules = [ "vmwgfx" ];
  boot.kernelModules = [ "vmwgfx" ];

  # Kernel 5.19+ required for OpenGL 4.3 in Fusion
  # nixos-unstable tracks a recent enough kernel automatically,
  # but pin to latest if needed:
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── System ──────────────────────────────────────────────────────────────────
  networking.hostName = "hypr-vmware";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── VMware guest tools ───────────────────────────────────────────────────── 
  # open-vm-tools: clipboard sharing, display resize, host/guest file sharing
  virtualisation.vmware.guest = {
    enable = true;
    headless = false;   # false = include vmwgfx display driver support
  };

  # ── Graphics / Wayland ──────────────────────────────────────────────────────
  # vmwgfx exposes OpenGL 4.3 via Mesa's svga/vmwgfx backend on Fusion 13+
  hardware.graphics = {
    enable = true;
    # mesa provides the vmwgfx/svga Gallium driver
    extraPackages = with pkgs; [
      mesa
    ];
  };

  # ── Hyprland ────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ── Display manager ─────────────────────────────────────────────────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # UWSM-managed session — withUWSM = true generates the start-hyprland wrapper
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        # Fallback: direct launch without UWSM
        # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ── Audio ───────────────────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ── User ────────────────────────────────────────────────────────────────────
  users.users.shawn = {            # ← change to your username
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # ── Base packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    pciutils
    usbutils
    wl-clipboard
    grim
    slurp
    uwsm              # universal wayland session manager — required for uwsm-start
    # Useful for confirming GL version inside the VM
    mesa-demos
    vulkan-tools
    ghostty
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
