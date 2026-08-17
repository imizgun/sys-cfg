{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # nixpkgs' jetbrains-mono builds the font from source via
  # python313Packages.gftools/nanoemoji, which is fragile (nanoemoji's
  # GitHub tag archive hash drifts upstream, breaking the fixed-output
  # derivation on every other `nix flake update`). We don't need that
  # toolchain at all: fetch JetBrains' own prebuilt release instead.
  nixpkgs.overlays = [
    (final: prev: {
      jetbrains-mono = prev.stdenvNoCC.mkDerivation rec {
        pname = "jetbrains-mono";
        version = "2.304";
        src = final.fetchzip {
          url = "https://github.com/JetBrains/JetBrainsMono/releases/download/v${version}/JetBrainsMono-${version}.zip";
          hash = "sha256-rv5A3F1zdcUJkmw09st1YxmEIkIoYJaMYGyZjic8jfc=";
          stripRoot = false;
        };
        installPhase = ''
          runHook preInstall
          install -Dm644 -t "$out/share/fonts/truetype/" fonts/ttf/*.ttf
          install -Dm644 -t "$out/share/fonts/truetype/" fonts/variable/*.ttf
          install -Dm644 -t "$out/share/fonts/WOFF2/" fonts/webfonts/*.woff2
          runHook postInstall
        '';
        meta = prev.jetbrains-mono.meta;
      };
    })
  ];

  # Keep the store tidy automatically instead of manually running gc.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
}
