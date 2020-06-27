{ config, lib, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "elevator=none" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r zpuddle/ephem/root@blank
  '';
  systemd.tmpfiles.rules = [
    "L /etc/nixos/configuration.nix - - - - /_projects/env/nixfiles/sv0.nix"
  ];

  boot.zfs.devNodes = "/dev/disk/by-partuuid";

  fileSystems."/" = { device = "zpuddle/ephem/root"; fsType = "zfs"; };
  fileSystems."/_backups" = { device = "zpuddle/persist/backups"; fsType = "zfs"; };
  fileSystems."/_deprecated" = { device = "zpuddle/persist/deprecated"; fsType = "zfs"; };
  fileSystems."/_docker" = { device = "zpuddle/persist/docker"; fsType = "zfs"; };
  fileSystems."/_dockervols" = { device = "zpuddle/persist/dockervols"; fsType = "zfs"; };
  fileSystems."/_projects" = { device = "zpuddle/persist/projects"; fsType = "zfs"; neededForBoot = true; };
  fileSystems."/_scratch" = { device = "zpuddle/persist/scratch"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/29EE-942A"; fsType = "vfat"; };
  fileSystems."/nix" = { device = "zpuddle/ephem/nix"; fsType = "zfs"; };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f6d54a0f-ccce-4c1a-b018-a58f2e889511"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sv0";
  networking.hostId = "445bd39c";
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp4s0.useDHCP = true;

  time.timeZone = "America/New_York";
  environment.systemPackages = [
    pkgs.curl
    pkgs.rsync
    pkgs.git
    pkgs.tig
    pkgs.micro
    pkgs.vim
    pkgs.tree
    pkgs.tmux
    pkgs.bash
    pkgs.bashInteractive
    pkgs.bashCompletion
    pkgs.openssh
    pkgs.gnupg
  ];

  users.mutableUsers = false;
  users.users.root.extraGroups = [ "docker" ];
  # nix-env -i mkpasswd; mkpasswd -m sha-512 -s >> /_projects/secrets/passwd_root
  # must mark the mount as needed on boot; see above.
  users.users.root.passwordFile = "/_projects/passwd_root";
  users.users.nonroot.isNormalUser = true;
  users.users.nonroot.extraGroups = [ "wheel" ];
  users.users.nonroot.passwordFile = "/_projects/passwd_nonroot";
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--data-root=/_docker";

  # FIXME: insecure.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  system.stateVersion = "20.03";
}

