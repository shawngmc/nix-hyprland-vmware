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
    fuzzel

    # Status bar
    waybar

    # Notifications
    mako
    libnotify

    # Terminal — foot is Wayland-native, no GL context issues
    foot

    # Browser — managed via programs.firefox, listed here for clarity
    firefox

    # Fonts
    nerd-fonts.roboto-mono
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

    # File manager
    nautilus

    # ── CLI tools ─────────────────────────────────────────────────────────────
    # System monitoring
    btop          # htop alternative with graphs
    procs         # modern ps replacement
    iftop         # network bandwidth by connection
    iotop         # disk I/O monitor
    lshw          # hardware info
    nload         # network traffic monitor
    gping         # ping with graph

    # Search / grep
    ripgrep       # rg — fast grep
    ripgrep-all   # rga — ripgrep over PDFs, zip, etc.
    ugrep         # feature-rich grep alternative
    fzf           # fuzzy finder

    # Data / text processing
    yq            # jq for YAML/JSON/TOML
    q             # SQL on CSV files
    fx            # interactive JSON viewer
    bat           # cat with syntax highlighting
    xan           # CSV toolkit
    visidata      # TUI spreadsheet / data explorer
    lnav          # log file navigator
    pspg          # pager for tabular data (psql, etc.)
    dhex          # hex editor

    # Terminal multiplexers
    zellij        # modern tmux alternative
    tmux          # classic multiplexer

    # File managers (TUI)
    yazi          # modern TUI file manager
    nnn           # minimal TUI file manager

    # Media
    mpv           # video player
    yt-dlp        # video downloader
    asciinema     # terminal session recorder
    vhs           # terminal GIF recorder

    # Shell / prompt — configured via programs.starship below
    fastfetch     # system info / neofetch alternative

    # Editors
    neovim        # modal editor

    # Kubernetes / containers
    kubectl       # k8s CLI
    k9s           # TUI k8s dashboard
    dive          # explore Docker image layers
    crane         # container registry CLI

    # Development
    uv            # fast Python package manager
    hyperfine     # CLI benchmarking tool
    f2            # bulk file renamer

    # Network / security
    doggo         # modern dig alternative
    ssh-audit     # SSH server auditing
    testssl       # TLS/SSL testing
    w3m           # terminal web browser

    # Docs / help
    tealdeer      # tldr pages (fast Rust client)

    # Email / comms
    aerc          # TUI email client
    discordo      # TUI Discord client

    # Cloud / productivity
    gcalcli       # Google Calendar CLI
    wego          # terminal weather
    bitwarden-cli # Bitwarden CLI (bw)

    # Misc
    dcv           # CSV diff viewer
    flawz         # TUI CVE browser

  # ── Foot terminal ─────────────────────────────────────────────────────────── 
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "RobotoMono Nerd Font:size=13";
      };
      colors = {
        # Catppuccin Mocha
        background = "1e1e2e";
        foreground = "cdd6f4";
        regular0   = "45475a";  # black
        regular1   = "f38ba8";  # red
        regular2   = "a6e3a1";  # green
        regular3   = "f9e2af";  # yellow
        regular4   = "89b4fa";  # blue
        regular5   = "f5c2e7";  # magenta
        regular6   = "94e2d5";  # cyan
        regular7   = "bac2de";  # white
        bright0    = "585b70";
        bright1    = "f38ba8";
        bright2    = "a6e3a1";
        bright3    = "f9e2af";
        bright4    = "89b4fa";
        bright5    = "f5c2e7";
        bright6    = "94e2d5";
        bright7    = "a6adc8";
      };
    };
  };

  # ── Fuzzel launcher ──────────────────────────────────────────────────────── 
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "RobotoMono Nerd Font:size=13";
        terminal = "foot";
        layer = "overlay";
        width = 35;
        lines = 10;
        border-radius = 8;
      };
      colors = {
        # Catppuccin Mocha
        background = "1e1e2eff";
        text       = "cdd6f4ff";
        match      = "cba6f7ff";
        selection   = "313244ff";
        selection-text = "cdd6f4ff";
        selection-match = "cba6f7ff";
        border     = "cba6f7ff";
      };
    };
  };
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

    hl.bind(SUPER, "Return", "exec", "foot")
    hl.bind(SUPER, "B",      "exec", "firefox")
    hl.bind(SUPER, "Q",      "killactive")
    hl.bind(SUPER, "M",      "exit")
    hl.bind(SUPER, "E",      "exec", "nautilus")
    hl.bind(SUPER, "F",      "fullscreen", 0)
    hl.bind(SUPER, "Space",  "exec", "fuzzel")

    -- Screenshot
    hl.bind("",             "Print", "exec", "grim ~/Pictures/screenshot-$(date +%s).png")
    hl.bind("SHIFT",        "Print", "exec", "grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png")
    hl.bind(SUPER.."SHIFT", "S",     "exec", "f=~/Pictures/screenshot-$(date +%s).png; grim -g \"$(slurp)\" \"$f\" && wl-copy < \"$f\"")

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
      * { font-family: "RobotoMono Nerd Font"; font-size: 13px; }
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
    font = "RobotoMono Nerd Font 13";
    backgroundColor = "#1e1e2e";
    borderColor = "#cba6f7";
    textColor = "#cdd6f4";
    borderRadius = 8;
    defaultTimeout = 5000;
  };

  # ── GTK theming ──────────────────────────────────────────────────────────── 
  gtk = {
    enable = true;
    font = {
      name = "RobotoMono Nerd Font";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
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

  # Force dark color-scheme preference — picked up by GTK4, libadwaita, and
  # any app that respects the FreeDesktop color-scheme portal setting
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "catppuccin-mocha-mauve-standard";
    };
  };

  # ── Firefox ──────────────────────────────────────────────────────────────── 
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # Wayland native rendering
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.use-xdg-desktop-portal.file-picker" = 1;

        # Enable userChrome.css and userContent.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # Force dark color scheme — tells websites to use dark mode too
        "layout.css.prefers-color-scheme.content-override" = 0;

        # UI
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.startup.page" = 3;           # restore previous session
        "browser.shell.checkDefaultBrowser" = false;
        "browser.tabs.inTitlebar" = 0;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
      };

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
      ];

      # ── userChrome.css — browser chrome theming ───────────────────────────
      userChrome = ''
        /* ── Catppuccin Mocha palette ── */
        :root {
          --ctp-base:    #1e1e2e;
          --ctp-mantle:  #181825;
          --ctp-crust:   #11111b;
          --ctp-surface0:#313244;
          --ctp-surface1:#45475a;
          --ctp-surface2:#585b70;
          --ctp-overlay0:#6c7086;
          --ctp-text:    #cdd6f4;
          --ctp-subtext: #a6adc8;
          --ctp-mauve:   #cba6f7;
          --ctp-blue:    #89b4fa;
          --ctp-red:     #f38ba8;

          /* Apply RobotoMono to all browser UI */
          --font-body: "RobotoMono Nerd Font", monospace !important;
        }

        /* ── Toolbar / nav bar ── */
        #navigator-toolbox,
        #toolbar-menubar,
        #TabsToolbar,
        #nav-bar,
        #PersonalToolbar {
          background-color: var(--ctp-mantle) !important;
          color: var(--ctp-text) !important;
          border-color: var(--ctp-surface0) !important;
          font-family: "RobotoMono Nerd Font", monospace !important;
        }

        /* ── URL bar ── */
        #urlbar,
        #urlbar-background {
          background-color: var(--ctp-surface0) !important;
          color: var(--ctp-text) !important;
          border-color: var(--ctp-mauve) !important;
          font-family: "RobotoMono Nerd Font", monospace !important;
        }

        #urlbar:focus-within > #urlbar-background {
          border-color: var(--ctp-blue) !important;
          box-shadow: 0 0 0 1px var(--ctp-blue) !important;
        }

        /* ── Tabs ── */
        :root { --tab-min-height: 28px !important; }

        .tabbrowser-tab[selected] .tab-background {
          background-color: var(--ctp-base) !important;
        }

        .tabbrowser-tab:not([selected]) .tab-background:hover {
          background-color: var(--ctp-surface0) !important;
        }

        .tab-label {
          color: var(--ctp-text) !important;
          font-family: "RobotoMono Nerd Font", monospace !important;
        }

        /* ── Sidebar ── */
        #sidebar-box {
          background-color: var(--ctp-mantle) !important;
          color: var(--ctp-text) !important;
        }

        /* ── Context menus ── */
        menupopup,
        panel {
          background-color: var(--ctp-surface0) !important;
          color: var(--ctp-text) !important;
          border-color: var(--ctp-surface1) !important;
          font-family: "RobotoMono Nerd Font", monospace !important;
        }

        menuitem:hover {
          background-color: var(--ctp-surface1) !important;
          color: var(--ctp-mauve) !important;
        }

        /* ── Hide tab bar when only one tab open ── */
        #tabbrowser-tabs[closebuttons="activetab"] .tabbrowser-tab:only-of-type,
        #tabbrowser-tabs[closebuttons="activetab"] .tabbrowser-tab:only-of-type ~ .tabbrowser-tab {
          visibility: collapse;
        }
      '';

      # ── userContent.css — webpage-level overrides ─────────────────────────
      userContent = ''
        /* Apply RobotoMono as default monospace font for web pages */
        :root {
          --monospace-font: "RobotoMono Nerd Font", monospace !important;
        }

        /* Firefox new tab page — dark background */
        @-moz-document url("about:home"), url("about:newtab"), url("about:blank") {
          body {
            background-color: #1e1e2e !important;
            color: #cdd6f4 !important;
          }
        }
      '';
    };
  };

  # ── Starship prompt ──────────────────────────────────────────────────────── 
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$kubernetes"
        "$python"
        "$nodejs"
        "$rust"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      character = {
        success_symbol = "[❯](mauve)";
        error_symbol   = "[❯](red)";
        vimcmd_symbol  = "[❮](green)";
      };

      directory = {
        style = "bold blue";
        truncation_length = 4;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        style  = "mauve";
      };

      git_status = {
        style    = "red";
        ahead    = "⇡$count";
        behind   = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        modified = "!$count";
        untracked = "?$count";
        staged   = "+$count";
        deleted  = "✘$count";
      };

      kubernetes = {
        disabled = false;
        symbol   = "☸ ";
        style    = "blue";
        contexts = [];
      };

      cmd_duration = {
        min_time = 2000;
        format   = "took [$duration](yellow) ";
      };

      nix_shell = {
        symbol = " ";
        style  = "blue";
        format = "[$symbol$state]($style) ";
      };

      python = {
        symbol = " ";
        style  = "yellow";
      };

      nodejs = {
        symbol = " ";
        style  = "green";
      };

      rust = {
        symbol = " ";
        style  = "red";
      };

      # Catppuccin Mocha palette for starship
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo  = "#f2cdcd";
        pink      = "#f5c2e7";
        mauve     = "#cba6f7";
        red       = "#f38ba8";
        maroon    = "#eba0ac";
        peach     = "#fab387";
        yellow    = "#f9e2af";
        green     = "#a6e3a1";
        teal      = "#94e2d5";
        sky       = "#89dceb";
        sapphire  = "#74c7ec";
        blue      = "#89b4fa";
        lavender  = "#b4befe";
        text      = "#cdd6f4";
        subtext1  = "#bac2de";
        subtext0  = "#a6adc8";
        overlay2  = "#9399b2";
        overlay1  = "#7f849c";
        overlay0  = "#6c7086";
        surface2  = "#585b70";
        surface1  = "#45475a";
        surface0  = "#313244";
        base      = "#1e1e2e";
        mantle    = "#181825";
        crust     = "#11111b";
      };
    };
  };

  programs.home-manager.enable = true;
}
