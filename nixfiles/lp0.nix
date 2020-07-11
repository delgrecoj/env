# device: Lenovo IdeaPad S940
# initial install: 2020-07-08

{ config, lib, pkgs, ... }:
let

  notsecret = {
    trustedCerts = {
      pfSenseInternalCA = builtins.readFile ../notsecret/pfsense-internal-CA.crt;
      pfSenseIntermediateCA = builtins.readFile ../notsecret/pfsense-intermediate-CA.crt;
    };
    sshPubKeys = {
      rootPubKey = builtins.readFile ../notsecret/lp0_root.pub;
      nonrootPubKey = builtins.readFile ../notsecret/lp0_nonroot.pub;
    };
  };

in {
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./corecli.nix
    ./coregui.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "elevator=none" ]; # ZFS perf thing.
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-partuuid";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r zpuddle/ephem/root@blank
  '';
  systemd.tmpfiles.rules = [
    "L /etc/nixos/configuration.nix - - - - /_projects/env/nixfiles/lp0.nix"
    "L /nonroot/.ssh - - - - /_projects/secrets/ssh"
    "L /nonroot/.gnupg - - - - /_projects/secrets/gnupg"
    "L /nonroot/.password-store - - - - /_projects/secrets/pass"
    "L /root/.ssh - - - - /_projects/secrets/ssh"
    "L /root/.gnupg - - - - /_projects/secrets/gnupg"
    "L /root/.password-store - - - - /_projects/secrets/pass"
  ];

  fileSystems."/" = { device = "zpuddle/ephem/root"; fsType = "zfs"; };
  fileSystems."/nix" = { device = "zpuddle/ephem/nix"; fsType = "zfs"; };
  fileSystems."/_backups" = { device = "zpuddle/persist/backups"; fsType = "zfs"; };
  fileSystems."/_deprecated" = { device = "zpuddle/persist/deprecated"; fsType = "zfs"; };
  fileSystems."/_docker" = { device = "zpuddle/persist/docker"; fsType = "zfs"; };
  fileSystems."/_dockervols" = { device = "zpuddle/persist/dockervols"; fsType = "zfs"; };
  fileSystems."/_projects" = { device = "zpuddle/persist/projects"; fsType = "zfs"; };
  fileSystems."/_scratch" = { device = "zpuddle/persist/scratch"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/09A5-F2E5"; fsType = "vfat"; };

  swapDevices = [
    { device = "/dev/disk/by-uuid/5dd28c11-91fb-4e64-b242-a61878d2896c"; }
  ];

  nix.maxJobs = lib.mkDefault 8;
  nixpkgs.config.allowUnfree = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  console = {
    useXkbConfig = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v22b.psf.gz";
  };

  time.timeZone = "America/New_York";






  environment.systemPackages = [
    pkgs.light
    pkgs.vanilla-dmz
  ];
  environment.etc."alacritty".text = builtins.readFile ../dotfiles/alacritty_smaller;

  networking.hostName = "lp0";
  networking.hostId = "01234567"; # FIXME # ZFS req.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # friendlier wireless support than wpa_supplicant; use nmcli/nmtui.
  networking.networkmanager.enable = true;

  # allow incoming 80/443 for testing/demo purposes.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [80 443];






  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      permitRootLogin = "prohibit-password";
      ports = [55000];
    };
    xserver = {
      dpi = 168;
      # FIXME: trackpad is unreliable, sometimes works after boot sometimes doesn't.
      # (using keynav for one-off clicks you need on GUI elements, slow but works)
      libinput.enable = true;
      libinput.dev = "/dev/input/event*";
      synaptics.enable = false;
    };
  };

  security = {
    pki = {
      certificates = [
        notsecret.trustedCerts.pfSenseInternalCA
        notsecret.trustedCerts.pfSenseIntermediateCA
      ];
    };
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = "--data-root=/_docker";
  };

  hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;

  # nix-env -i mkpasswd; mkpasswd -m sha-512 -s >> /_projects/secrets/shadow/passwd_lp0_root
  # nix-env -i mkpasswd; mkpasswd -m sha-512 -s >> /_projects/secrets/shadow/passwd_lp0_nonroot
  # must mark the mount as needed on boot; see above.
  users = {
    mutableUsers = false;
    users = {
      nonroot = {
        isNormalUser = true;
        home = "/nonroot";
        extraGroups = [ "wheel" "audio" "docker" ];
        passwordFile = "/_projects/secrets/shadow/passwd_lp0_nonroot";
        openssh = {
          authorizedKeys = {
            keys = [
              notsecret.sshPubKeys.nonrootPubKey
            ];
          };
        };
      };
      root = {
        extraGroups = [ "audio" "docker" ];
        passwordFile = "/_projects/secrets/shadow/passwd_lp0_root";
        openssh = {
          authorizedKeys = {
            keys = [
              notsecret.sshPubKeys.rootPubKey
            ];
          };
        };
      };
    };
  };

  system.stateVersion = "20.03";
}
