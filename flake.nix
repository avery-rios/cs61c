{
  inputs = {
    nixpkgs = {
      id = "nixpkgs";
      type = "indirect";
    };
  };

  outputs = { nixpkgs, ... }: {
    devShells = {
      "x86_64-linux".default = let pkgs = nixpkgs.legacyPackages."x86_64-linux";
      in pkgs.mkShell {
        buildInputs = with pkgs; [ gcc gdb valgrind gnumake openjdk ];
      };
    };
  };

}
