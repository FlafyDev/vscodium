{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "nodejs-16.20.1"
        ];
      };
    in {
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nodejs_16
          nodejs_16.pkgs.yarn
          jq
          git
          pkg-config
          gnumake
          gcc12
          # dpkg
          python3
          imagemagick
        ];
        buildInputs = with pkgs;
        with pkgs.xorg; [
          libX11
          libxkbfile
          libsecret
        ];
      };
    });
}
