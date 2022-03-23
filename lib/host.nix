inputs@{ lib, darwin, nixpkgs, home-manager, nixos-generators, ... }:

rec {
  virtualSystems = [
    "amazon"
    "azure"
    "cloudstack"
    "do"
    "gce"
    "hyperv"
    "install-iso-hyperv"
    "install-iso"
    "iso"
    "kexec"
    "kexec-bundle"
    "kubevirt"
    "lxc"
    "lxc-metadata"
    "openstack"
    "proxmox"
    "qcow"
    "raw"
    "raw-efi"
    "sd-aarch64-installer"
    "sd-aarch64"
    "vagrant-virtualbox"
    "virtualbox"
    "vm-bootloader"
    "vm-nogui"
    "vmware"
    "vm"
  ];

  isDarwin = lib.hasInfix "darwin";
  isVirtual = system:
    lib.foldl
    (exists: virtualSystem: exists || lib.hasInfix virtualSystem system) false
    virtualSystems;

  getVirtual = system:
    lib.foldl (result: virtualSystem:
      if lib.not null result then
        result
      else if lib.hasInfix virtualSystem system then
        virtualSystem
      else
        null) null virtualSystems;

  getDynamicConfig = system:
    if lib.isVirtual system then
      let
        format = getVirtual system;
        system' = builtins.replaceStrings [ format ] [ "linux" ] system;
      in {
        output = "${format}Configurations";
        system = system';
        builder = args:
          let
            formatModule =
              builtins.getAttr format nixos-generators.nixosModules;
            image = nixpkgs.lib.nixosSystem (args // {
              modules = [ formatModule home-manager.nixosModules.home-manager ]
                ++ (args.modules);
              inherit (args) specialArgs;
            });
          in image.config.system.build.${image.config.formatAttr};
      }
    else if lib.isDarwin system then {
      output = "darwinConfigurations";
      builder = args:
        darwin.lib.darwinSystem (builtins.removeAttrs args [ "system" ]);
    } else {
      builder = args:
        nixpkgs.lib.nixosSystem (args // {
          modules = args.modules ++ [
            # ({ config, ... }: {
            #   system.configurationRevision = sourceInfo.rev;
            #   services.getty.greetingLine =
            #     "<<< Welcome to NixOS ${config.system.nixos.label} @ ${sourceInfo.rev} - \\l >>>";
            # })
            { imports = [ home-manager.nixosModules.home-manager ]; }
          ];
        });
    };

  withDynamicConfig = lib.composeAll [ lib.merge' getDynamicConfig ];

  # Pass through all inputs except `self` and `utils` due to them breaking
  # the module system or causing recursion.
  mkSpecialArgs = args:
    (builtins.removeAttrs inputs [ "self" "utils" ]) // {
      inherit lib;
    } // args;

  mkHost = { system, path, name ? lib.getFileName (builtins.baseNameOf path)
    , modules ? [ ], specialArgs ? { }, channelName ? "nixpkgs" }: {
      "${name}" = withDynamicConfig system {
        inherit system channelName;
        modules =
          (lib.getModuleFilesWithoutDefaultRec (lib.getPathFromRoot "/modules"))
          ++ [ path ] ++ modules;
        specialArgs = mkSpecialArgs (specialArgs // { inherit system name; });
      };
    };

  mkHosts = { src, hostOptions ? { } }:
    let
      systems = lib.getDirs src;
      hosts = builtins.concatMap (systemPath:
        let
          system = builtins.baseNameOf systemPath;
          modules = lib.getDirs systemPath;
        in builtins.map (path:
          let
            name = lib.getFileName (builtins.baseNameOf path);
            options = lib.optionalAttrs (builtins.hasAttr name hostOptions)
              hostOptions.${name};
            host = mkHost ({ inherit system path name; } // options);
          in host) modules) systems;
    in lib.foldl lib.merge { } hosts;
}
