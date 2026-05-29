# home.nix
# Home Manager — user-level config with Hyprland tools and hyprland.lua
# VMware Fusion variant — no virtio workarounds needed

{ config, pkgs, lib, ... }:

{
  home.username = "shawn";           # ← change to your username
  home.homeDirectory = "/home/shawn";
  home.stateVersion = "25.11";

  # ── Wayland environment variables ───────────────────────────────────────────
  home.sessionVariables = {
    # Force Wayland for Electron/Chromium apps
    NIXOS_OZONE_WL = "1";
    # Hint apps to the correct session type
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    # VMware SVGA3 driver name (helps some apps pick the right EGL platform)
    MESA_LOADER_DRIVER_OVERRIDE = "vmwgfx";
  };
  # Note: WLR_RENDERER, WLR_NO_HARDWARE_CURSORS, and LIBGL_ALWAYS_SOFTWARE
  # are NOT needed here — vmwgfx provides real hardware-accelerated OpenGL 4.3.

  # ── Packages ──────────────────────────────────────────────────────────────── 
  home.packages = with pkgs; [
    # Launcher
    rofi

    # Status bar
    waybar

    # Notifications
    mako
    libnotify

    # Terminal — kitty works fine with OpenGL 4.3 from vmwgfx
    kitty

    # File manager
    nautilus

    # Fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji

    # Theming
    catppuccin-gtk
    papirus-icon-theme

    # Wayland utilities
    wlr-randr
    brightnessctl
    playerctl
    hyprpaper
    hypridle
    hyprlock
    ghostty
  ];

  # ── Kitty terminal ───────────────────────────────────────────────────────── 
  # No GL workarounds needed — vmwgfx provides OpenGL 4.3
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font";
    font.size = 13;
    settings = {
      background_opacity = "0.95";
      confirm_os_window_close = 0;
      linux_display_server = "wayland";
    };
    theme = "Catppuccin-Mocha";
  };

  # ── Hyprland config (hyprland.lua) ───────────────────────────────────────── 
  # As of v0.55, Hyprland uses Lua for configuration.
  # Managed via xdg.configFile until Home Manager's hyprland module is updated.
  xdg.configFile."hypr/hyprland.lua".text = ''
    -- hyprland.lua — VMware Fusion aarch64 NixOS
    -- Hyprland v0.55+ Lua configuration

    -- ── Monitors ────────────────────────────────────────────────────────────
    -- VMware presents the display as "Virtual-1" or similar.
    -- open-vm-tools handles dynamic resolution — "preferred" follows the window.
    hl.config {
      monitor = {
        { name = "Virtual-1", resolution = "preferred", position = "0x0", scale = 1 }
      }
    }

    -- ── General ─────────────────────────────────────────────────────────────
    hl.config {
      general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
          active_border   = "rgba(cba6f7ff) rgba(89b4faff) 45deg",
          inactive_border = "rgba(45475aff)",
        },
        layout = "dwindle",
      }
    }

    -- ── Decoration ──────────────────────────────────────────────────────────
    -- With OpenGL 4.3 available, blur and shadows can be enabled.
    -- Dial back if you notice GPU pressure in a resource-constrained VM.
    hl.config {
      decoration = {
        rounding = 10,
        blur = {
          enabled = true,
          size = 6,
          passes = 2,
          vibrancy = 0.2,
        },
        shadow = {
          enabled = true,
          range = 12,
          render_power = 3,
          color = "rgba(1a1a2eee)",
        },
      }
    }

    -- ── Animations ──────────────────────────────────────────────────────────
    hl.config {
      animations = {
        enabled = true,
        bezier = {
          { name = "overshoot", points = { 0.05, 0.9, 0.1, 1.05 } },
          { name = "ease",      points = { 0.25, 0.1, 0.25, 1.0 } },
        },
        animation = {
          { target = "windows",      animation = "overshoot", duration = 250 },
          { target = "windowsOut",   animation = "ease",      duration = 200 },
          { target = "workspaces",   animation = "ease",      duration = 250 },
          { target = "fade",         animation = "ease",      duration = 180 },
        }
      }
    }

    -- ── Input ───────────────────────────────────────────────────────────────
    hl.config {
      input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
          natural_scroll = true,
        },
        sensitivity = 0,
      }
    }

    -- ── Layouts ─────────────────────────────────────────────────────────────
    hl.config {
      dwindle = {
        pseudotile     = true,
        preserve_split = true,
      },
      master = {
        new_status = "master",
      }
    }

    -- ── Misc ────────────────────────────────────────────────────────────────
    hl.config {
      misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- VMware: vblank_scheduler can cause issues; disable if you see tearing
        vfr = true,
      }
    }

    -- ── Autostart ───────────────────────────────────────────────────────────
    hl.exec_once("waybar")
    hl.exec_once("mako")
    hl.exec_once("hyprpaper")

    -- ── Keybindings ─────────────────────────────────────────────────────────
    local SUPER = "SUPER"

    hl.bind(SUPER, "Return", "exec", "ghostty")
    hl.bind(SUPER, "Q",      "killactive")
    hl.bind(SUPER, "M",      "exit")
    hl.bind(SUPER, "E",      "exec", "nautilus")
    hl.bind(SUPER, "F",      "fullscreen", 0)
    hl.bind(SUPER, "Space",  "exec", "rofi -show drun")

    -- Screenshot
    hl.bind("",      "Print",  "exec", "grim ~/Pictures/screenshot-$(date +%s).png")
    hl.bind("SHIFT", "Print",  "exec", "grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png")

    -- Focus
    hl.bind(SUPER, "H", "movefocus", "l")
    hl.bind(SUPER, "L", "movefocus", "r")
    hl.bind(SUPER, "K", "movefocus", "u")
    hl.bind(SUPER, "J", "movefocus", "d")

    -- Move windows
    hl.bind(SUPER .. "SHIFT", "H", "movewindow", "l")
    hl.bind(SUPER .. "SHIFT", "L", "movewindow", "r")
    hl.bind(SUPER .. "SHIFT", "K", "movewindow", "u")
    hl.bind(SUPER .. "SHIFT", "J", "movewindow", "d")

    -- Resize
    hl.bind(SUPER .. "CTRL", "H", "resizeactive", "-40 0")
    hl.bind(SUPER .. "CTRL", "L", "resizeactive",  "40 0")
    hl.bind(SUPER .. "CTRL", "K", "resizeactive", "0 -40")
    hl.bind(SUPER .. "CTRL", "J", "resizeactive", "0  40")

    -- Toggle floating / pseudo-tile
    hl.bind(SUPER, "V", "togglefloating")
    hl.bind(SUPER, "P", "pseudo")
    hl.bind(SUPER, "T", "togglesplit")

    -- Workspaces 1–9
    for i = 1, 9 do
      hl.bind(SUPER,          tostring(i), "workspace",       i)
      hl.bind(SUPER.."SHIFT", tostring(i), "movetoworkspace", i)
    end

    -- Mouse bindings
    hl.bindm(SUPER, "mouse:272", "movewindow")
    hl.bindm(SUPER, "mouse:273", "resizewindow")

    -- ── Window rules ────────────────────────────────────────────────────────
    hl.windowrulev2("float",  "class:^(nm-connection-editor)$")
    hl.windowrulev2("float",  "class:^(pavucontrol)$")
    hl.windowrulev2("center", "class:^(nm-connection-editor)$")
  '';

  # ── Waybar ──────────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 30;
      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [ "network" "memory" "cpu" "pulseaudio" "tray" ];
      "clock" = {
        format = " {:%H:%M  %a %b %d}";
        tooltip-format = "{calendar}";
      };
      "cpu"    = { format = " {usage}%"; };
      "memory" = { format = " {}%"; };
      "network" = {
        format-wifi = " {essid}";
        format-ethernet = " {ipaddr}";
        format-disconnected = "⚠ Disconnected";
      };
      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-icons = { default = [ "" "" "" ]; };
        on-click = "pavucontrol";
      };
    }];
    style = ''
      * { font-family: "JetBrainsMono Nerd Font"; font-size: 13px; }
      window#waybar { background: rgba(30,30,46,0.92); color: #cdd6f4; }
      #workspaces button { padding: 0 6px; color: #6c7086; }
      #workspaces button.active { color: #cba6f7; border-bottom: 2px solid #cba6f7; }
      #clock, #cpu, #memory, #network, #pulseaudio, #tray {
        padding: 0 10px; color: #cdd6f4;
      }
    '';
  };

  # ── Mako notifications ───────────────────────────────────────────────────── 
  services.mako = {
    enable = true;
    backgroundColor = "#1e1e2e";
    borderColor = "#cba6f7";
    textColor = "#cdd6f4";
    borderRadius = 8;
    defaultTimeout = 5000;
  };

  # ── GTK theming ──────────────────────────────────────────────────────────── 
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      size = 24;
    };
  };

  programs.home-manager.enable = true;
}
