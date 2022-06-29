{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "kubectl-aliases";

  src = pkgs.fetchFromGitHub {
    owner = "ahmetb";
    repo = "kubectl-aliases";
    rev = "b2ee5dbd3d03717a596d69ee3f6dc6de8b140128";
    sha256 = "TCk26Wdo35uKyTjcpFLHl5StQOOmOXHuMq4L13EPp0U=";
  };

  installPhase = ''
    mkdir -p $out/share/kubectl-aliases
    cp .kubectl_aliases $out/share/kubectl-aliases/
  '';
}
