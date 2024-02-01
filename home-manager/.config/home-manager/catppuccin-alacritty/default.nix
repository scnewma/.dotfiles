{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "catppuccin-alacritty";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "alacritty";
    rev = "f2da554ee63690712274971dd9ce0217895f5ee0";
    sha256 = "sha256-ypYaxlsDjI++6YNcE+TxBSnlUXKKuAMmLQ4H74T/eLw=";
  };

  installPhase = ''
    dir=$out/share/catppuccin-alacritty
    mkdir -p $dir
    cp *.toml $dir/
  '';
}
