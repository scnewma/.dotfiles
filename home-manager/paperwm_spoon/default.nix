{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "PaperWM.spoon";

  src = pkgs.fetchFromGitHub {
    owner = "mogenson";
    repo = "PaperWM.spoon";
    rev = "41389206e739e6f48ea59ddcfc07254226f4c93f";
    sha256 = "sha256-O1Pis5udvh3PUYJmO+R2Aw11/udxk3v5hf2U9SzbeqI=";
  };

  installPhase = ''
    mkdir -p $out/share/Spoons/PaperWM.spoon
    cp -r * $out/share/Spoons/PaperWM.spoon/
  '';
}
