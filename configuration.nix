# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 
  unstablePkgs = import <nixpkgs-unstable> { };
in  
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./apps/sttt.nix
      ./apps/xdg.nix
    ];
  
  environment.systemPackages = with pkgs; [
    vim
    btop
    hyprland
    tree
    fish
    git
    wget
    vivaldi
    fastfetch
    kitty
    discord
    rofi-wayland
    eww
    swww

    pulseaudioFull
    alsa-utils
    alsa-plugins
    pavucontrol
     
    bluez
    blueman

    vscode
    xfce.thunar

    python3

    grim   # screenshots on wayland
    slurp  # rectangle selector on wayland

    nerdfonts

    xdg-utils
  ] ++ [
    unstablePkgs.wallust
  ];
 
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = let
    apc-extension = builtins.fetchGit {
      url = https://github.com/drcika/apc-extension.git;
      rev = "4d7d3b10ee1814880514728bd18ffac143329642";
    };
  in [
    (self: super: {
      vscode = super.vscode.overrideAttrs (attrs: {
        postInstall = ''
          cd $out
          mkdir apc-extension

          sed '1d' ${apc-extension}/src/patch.ts >> $out/apc-extension/patch.ts
          sed "s%require.main!.filename%'$out/lib/vscode/resources/app/out/dummy'%g" -i  $out/apc-extension/patch.ts
          sed "s%vscode.window.showErrorMessage(%throw new Error(installationPath + %g" -i  $out/apc-extension/patch.ts
          sed "s%promptRestart();%%g" -i  $out/apc-extension/patch.ts

          sed '1d' ${apc-extension}/src/utils.ts > $out/apc-extension/utils.ts
          ls $out/apc-extension >> log

          echo "import { install } from './patch.ts'; install({ extensionPath: '${apc-extension}' })" > $out/apc-extension/install.ts

          bun apc-extension/install.ts
        '';
        buildInputs = attrs.buildInputs ++ [
          pkgs.bun
        ];
      });
    })
  ];


  programs.hyprland.enable = true;
  programs.light.enable = true;

  programs = {
    bash.interactiveShellInit = ''
        export TERM=xterm-256color
    '';

    fish.shellInit = ''
        set -x TERM xterm-256color
    '';
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { 
      fonts = [ "LiberationMono" ];
    }) 
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    # Disable the Logitech high-resolution driver
    install hid_logitech_hidpp /usr/bin/true
  '';

  networking.hostName = "venari"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pulseaudio.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    extraConfig = ''
      load-module module-combine-sink
     '';
  };
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.opengl.extraPackages = with pkgs; [
    intel-vaapi-driver # for older hardware
    # intel-media-driver # switch when newer hardware
    libvdpau-va-gl
  ];
 
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.py = {
     isNormalUser = true;
     extraGroups = [ "wheel" "sudo" "audio" "video" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
  };
  
  users.groups.sudo = {};
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      %sudo ALL=(ALL) NOPASSWD: ALL
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

