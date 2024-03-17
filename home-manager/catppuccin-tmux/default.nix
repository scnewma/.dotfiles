{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "catppuccin-tmux";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    rev = "8dd142b4e0244a357360cf87fb36c41373ab451f";
    sha256 = "KoGrA5Mgw52jU00bgirQb/E8GbsMkG1WVyS5NSFqv7o=";
  };

  installPhase = ''
    dir=$out/share/catppuccin-tmux
    mkdir -p $dir
    cp *.tmuxtheme $dir/
    cp *.tmux $dir/
  '';
}
