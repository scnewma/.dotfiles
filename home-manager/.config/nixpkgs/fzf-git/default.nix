{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "fzf-git";

  src = pkgs.fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf-git.sh";
    rev = "a5c30a5894061040bc02c1f6f3dcf711c4e5363e";
    sha256 = "X0IXIpv1Po6iIZ43OqZY7q4g62x8IouuibyXlha3cBk=";
  };

  installPhase = ''
    mkdir -p $out/share/fzf-git
    cp fzf-git.sh $out/share/fzf-git/
  '';
}
