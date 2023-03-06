{
  description = "Odin template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    my-nix-overlay = {
      #url = "path:/home/hcssmith/Projects/my-nix-overlay";
      url = "github:hcssmith/my-nix-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, my-nix-overlay }: 
    let
    # to work with older version of flakes
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

    # Generate a user-friendly version number.
    version = builtins.substring 0 8 lastModifiedDate;

    # System types to support.
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs 
    { 
      inherit system; 
      overlays = [ 
        self.overlay 
        my-nix-overlay.overlay
      ]; 
    });

  in
  {
    overlay = final: prev: {
      hello = with final; stdenv.mkDerivation rec {
        name = "hello-${version}";
        src = ./.;
        buildInputs = [odin-latest];

        unpackPhase = ":";
        buildPhase =
            ''
              odin build $src -out:${name}
            '';

        installPhase =
            ''
              mkdir -p $out/bin
              cp ${name} $out/bin/
            '';
      };
    };
    # Provide some binary packages for selected system types.
    packages = forAllSystems (system:
    {
      inherit (nixpkgsFor.${system}) hello;
    });

    # The default package for 'nix build'. This makes sense if the
    # flake provides only one package or there is a clear "main"
    # package.
    defaultPackage = forAllSystems (system: self.packages.${system}.hello);


  };
}
