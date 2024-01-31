{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      date = inputs.self.lastModifiedDate or inputs.self.lastModified or "19700101";
      commit = inputs.self.shortRev or "dirty";

      theme = pkgs.callPackage ./nix/beamertheme-pure-minimalistic.nix {};
      buildScript = ''
        pandoc slides.md --pdf-engine=latexmk --pdf-engine-opt=-xelatex --listings -t beamer --slide-level=1 -o slides.pdf
        # sadly can't use tectonic due to it not (easily) supporting offline pre-cached builds
        #pandoc slides.md --pdf-engine=tectonic -t beamer --slide-level=2 -o $out/slides.pdf
      '';
      tex = pkgs.texliveSmall.withPackages (ps:
        [theme]
        ++ (
          with ps; [
            latexmk
            pdfpc
            xstring
            hyperxmp
            ifmtarg
          ]
        ));
      package = pkgs.stdenvNoCC.mkDerivation {
        pname = "keycloakdevday2024-slides";
        version = "${builtins.substring 0 8 date}+${commit}";
        src = ./.;
        buildInputs = with pkgs; [
          pandoc
          tex
        ];
        buildPhase = ''
          runHook preBuild

          mkdir -p .cache/texmf-var .cache/xdg
          export TEXMFHOME=.cache
          export TEXMFVAR=.cache/texmf-var
          export SOURCE_DATE_EPOCH=${date}
          export XDG_CACHE_HOME=.cache/xdg
          ${buildScript}

          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp slides.pdf $out/
          runHook postInstall
        '';
      };
    in {
      devShells.default = pkgs.mkShell {
        inputsFrom = [package];
        packages = with pkgs; [
          pdfpc
          (writeShellScriptBin "build-slides" ''
            set -e
            ${buildScript}
          '')
        ];
      };
      packages = {
        default = package;
        inherit theme;
      };
    });
}
