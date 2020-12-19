{ config, lib, pkgs, ... }:
let

  notsecret = {
    trustedCerts = {
      pfSenseInternalCA = builtins.readFile ../notsecret/pfsense-internal-CA.crt;
      pfSenseIntermediateCA = builtins.readFile ../notsecret/pfsense-intermediate-CA.crt;
    };
    sshPubKeys = {
      rootPubKey = builtins.readFile ../notsecret/ws0_root.pub;
      nonrootPubKey = builtins.readFile ../notsecret/ws0_nonroot.pub;
    };
  };

in {
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./corecli.nix
    ./coregui.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
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
    "L /etc/nixos/configuration.nix - - - - /_projects/env/nixfiles/ws0.nix"
    "L /nonroot/.ssh - - - - /_projects/secrets/ssh"
    "L /nonroot/.gnupg - - - - /_projects/secrets/gnupg"
    "L /nonroot/.password-store - - - - /_projects/secrets/pass"
    "L /root/.ssh - - - - /_projects/secrets/ssh"
    "L /root/.gnupg - - - - /_projects/secrets/gnupg"
    "L /root/.password-store - - - - /_projects/secrets/pass"
  ];

  fileSystems."/" = { device = "zpuddle/ephem/root"; fsType = "zfs"; };
  fileSystems."/_backups" = { device = "zpuddle/persist/backups"; fsType = "zfs"; };
  fileSystems."/_deprecated" = { device = "zpuddle/persist/deprecated"; fsType = "zfs"; };
  fileSystems."/_docker" = { device = "zpuddle/persist/docker"; fsType = "zfs"; };
  fileSystems."/_dockervols" = { device = "zpuddle/persist/dockervols"; fsType = "zfs"; };
  fileSystems."/_projects" = { device = "zpuddle/persist/projects"; fsType = "zfs"; neededForBoot = true; };
  fileSystems."/_scratch" = { device = "zpuddle/persist/scratch"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/42F5-5416"; fsType = "vfat"; };
  fileSystems."/nix" = { device = "zpuddle/ephem/nix"; fsType = "zfs"; };

  swapDevices = [
    { device = "/dev/disk/by-uuid/1d4ce75f-8044-4a41-ac99-3859f1cf17a6"; }
  ];

  nixpkgs.config.allowUnfree = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  console = {
    useXkbConfig = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v22b.psf.gz";
  };

  # does not live in coregui due to needing a different version for lp0.
  environment.etc."alacritty".text = builtins.readFile ../dotfiles/alacritty;

  time.timeZone = "America/New_York";

  networking.hostName = "ws0";
  networking.hostId = "b776b545"; # ZFS req.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  # use this to set a static IP, e.g. for UBNT router initial setup.
  #networking.interfaces.eno1.ipv4.addresses = [{ address = "192.168.1.11"; prefixLength = 24; }];

  # allow incoming 80/443 for testing/demo purposes.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [80 443 8384];

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      permitRootLogin = "prohibit-password";
      ports = [55000];
    };
    xserver = {
      dpi = 128;
      videoDrivers = [ "nvidia" ];
    };
    syncthing = {
      enable = true;
      systemService = true;
      dataDir = "/_scratch/syncthing_data";
      configDir = "/_scratch/syncthing_config";
      guiAddress = "127.0.0.1:8384";
      openDefaultPorts = true;
      user = "nonroot";
      group = "users";
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

  # nix-env -i mkpasswd; mkpasswd -m sha-512 -s >> /_projects/secrets/shadow/passwd_ws0_root
  # nix-env -i mkpasswd; mkpasswd -m sha-512 -s >> /_projects/secrets/shadow/passwd_ws0_nonroot
  # must mark the mount as needed on boot; see above.
  users = {
    mutableUsers = false;
    users = {
      nonroot = {
        isNormalUser = true;
        home = "/nonroot";
        extraGroups = [ "wheel" "audio" "docker" ];
        passwordFile = "/_projects/secrets/shadow/passwd_ws0_nonroot";
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
        passwordFile = "/_projects/secrets/shadow/passwd_ws0_root";
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
