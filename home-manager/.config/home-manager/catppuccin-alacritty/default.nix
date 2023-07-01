{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "catppuccin-alacritty";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "alacritty";
    rev = "3c808cbb4f9c87be43ba5241bc57373c793d2f17";
    sha256 = "w9XVtEe7TqzxxGUCDUR9BFkzLZjG8XrplXJ3lX6f+x0=";
  };

  installPhase = ''
    dir=$out/share/catppuccin-alacritty
    mkdir -p $dir
    cp *.yml $dir/
  '';
}
