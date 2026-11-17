final: prev: {
  # nixpkgs' jetbrains-mono builds the font from source via
  # python313Packages.gftools/nanoemoji, which is fragile (nanoemoji's
  # GitHub tag archive hash drifts upstream, breaking the fixed-output
  # derivation on every other `nix flake update`). We don't need that
  # toolchain at all: fetch JetBrains' own prebuilt release instead.
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

  # cargoSetupHook now exports AWS_LC_SYS_USE_SYSTEM=1, but nixpkgs' espup
  # doesn't list aws-lc as a dependency, so aws-lc-sys panics at build time.
  # Drop this once espup in nixpkgs includes aws-lc in its buildInputs.
  espup = prev.espup.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ final.aws-lc ];
  });

  # cargoSetupHook forbids *-sys crates from building their vendored C
  # libraries (LIBGIT2_NO_VENDOR=1, LIBSQLITE3_SYS_USE_PKG_CONFIG=1, ...), so
  # they must find system ones through pkg-config — but nixpkgs' yaak lists
  # neither, even though it pulls in git2/libgit2-sys and rusqlite/
  # libsqlite3-sys. Without libgit2 the build aborts in libgit2-sys' build
  # script; without sqlite it gets as far as linking and fails on -lsqlite3.
  # Drop this once yaak in nixpkgs has both in its buildInputs.
  yaak = prev.yaak.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [
      final.libgit2
      final.sqlite
    ];
  });
}
