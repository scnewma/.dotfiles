{
  description = "System packages";

  inputs = {
    flakey-profile.url = "github:lf-/flakey-profile";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    sunbeam.url = "github:pomdtr/sunbeam";
    sunbeam.inputs.nixpkgs.follows = "nixpkgs";
    sunbeam.inputs.utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, flakey-profile, sunbeam }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            (self: super: {
              nerdfonts = super.nerdfonts.override {
                fonts = [ "JetBrainsMono" ];
              };

              tmux = super.tmux.overrideAttrs (finalAttrs: previousAttrs: {
                patches = [ ../home-manager/tmux-main-rev.patch ];
              });
            })
          ];
        };

        customPackages = {
          kubectlAliases = pkgs.callPackage ../home-manager/kubectl-aliases/default.nix { inherit pkgs; };
          fzfGit = pkgs.callPackage ../home-manager/fzf-git/default.nix { inherit pkgs; };
          tmux-fzf-url = pkgs.callPackage ../home-manager/tmux-fzf-url { inherit pkgs; };
          catppucin-alacritty = pkgs.callPackage ../home-manager/catppuccin-alacritty { inherit pkgs; };
          catppucin-tmux = pkgs.callPackage ../home-manager/catppuccin-tmux { inherit pkgs; };
        };

        sunbeamPkg = sunbeam.packages.${system}.default;
      in
      {
        # Any extra arguments to mkProfile are forwarded directly to pkgs.buildEnv.
        #
        # Usage:
        # Switch to this flake:
        #   nix run .#profile.switch
        # Revert a profile change (note: does not revert pins):
        #   nix run .#profile.rollback
        # Build, without switching:
        #   nix build .#profile
        # Pin nixpkgs in the flake registry and in NIX_PATH, so that
        # `nix run nixpkgs#hello` and `nix-shell -p hello --run hello` will
        # resolve to the same hello as below [should probably be run as root, see README caveats]:
        #   sudo nix run .#profile.pin
        packages.profile = flakey-profile.lib.mkProfile {
          inherit pkgs;
          # Specifies things to pin in the flake registry and in NIX_PATH.
          pinned = { nixpkgs = toString nixpkgs; };
          paths = with pkgs; [
            customPackages.kubectlAliases
            customPackages.fzfGit
            customPackages.tmux-fzf-url
            customPackages.catppucin-alacritty
            customPackages.catppucin-tmux

            sunbeamPkg

            alacritty
            asciinema
            aspell
            awscli2
            bash
            bat
            # coreutils
            curl
            delta # syntax highlighting for git
            direnv
            eza # exa is unmaintained
            fd
            fzf
            # causing issues with rust finding libiconv
            # gcc
            gh
            git
            git-crypt
            glow
            gnupg
            go-jsonnet
            goku
            goreleaser
            graphviz
            grpcurl
            gum # used in tmux scripts
            htop
            hyperfine
            jd-diff-patch
            jq
            just
            mysql80
            neovim
            nerdfonts
            # nodejs
            postgresql
            pre-commit
            protobuf
            pv
            python310
            ripgrep
            shellcheck
            starship
            stow
            tmux
            tshark
            unixtools.watch
            wget
            wireguard-go
            wireguard-tools
            yq-go
            zld # alternative linker
            zsh
            zsh-autosuggestions
            zsh-syntax-highlighting

            # neovim language servers
            nodePackages.bash-language-server
            nodePackages.dockerfile-language-server-nodejs
            nodePackages.pyright
            nodePackages.vim-language-server
            nodePackages.vscode-langservers-extracted
            nodePackages.yaml-language-server
            nodePackages.typescript-language-server
            lua-language-server
          ];
        };
      });
}
