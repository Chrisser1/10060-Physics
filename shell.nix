let
    nixpkgs-src = builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
        # You may need to add a 'sha256' hash here
        # Nix will tell you which one to add on the first run
    };

        pyproject-nix-src = builtins.fetchTarball {
        url = "https://github.com/pyproject-nix/pyproject.nix/archive/master.tar.gz";
        # You may need to add a 'sha256' hash here
    };

    pkgs = import nixpkgs-src { };

    pyproject-nix-lib = (import (pyproject-nix-src + "/lib")) {
        lib = pkgs.lib;
    };

    python = pkgs.python3;

    project = pyproject-nix-lib.project.loadPyproject {
        projectRoot = ./.;
    };

    pythonDependencies = project.renderers.withPackages { inherit python; };

    pythonEnv = python.withPackages pythonDependencies;

in
    pkgs.mkShell {
    packages = [
        pythonEnv
    ];
}