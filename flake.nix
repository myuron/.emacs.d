{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    twist.url = "github:emacs-twist/twist.nix";
    elpa = {
      url = "github:elpa-mirrors/elpa";
      flake = false;
    };
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      twist,
      elpa,
      melpa,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      emacsConfig = twist.lib.makeEnv {
        inherit pkgs;
        emacsPackage = pkgs.emacs;
        initFiles = [ ./init.el ];
        lockDir = ./lock;
        registries = [
          {
            type = "elpa";
            path = elpa.outPath + "/elpa-packages";
            core-src = pkgs.emacs.src;
            auto-sync-only = true;
          }
          {
            name = "melpa";
            type = "melpa";
            path = melpa.outPath + "/recipes";
          }
        ];
      };
    in
    {
      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
      packages.${system}.default = emacsConfig;
      apps.${system} = emacsConfig.makeApps { lockDirName = "lock"; };
    };
}
