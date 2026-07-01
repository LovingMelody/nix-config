{inputs, ...}: {
  imports = with inputs; [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-amd
  ];
  TM = {
    isDesktop = true;
    isServer = true;
    isGui = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    # initrd = {
    #   secrets = {"/etc/dropbear/dropbear_rsa_host_key" = null;};
    #   network = {
    #     enable = true;
    #     ssh = {
    #       enable = true;
    #       port = 2222;
    #       hostKeys = "/etc/dropbear/dropbear_rsa_host_key";
    #       authorizedKeys = with lib;
    #         concatLists (mapAttrsToList (_name: user:
    #           if elem "wheel" user.extraGroups
    #           then user.openssh.authorizedKeys.keys
    #           else [])
    #         config.users.users);
    #     };
    #     postCommands = ''
    #       echo "zfs load-key -a; killall zfs >> /root/.profile"
    #     '';
    #   };
    # };
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
  };
  powerManagement.cpuFreqGovernor = "performance";

  services.fwupd.enable = true;
  hardware = {
    # openrazer = {
    #   enable = true;
    #   users = [config.users.users.melody.name];
    # };
  };
  networking.interfaces.enp7s0.wakeOnLan.enable = true;
  # fileSystems."/vault".neededForBoot = true;
}
