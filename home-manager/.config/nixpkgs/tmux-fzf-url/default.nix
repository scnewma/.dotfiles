{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "tmux-fzf-url";

  src = pkgs.fetchFromGitHub {
    owner = "wfxr";
    repo = "tmux-fzf-url";
    rev = "1241fc5682850fe41812cad81c76541674ee305b";
    sha256 = "sU0AydugtAE28DGy7Dgkj/eyHGaKQuWeVE2/7Wxh4Ig=";
  };

  installPhase = ''
    mkdir -p $out/share/tmux-fzf-url
    for f in fzf-url.sh fzf-url.tmux; do
      cp $f $out/share/tmux-fzf-url/
    done
  '';
}
