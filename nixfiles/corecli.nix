# core CLI environment; strictly non-machine-specific things that work from a TTY.
{ config, lib, pkgs, ... }:
{
  console = {
    colors = [
      # FIXME: match the alacritty ones.
      "000000" "c2454e" "7cbf9e" "8a7a63"
      "91879d" "ff5879" "44b5b1" "aaaaaa"
      "707070" "ef5847" "a2d9b1" "beb090"
      "8197ad" "ff99a1" "9ed9d8" "eeeeee"
    ];
    earlySetup = true;
  };

  environment = {
    systemPackages = [
      (with import <nixpkgs> {};
      vim_configurable.customize {
        name = "vim";
        vimrcConfig = {
          customRC = builtins.readFile ../dotfiles/vimrc;
        };
      })
      pkgs.age
      pkgs.arp-scan
      pkgs.bash
      pkgs.bashCompletion
      pkgs.bashInteractive
      pkgs.bat
      pkgs.binutils
      pkgs.bzip2
      pkgs.coreutils
      pkgs.curl
      pkgs.dos2unix
      pkgs.editorconfig-core-c
      pkgs.elixir
      pkgs.entr
      pkgs.exa
      pkgs.fd
      pkgs.file
      pkgs.findutils
      pkgs.fzf
      pkgs.git
      pkgs.gnugrep
      pkgs.gnumake
      pkgs.gnupg
      pkgs.gnused
      pkgs.gnutar
      pkgs.gzip
      pkgs.htop
      pkgs.less
      pkgs.lm_sensors
      pkgs.micro
      pkgs.mkcert
      pkgs.mkpasswd
      pkgs.nix
      pkgs.openssh
      pkgs.p7zip
      pkgs.parted
      pkgs.pass
      pkgs.pinentry
      pkgs.psmisc
      pkgs.ripgrep
      pkgs.rsync
      pkgs.sd
      pkgs.shellcheck
      pkgs.tig
      pkgs.tldr
      pkgs.tmux
      pkgs.tokei
      pkgs.traceroute
      pkgs.tree
      pkgs.unixtools.ping
      pkgs.unzip
      pkgs.watch
      pkgs.which
      pkgs.zip

      # pkgs.apg
      # pkgs.cvs
      # pkgs.dash
      # pkgs.elvish
      # pkgs.fdupes
      # pkgs.fish
      # pkgs.hdparm
      # pkgs.hyperfine
      # pkgs.iftop
      # pkgs.imagemagick
      # pkgs.iotop
      # pkgs.iperf3
      # pkgs.jo
      # pkgs.jq
      # pkgs.ksh
      # pkgs.lnav
      # pkgs.lrzip
      # pkgs.mercurial
      # pkgs.ncat
      # pkgs.nmap
      # pkgs.pandoc
      # pkgs.pv
      # pkgs.ruby
      # pkgs.screen
      # pkgs.scrypt
      # pkgs.speedtest-cli
      # pkgs.subversion
      # pkgs.tcsh
      # pkgs.wget
      # pkgs.ws
      # pkgs.xsv
      # pkgs.zsh
    ];
    etc."bashrc.local".text = builtins.readFile ../dotfiles/bashrc;
    etc."gitconfig".text = builtins.readFile ../dotfiles/gitconfig;
    etc."htoprc".text = builtins.readFile ../dotfiles/htoprc;
    etc."tmux.conf".text = builtins.readFile ../dotfiles/tmuxconf;
  };

  programs = {
    ssh = {
      startAgent = true;
    };
    gnupg = {
      agent = {
        enable = true;
        pinentryFlavor = "curses";
      };
    };
  };
}
