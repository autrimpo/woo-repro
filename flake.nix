{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = {self, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({config, ...}: {
      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];

      perSystem = {
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages = {
          default = pkgs.sbcl.buildASDFSystem rec {
            pname = "woo-repro";
            version = "0.0.0";
            src = ./.;

            lispLibs = with pkgs.sbcl.pkgs; [
              woo
            ];

            nativeBuildInputs = [pkgs.makeWrapper];

            buildScript = pkgs.writeText "build-woo-repro.lisp" ''
              (load (concatenate 'string (sb-ext:posix-getenv "asdfFasl") "/asdf.fasl"))
              (asdf:operate :program-op :woo-repro/executable)
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp -v bin/woo-repro $out/bin
              wrapProgram $out/bin/woo-repro \
                --prefix LD_LIBRARY_PATH : $LD_LIBRARY_PATH
            '';

            passthru.devShell = let
              sbclWithSlynk = pkgs.sbcl.withPackages (p: [p.slynk] ++ lispLibs);
            in
              pkgs.mkShell.override {stdenv = pkgs.stdenvNoCC;} {
                inputsFrom = [self'.packages.default];
                propagatedBuildInputs = [sbclWithSlynk];
                shellHook = ''
                  export CL_SOURCE_REGISTRY="$(pwd)"
                '';
              };
          };
        };

        devShells.default = self'.packages.default.devShell;
      };
    });
}
