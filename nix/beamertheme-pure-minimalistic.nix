{
  stdenvNoCC,
  fetchFromGitHub,
  texlive,
}:
# ctan only has 2.0.0 where the date is not rendered correctly
stdenvNoCC.mkDerivation rec {
  pname = "beamertheme-pure-minimalistic";
  version = "2.0.3";

  outputs = ["out" "tex"];
  src = fetchFromGitHub {
    owner = "kai-tub";
    repo = "latex-beamer-pure-minimalistic";
    rev = "v${version}";
    hash = "sha256-1Nwu0GSUfLqN8LctWx+Pd7wTECNyU3oHMG2g1znvQTI=";
  };

  passthru.tlDeps = with texlive; [silence iftex noto fira etoolbox];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    touch $out/dummy

    mkdir -p $tex/tex/latex/beamertheme-pure-minimalistic
    cp -v *.sty $tex/tex/latex/beamertheme-pure-minimalistic/

    runHook postInstall
  '';
}
