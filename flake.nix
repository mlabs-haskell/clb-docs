{
  description = "CLB docs dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/";

  outputs =
    { self
    , nixpkgs
    }:

    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      # Helper function for scripting
      runPkg = pkgs: pkg: "${pkgs.${pkg}}/bin/${pkg}";
    in
    {
      devShells = forAllSystems
        ({ pkgs }:
          let
            common = with pkgs; [
              # Language
              vale

              # Link checking
              htmltest
              lychee

              # JS
              nodejs
              pnpm

              # Serve locally
              static-web-server
            ];

            run = pkg: runPkg pkgs pkg;

            scripts = with pkgs; [
              (writeScriptBin "clean" ''
                rm -rf dist
              '')

              (writeScriptBin "setup" ''
                clean
                ${run "pnpm"} install
              '')

              (writeScriptBin "build" ''
                setup
                ${run "pnpm"} run build
              '')

              (writeScriptBin "build-ci" ''
                setup
                ENV=ci ${run "pnpm"} run build
              '')

              (writeScriptBin "dev" ''
                setup
                ${run "pnpm"} run dev
              '')

              (writeScriptBin "format" ''
                setup
                ${run "pnpm"} run format
              '')

              (writeScriptBin "check-internal-links" ''
                ${run "htmltest"} --conf ./.htmltest.internal.yml
              '')

              (writeScriptBin "check-external-links" ''
                ${run "htmltest"} --conf ./.htmltest.external.yml
              '')

              (writeScriptBin "lint-style" ''
                ${run "vale"} src/pages
              '')

              (writeScriptBin "preview" ''
                build
                ${run "pnpm"} run preview
              '')

              # Run this to see if CI will pass
              (writeScriptBin "ci" ''
                set -e
                build-ci
                check-internal-links
                lint-style
              '')
            ];

            exampleShells = import ./nix/shell/example.nix { inherit pkgs; };
          in
          {
            inherit (exampleShells) example cpp haskell hook javascript python go rust scala multi;
          } // {
            default = pkgs.mkShell
              {
                packages = common ++ scripts;
              };
          });

      apps = forAllSystems ({ pkgs }:
        let
          run = pkg: runPkg pkgs pkg;

          runLocal = pkgs.writeScriptBin "run-local" ''
            rm -rf dist
            ${run "pnpm"} install
            ${run "pnpm"} run build
            ${run "pnpm"} run preview
          '';
        in
        {
          default = {
            type = "app";
            program = "${runLocal}/bin/run-local";
          };
        });
    };
}