{
  description = "A native Python dev shell for the fysik project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, pyproject-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Loads your pyproject.toml file
      project = pyproject-nix.lib.project.loadPyproject {
        projectRoot = ./.;
      };

      # Specify Python 3.12 for this project
      python = pkgs.python312;

    in
    {
      # This creates the development shell that direnv will load
      devShells.${system}.default =
        let
          # pyproject.nix creates the list of packages for the builder
          arg = project.renderers.withPackages { inherit python; };
          # Nixpkgs' builder creates the final Python environment
          pythonEnv = python.withPackages arg;
        in
        pkgs.mkShell {
          # Add the native Python environment to your shell
          packages = [ pythonEnv ];
        };
    };
}
