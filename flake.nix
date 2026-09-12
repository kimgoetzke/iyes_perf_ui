{
  description = "iyes_perf_ui Bevy development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };
          rust = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "clippy" "rustfmt" ];
          };
          nativeLibs = with pkgs; [
            alsa-lib
            glibc.dev
            libGL
            libxkbcommon
            udev
            vulkan-loader
            wayland
            libx11
            libxcursor
            libxi
            libxrandr
          ];
        in {
          formatter = pkgs.alejandra;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              pkg-config
              rust
              rust-analyzer
            ] ++ nativeLibs;

            RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeLibs;
          };
        };
    };
}
