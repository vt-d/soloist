{
  description = "Spotify Soloist binary package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "soloist";
      };
      soloist = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        inherit soloist;
        default = soloist;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/soloist";
        meta.description = "Run Spotify Soloist";
      };
    };
}
