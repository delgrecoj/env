# core GUI environment; strictly non-machine-specific things that do not work from a TTY.
{ config, lib, pkgs, ... }:
let

  bspwmrcfile = builtins.readFile ../dotfiles/bspwmrc;
  bspwmrc = pkgs.writeScript "bspwmrc" "${bspwmrcfile}";

in {
  imports = [
    ./chromium.nix
  ];

  environment = {
    systemPackages = [
      # FIXME: dunst.
      # pkgs.libreoffice
      # pkgs.obs-studio
      # pkgs.xfce.thunar
      # pkgs.xfce.tumbler
      pkgs.alacritty
      pkgs.arc-icon-theme
      pkgs.bemenu
      pkgs.chromium
      pkgs.ffmpeg
      pkgs.firefox
      pkgs.hsetroot
      pkgs.imv
      pkgs.lxappearance
      # pkgs.matcha-gtk-theme
      pkgs.mpv
      pkgs.pavucontrol
      pkgs.scrot
      pkgs.slock
      pkgs.sxiv
      pkgs.xclip
      pkgs.xorg.xmodmap
      pkgs.xorg.xset
      pkgs.youtube-dl
      pkgs.zathura
    ];
    etc."sxhkdrc".text = builtins.readFile ../dotfiles/sxhkdrc;
    # etc."alacritty".text = builtins.readFile ../dotfiles/alacritty;
  };

  fonts.fonts = [
    pkgs.iosevka-bin
    pkgs.dejavu_fonts
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  location = {
    # https://www.latlong.net/
    latitude = 41.646099;
    longitude = -80.147148;
  };

  services = {
    redshift = {
      enable = true;
      temperature = {
        day = 5500;
        night = 4200;
      };
    };
    unclutter = {
      enable = true;
    };
    xserver = {
      autoRepeatDelay = 300;
      autoRepeatInterval = 20;
      desktopManager = {
        xfce = {
          enable = false;
        };
      };
      displayManager = {
        sddm = {
          enable = true;
        };
        autoLogin = {
          enable = true;
          user = "nonroot";
        };
        sessionCommands = ''
          # xmodmap -e "keycode 9 = grave"
          # xmodmap -e "keycode 49 = asciitilde"
          hsetroot -solid '#000000'
          xset -dpms
          xset s 6000 6000
          xset s off
          xset s noblank
          xset s noexpose
        '';
      };
      enable = true;
      layout = "us";
      windowManager = {
        bspwm = {
          enable = true;
          configFile = "${bspwmrc}";
          sxhkd = {
            configFile = "/etc/sxhkdrc";
          };
        };
      };
      xkbOptions = "caps:escape";
    };
  };

  security = {
    wrappers = {
      slock = {
        source = "${pkgs.slock.out}/bin/slock";
      };
    };
  };
}
