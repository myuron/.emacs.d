{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    twist.url = "github:emacs-twist/twist.nix";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      emacs-overlay,
      twist,
      treefmt-nix,
      elpa,
      melpa,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          emacs-overlay.overlay
        ];
      };

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
