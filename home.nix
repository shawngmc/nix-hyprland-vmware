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
    fd            # fast find — used by fzf Alt+C widget
    fzf           # fuzzy finder — shell integration configured via programs.fzf below

    # Zsh plugins (sourced via programs.zsh.plugins)
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search

    # Data / text processing
    yq            # jq for YAML/JSON/TOML
    q             # SQL on CSV files
    fx            # interactive JSON viewer
    bat           # cat with syntax highlighting — configured via programs.bat below
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
    neovim        # modal editor — configured via programs.neovim below

    # Kubernetes / containers
    kubectl       # k8s CLI
    k9s           # TUI k8s dashboard
    dive          # explore Docker image layers
    crane         # container registry CLI

    # Development
    uv            # fast Python package manager
    hyperfine     # CLI benchmarking tool
    f2            # bulk file renamer
    delta         # better git diffs — configured via programs.git below

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
    bluetuith     # TUI bluetooth manager (waybar bluetooth on-click)

    # Cloud / productivity
    gcalcli       # Google Calendar CLI
    wego          # terminal weather
    bitwarden-cli # Bitwarden CLI (bw)

    # Misc
    dcv           # CSV diff viewer
    flawz         # TUI CVE browser

  # ── Git ───────────────────────────────────────────────────────────────────── 
  programs.git = {
    enable = true;
    userName  = "Shawn McNaughton";
    userEmail = "shawngmc@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";

      # delta as pager
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";

      delta = {
        navigate    = true;   # n/N to move between diff sections
        dark        = true;
        line-numbers = true;
        side-by-side = false; # set true if you prefer side-by-side diffs
        syntax-theme = "catppuccin-mocha";
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";

      # Better defaults
      pull.rebase          = false;
      push.autoSetupRemote = true;
      fetch.prune          = true;
      rerere.enabled       = true;   # reuse recorded resolution for merge conflicts
    };

    aliases = {
      st   = "status -sb";
      lg   = "log --oneline --graph --decorate --all";
      undo = "reset HEAD~1 --mixed";
      wip  = "commit -am 'wip'";
      pushf = "push --force-with-lease";  # safer than --force
    };

    # delta for diffs
    delta = {
      enable = true;
      options = {
        navigate    = true;
        dark        = true;
        line-numbers = true;
        syntax-theme = "catppuccin-mocha";
        # Catppuccin Mocha colors for delta chrome
        plus-style           = "syntax #a6e3a1";
        plus-emph-style      = "syntax #40a02b";
        minus-style          = "syntax #f38ba8";
        minus-emph-style     = "syntax #d20f39";
        line-numbers-zero-style = "#6c7086";
        line-numbers-plus-style = "#a6e3a1";
        line-numbers-minus-style = "#f38ba8";
        file-style           = "bold #cba6f7";
        file-decoration-style = "#cba6f7 underline";
        hunk-header-style    = "file line-number syntax";
      };
    };
  };

  # ── Zsh ───────────────────────────────────────────────────────────────────── 
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";

    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.config/zsh/zsh_history";
      ignoreDups = true;
      ignoreSpace = true;  # lines starting with space are not saved
      extended = true;     # save timestamps
      share = true;        # share history across sessions
    };

    # Plugins — all available in nixpkgs, no external plugin manager needed
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];

    # Key bindings
    initExtra = ''
      # History substring search — bind to Up/Down arrows
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Better word navigation (Ctrl+Left/Right)
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # Edit command in $EDITOR with Ctrl+X Ctrl+E
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # Colored completion menu
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu select

      # fastfetch on new terminal (skip if in tmux/zellij to avoid spam)
      if [[ -z "$TMUX" && -z "$ZELLIJ" ]]; then
        fastfetch
      fi
    '';

    shellAliases = {
      # Better defaults
      ls    = "ls --color=auto";
      ll    = "ls -lah --color=auto";
      la    = "ls -A --color=auto";
      tree  = "tree -C";
      grep  = "grep --color=auto";
      diff  = "diff --color=auto";
      ip    = "ip --color=auto";

      # Use bat instead of cat
      cat   = "bat --paging=never";
      catp  = "bat";                 # bat with paging

      # Safer file ops
      cp    = "cp -iv";
      mv    = "mv -iv";
      rm    = "rm -iv";
      mkdir = "mkdir -pv";

      # Quick navigation
      ".."  = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Nix
      rebuild = "sudo nixos-rebuild switch --flake ~/.config/nixos#hypr-vmware";
      update  = "nix flake update ~/.config/nixos && sudo nixos-rebuild switch --flake ~/.config/nixos#hypr-vmware";
      cleanup = "sudo nix-collect-garbage -d";

      # Apps
      vi    = "nvim";
      vim   = "nvim";

      # Kubernetes
      k     = "kubectl";
      kns   = "kubectl config set-context --current --namespace";
    };
  };

  # ── fzf ───────────────────────────────────────────────────────────────────── 
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;   # Ctrl+R, Ctrl+T, Alt+C

    # Use ripgrep as the default find command — respects .gitignore
    defaultCommand = "rg --files --hidden --follow --glob '!.git'";
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--prompt=  "
      "--pointer= "
      "--marker= "
      # Catppuccin Mocha colors
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      "--color=selected-bg:#45475a"
    ];

    # Ctrl+T — file search using rg
    fileWidgetCommand = "rg --files --hidden --follow --glob '!.git'";
    fileWidgetOptions = [ "--preview 'bat --color=always --style=numbers {}'" ];

    # Alt+C — directory jump using fd
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [ "--preview 'ls --color=always {}'" ];

    # Ctrl+R — history search
    historyWidgetOptions = [ "--sort" "--exact" ];
  };

  # ── zoxide ────────────────────────────────────────────────────────────────── 
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    # Replaces cd — use 'z <dir>' to jump, 'zi' for interactive fzf picker
    options = [ "--cmd cd" ];  # makes 'cd' itself use zoxide
  };

  # ── bat ───────────────────────────────────────────────────────────────────── 
  programs.bat = {
    enable = true;
    config = {
      theme  = "catppuccin-mocha";
      style  = "numbers,changes,header";
      pager  = "less -FR";
    };
    themes = {
      catppuccin-mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo  = "bat";
          rev   = "699f60fc8ec434574ca7451b444b880430319941";
          hash  = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
  };

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
      layer    = "top";
      position = "top";
      height   = 32;
      spacing  = 4;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
        "hyprland/window"
      ];
      modules-center = [
        "mpris"
        "clock"
      ];
      modules-right = [
        "custom/updates"
        "custom/vpn"
        "bluetooth"
        "network"
        "battery"
        "disk"
        "memory"
        "cpu"
        "temperature"
        "pulseaudio"
        "idle_inhibitor"
        "systemd-failed-units"
        "custom/weather"
        "tray"
        "custom/notification"
      ];

      # ── Left modules ──────────────────────────────────────────────────────
      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          "1" = "󰎤"; "2" = "󰎧"; "3" = "󰎪"; "4" = "󰎭"; "5" = "󰎱";
          "6" = "󰎳"; "7" = "󰎶"; "8" = "󰎹"; "9" = "󰎼";
          urgent = ""; active = ""; default = "";
        };
        persistent-workspaces = { "*" = 5; };
      };

      "hyprland/submap" = {
        format = "<span style='italic'>{}</span>";
        tooltip = false;
      };

      "hyprland/window" = {
        max-length = 40;
        separate-outputs = true;
      };

      # ── Center modules ────────────────────────────────────────────────────
      "mpris" = {
        format = "{player_icon}  {title}";
        format-paused = "{player_icon}  <i>{title}</i>";
        format-stopped = "";
        player-icons = {
          default  = "▶";
          mpv      = "󰐊";
          firefox  = "󰈹";
          spotify  = "󰓇";
          chromium = "󰊯";
        };
        status-icons = {
          paused = "⏸";
        };
        max-length    = 40;
        on-click      = "playerctl play-pause";
        on-click-right = "playerctl next";
        on-scroll-up   = "playerctl volume 0.05+";
        on-scroll-down = "playerctl volume 0.05-";
        tooltip-format = "{title}\n{artist}\n{album}\n[{player}]";
      };

      "clock" = {
        format = "  {:%H:%M}";
        format-alt = "  {:%a %b %d %Y  %H:%M:%S}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        interval = 1;
      };

      # ── Right modules ─────────────────────────────────────────────────────
      "custom/updates" = {
        exec    = "nix flake metadata /etc/nixos --json 2>/dev/null | python3 -c \"import sys,json,subprocess; d=json.load(sys.stdin); locks=d.get('locks',{}).get('nodes',{}); print('󰚰  Updates') if any(v.get('locked',{}).get('lastModified',0) < v.get('original',{}).get('lastModified',0) for v in locks.values() if isinstance(v,dict)) else print('')\" 2>/dev/null || echo ''";
        interval = 3600;
        on-click = "foot -e sh -c 'nix flake update ~/.config/nixos && echo Done. Press enter to close. && read'";
        tooltip  = false;
      };

      "custom/vpn" = {
        exec    = "ip link show | grep -qE '^[0-9]+: (tun|wg|vpn|tailscale)[0-9]' && echo '󰦝  VPN' || echo ''";
        interval = 5;
        tooltip  = false;
      };

      "bluetooth" = {
        format          = "󰂯";
        format-disabled = "";
        format-connected = "󰂱  {device_alias}";
        format-connected-battery = "󰂱  {device_alias} {device_battery_percentage}%";
        on-click        = "foot -e bluetuith";
        tooltip-format  = "{controller_alias}\n{num_connections} connected\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}";
        tooltip-format-enumerate-connected-battery = "{device_alias} 🔋{device_battery_percentage}%";
      };

      "network" = {
        interval = 5;
        format-ethernet  = "󰈀  {ipaddr}";
        format-wifi      = "  {essid} ({signalStrength}%)";
        format-disconnected = "󰤭  Disconnected";
        format-linked    = "󰈀  {ifname} (no IP)";
        tooltip-format   = "{ifname}\n{ipaddr}/{cidr}\nUp: {bandwidthUpBits}  Down: {bandwidthDownBits}";
        on-click         = "foot -e nmtui";
      };

      "battery" = {
        interval  = 30;
        states    = { warning = 30; critical = 15; };
        format    = "{icon}  {capacity}%";
        format-charging = "󰂄  {capacity}%";
        format-plugged  = "󰚥  {capacity}%";
        format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format  = "{timeTo}\nPower: {power}W";
      };

      "disk" = {
        interval = 30;
        format   = "󰋊  {percentage_used}%";
        path     = "/";
        tooltip-format = "{used} / {total} used ({percentage_used}%)";
        on-click = "foot -e btop";
      };

      "memory" = {
        interval = 5;
        format   = "󰍛  {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G used\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G";
        on-click = "foot -e btop";
        warning  = 75;
        critical = 90;
      };

      "cpu" = {
        interval = 2;
        format   = "  {usage}%";
        tooltip-format = "CPU: {usage}%\nLoad: {load}";
        on-click = "foot -e btop";
      };

      "temperature" = {
        interval      = 5;
        format        = "  {temperatureC}°C";
        format-critical = "  {temperatureC}°C";
        critical-threshold = 80;
        tooltip        = true;
      };

      "pulseaudio" = {
        format        = "{icon}  {volume}%";
        format-muted  = "󰝟  Muted";
        format-icons  = {
          headphone  = "";
          headset    = "󰋎";
          default    = [ "󰕿" "󰖀" "󰕾" ];
        };
        scroll-step   = 5;
        on-click      = "pavucontrol";
        on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        tooltip-format = "{desc}\nVolume: {volume}%";
      };

      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated   = "󰒳";
          deactivated = "󰒲";
        };
        tooltip-format-activated   = "Idle inhibitor: ON";
        tooltip-format-deactivated = "Idle inhibitor: OFF";
      };

      "systemd-failed-units" = {
        format          = "󱚡  {nr_failed}";
        format-ok       = "";
        on-click        = "foot -e sh -c 'systemctl --failed; read'";
        hide-on-ok      = true;
        system          = true;
        user            = true;
      };

      "custom/weather" = {
        exec    = "wego 1 2>/dev/null | head -7 | tail -1 | tr -s ' ' | cut -d' ' -f2-5 2>/dev/null || echo '󰖔'";
        interval = 1800;
        on-click = "foot -e wego";
        tooltip  = false;
      };

      "tray" = {
        icon-size = 16;
        spacing   = 8;
      };

      "custom/notification" = {
        exec         = "makoctl list | python3 -c \"import sys,json; d=json.load(sys.stdin); n=sum(len(g['notifications']) for g in d.get('groups',[])); print(('󱅫  '+str(n)) if n>0 else '󰂚')\" 2>/dev/null || echo '󰂚'";
        interval     = 3;
        on-click     = "makoctl dismiss --all";
        on-click-right = "makoctl restore";
        tooltip      = false;
      };
    }];

    style = ''
      * {
        font-family: "RobotoMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.92);
        color: #cdd6f4;
        border-bottom: 2px solid rgba(49, 50, 68, 0.8);
      }

      /* ── Workspaces ── */
      #workspaces button {
        padding: 0 6px;
        color: #6c7086;
        border-bottom: 2px solid transparent;
        transition: all 0.2s ease;
      }
      #workspaces button:hover {
        color: #cdd6f4;
        background: rgba(49, 50, 68, 0.5);
      }
      #workspaces button.active {
        color: #cba6f7;
        border-bottom: 2px solid #cba6f7;
      }
      #workspaces button.urgent {
        color: #f38ba8;
        border-bottom: 2px solid #f38ba8;
      }

      /* ── Submap ── */
      #submap {
        padding: 0 10px;
        color: #f9e2af;
        font-style: italic;
      }

      /* ── Window title ── */
      #window {
        padding: 0 10px;
        color: #a6adc8;
      }

      /* ── MPRIS ── */
      #mpris {
        padding: 0 12px;
        color: #a6e3a1;
      }

      /* ── Clock ── */
      #clock {
        padding: 0 14px;
        color: #89b4fa;
        font-weight: bold;
      }

      /* ── Right modules — shared ── */
      #custom-updates,
      #custom-vpn,
      #bluetooth,
      #network,
      #battery,
      #disk,
      #memory,
      #cpu,
      #temperature,
      #pulseaudio,
      #idle_inhibitor,
      #systemd-failed-units,
      #custom-weather,
      #tray,
      #custom-notification {
        padding: 0 10px;
        color: #cdd6f4;
      }

      /* ── Per-module accent colors ── */
      #custom-updates  { color: #f9e2af; }
      #custom-vpn      { color: #a6e3a1; }
      #bluetooth       { color: #89b4fa; }
      #network         { color: #89dceb; }
      #battery         { color: #a6e3a1; }
      #disk            { color: #a6e3a1; }
      #memory          { color: #cba6f7; }
      #cpu             { color: #89b4fa; }
      #temperature     { color: #fab387; }
      #pulseaudio      { color: #f5c2e7; }
      #custom-weather  { color: #89dceb; }

      /* ── Warning / critical states ── */
      #memory.warning,
      #cpu.warning          { color: #f9e2af; }
      #memory.critical,
      #cpu.critical         { color: #f38ba8; }
      #temperature.critical { color: #f38ba8; }
      #battery.warning      { color: #f9e2af; }
      #battery.critical     { color: #f38ba8; }

      /* ── Systemd failed — only visible when non-zero ── */
      #systemd-failed-units { color: #f38ba8; }

      /* ── Idle inhibitor ── */
      #idle_inhibitor.activated { color: #a6e3a1; }

      /* ── Tray ── */
      #tray { padding: 0 8px; }
      #tray > .passive  { -gtk-icon-effect: dim; }
      #tray > .needs-attention { -gtk-icon-effect: highlight; }
    '';
  };

  # ── direnv ────────────────────────────────────────────────────────────────── 
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;   # nix-direnv: faster, cached nix shell evaluation
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

        # Privacy & telemetry
        "privacy.donottrackheader.enabled" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.enabled" = false;
        "browser.urlbar.trending.featureGate" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
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

  # ── Neovim ────────────────────────────────────────────────────────────────── 
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias  = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # ── Colorscheme ─────────────────────────────────────────────────────────
      {
        plugin = catppuccin-nvim;
        config = ''
          lua << EOF
          require("catppuccin").setup({
            flavour = "mocha",
            background = { dark = "mocha" },
            integrations = {
              treesitter = true,
              native_lsp = { enabled = true },
              telescope  = { enabled = true },
              cmp        = true,
            },
          })
          vim.cmd("colorscheme catppuccin-mocha")
          EOF
        '';
      }

      # ── Treesitter ──────────────────────────────────────────────────────────
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
          lua << EOF
          require("nvim-treesitter.configs").setup({
            highlight    = { enable = true },
            indent       = { enable = true },
            auto_install = false,  -- grammars provided by nix
          })
          EOF
        '';
      }

      # ── LSP ─────────────────────────────────────────────────────────────────
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          local lsp = require("lspconfig")

          -- Common on_attach: keybindings active when LSP attaches to a buffer
          local on_attach = function(_, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      opts)
            vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,     opts)
            vim.keymap.set("n", "gr",         vim.lsp.buf.references,      opts)
            vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,  opts)
            vim.keymap.set("n", "K",          vim.lsp.buf.hover,           opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,     opts)
            vim.keymap.set("n", "<leader>f",  vim.lsp.buf.format,          opts)
            vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,    opts)
            vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,    opts)
          end

          -- Add language servers here as needed.
          -- Each requires the server binary on PATH (install via home.packages).
          -- Examples (uncomment + add package to home.packages):
          -- lsp.lua_ls.setup({ on_attach = on_attach })
          -- lsp.nixd.setup({ on_attach = on_attach })
          -- lsp.pyright.setup({ on_attach = on_attach })
          -- lsp.rust_analyzer.setup({ on_attach = on_attach })
          -- lsp.ts_ls.setup({ on_attach = on_attach })
          -- lsp.yamlls.setup({ on_attach = on_attach })
          -- lsp.bashls.setup({ on_attach = on_attach })
          EOF
        '';
      }

      # ── nvim-cmp (autocompletion) ────────────────────────────────────────── 
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      {
        plugin = nvim-cmp;
        config = ''
          lua << EOF
          local cmp     = require("cmp")
          local luasnip = require("luasnip")

          cmp.setup({
            snippet = {
              expand = function(args) luasnip.lsp_expand(args.body) end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
              ["<C-f>"]     = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"]     = cmp.mapping.abort(),
              ["<CR>"]      = cmp.mapping.confirm({ select = false }),
              ["<Tab>"]     = cmp.mapping(function(fallback)
                if cmp.visible() then cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                else fallback() end
              end, { "i", "s" }),
              ["<S-Tab>"]   = cmp.mapping(function(fallback)
                if cmp.visible() then cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                else fallback() end
              end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip"  },
            }, {
              { name = "buffer" },
              { name = "path"   },
            }),
          })

          -- Completion for / search
          cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
          })

          -- Completion for : commands
          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
              { { name = "path" } },
              { { name = "cmdline" } }
            ),
          })

          -- Wire cmp capabilities into lspconfig
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          -- Pass capabilities to each lsp.XXX.setup() call above
          _ = capabilities  -- referenced by lspconfig setups when uncommented
          EOF
        '';
      }

      # ── Telescope ───────────────────────────────────────────────────────────
      plenary-nvim   # telescope dependency
      {
        plugin = telescope-nvim;
        config = ''
          lua << EOF
          local telescope = require("telescope")
          local builtin   = require("telescope.builtin")

          telescope.setup({
            defaults = {
              prompt_prefix  = "  ",
              selection_caret = " ",
              path_display   = { "truncate" },
              sorting_strategy = "ascending",
              layout_config  = {
                horizontal = { prompt_position = "top", preview_width = 0.55 },
              },
            },
          })

          -- Keybindings
          local opts = { noremap = true, silent = true }
          vim.keymap.set("n", "<leader>ff", builtin.find_files,    opts)  -- find files
          vim.keymap.set("n", "<leader>fg", builtin.live_grep,     opts)  -- live grep
          vim.keymap.set("n", "<leader>fb", builtin.buffers,       opts)  -- buffers
          vim.keymap.set("n", "<leader>fh", builtin.help_tags,     opts)  -- help
          vim.keymap.set("n", "<leader>fd", builtin.diagnostics,   opts)  -- diagnostics
          vim.keymap.set("n", "<leader>fr", builtin.lsp_references,opts)  -- LSP refs
          vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, opts)
          EOF
        '';
      }
    ];

    # Base vim options
    extraConfig = ''
      " Leader key
      let mapleader = " "

      " UI
      set number
      set relativenumber
      set cursorline
      set signcolumn=yes
      set scrolloff=8
      set sidescrolloff=8
      set wrap=off
      set colorcolumn=100

      " Indentation
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set smartindent

      " Search
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch

      " Split behaviour
      set splitright
      set splitbelow

      " Misc
      set termguicolors
      set undofile
      set updatetime=250
      set timeoutlen=300
      set clipboard=unnamedplus   " use system clipboard
    '';
  };

  # ── XDG user directories ──────────────────────────────────────────────────── 
  xdg.userDirs = {
    enable     = true;
    createDirectories = true;
    desktop    = "$HOME/Desktop";
    documents  = "$HOME/Documents";
    download   = "$HOME/Downloads";
    music      = "$HOME/Music";
    pictures   = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates  = "$HOME/Templates";
    videos     = "$HOME/Videos";
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
