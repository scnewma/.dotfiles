{ config, pkgs, ... }:

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

  home.packages = with pkgs; [
    _1password
    asciinema
    aspell
    awscli2
    bash
    bat
    coreutils
    curl
    delta # syntax highlighting for git
    direnv
    exa
    fd
    fzf
    gh
    git
    goreleaser
    graphviz
    grpcurl
    htop
    iterm2
    kitty
    jd-diff-patch
    jq
    mysql80
    neovim
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
    yq
    zsh

    # neovim language servers
    gopls
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.pyright
    nodePackages.vim-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    rnix-lsp
    rust-analyzer
    sumneko-lua-language-server
  ];
}
