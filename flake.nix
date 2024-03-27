{
  inputs = {
    nixpkgs = {
      id = "nixpkgs";
      type = "indirect";
    };
  };

  outputs = { nixpkgs, ... }: {
    devShells = {
      "x86_64-linux" = let pkgs = nixpkgs.legacyPackages."x86_64-linux";
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ gcc gdb valgrind gnumake openjdk ];
        };
        evoluvion = pkgs.mkShell { buildInputs = [ pkgs.openjdk ]; };
      };
    };
  };

}
