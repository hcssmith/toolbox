{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    #TEMPLATES
    templates = {
      odin = {
        path = ./templates/odin;
        description = "Basic template for an odin program";
      };
    };

    #TOOLS
    simple_web_server = pkgs.callPackage ./simple_web_server { };

    #USAGE
    packages.${system}.default = pkgs.writeScriptBin "test" ''
      echo Usage: nix run toolbox#tool
      echo Make sure that toolbox is added as a registery
      '';
  };
}
