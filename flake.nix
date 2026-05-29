{
  description = "NixOS aarch64 VMware Fusion VM — Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }: {
    nixosConfigurations.hypr-vmware = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        # Make NUR available system-wide
        { nixpkgs.overlays = [ nur.overlays.default ]; }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Change "shawn" to your username
          home-manager.users.shawn = import ./home.nix;
        }
      ];
    };
  };
}
