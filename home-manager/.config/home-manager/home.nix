{ config, pkgs, ... }:

let
  customPackages = {
    kubectlAliases = pkgs.callPackage ./kubectl-aliases/default.nix { inherit pkgs; };
    fzfGit = pkgs.callPackage ./fzf-git/default.nix { inherit pkgs; };
    tmux-fzf-url = pkgs.callPackage ./tmux-fzf-url { inherit pkgs; };
    catppucin-alacritty = pkgs.callPackage ./catppuccin-alacritty { inherit pkgs; };
    catppucin-tmux = pkgs.callPackage ./catppuccin-tmux { inherit pkgs; };
  };
in
  {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "shaun";
  home.homeDirectory = "/Users/shaun";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      nerdfonts = super.nerdfonts.override {
        fonts = [ "JetBrainsMono" ];
      };

      tmux = super.tmux.overrideAttrs (finalAttrs: previousAttrs: {
        patches = [ ./tmux-main-rev.patch ];
      });
    })
  ];

  home.packages = with pkgs; [
    customPackages.kubectlAliases
    customPackages.fzfGit
    customPackages.tmux-fzf-url
    customPackages.catppucin-alacritty
    customPackages.catppucin-tmux

    alacritty
    asciinema
    aspell
    awscli2
    bash
    bat
    coreutils
    curl
    delta # syntax highlighting for git
    direnv
    eza # exa is unmaintained
    fd
    fzf
    gh
    git
    git-crypt
    gnupg
    go-jsonnet
    goku
    goreleaser
    graphviz
    grpcurl
    htop
    hyperfine
    iterm2
    jd-diff-patch
    jq
    # kitty
    mysql80
    neovim
    nerdfonts
    nomad
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
    gopls
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.pyright
    nodePackages.vim-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages.typescript-language-server
    rnix-lsp
    lua-language-server
  ];
}
