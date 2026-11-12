# Upstream's prebuilt CEF .deb, patched to run on NixOS (nixpkgs only has
# 1.1.0, and building from source needs the whole Rust/Tauri toolchain).
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libxkbcommon,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  wayland,
  xdg-utils,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "deadlock-mod-manager";
  version = "2.2.0";

  src = fetchurl {
    url = "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases/download/v${version}/Deadlock.Mod.Manager_${version}_amd64-cef.deb";
    hash = "sha256-0VE8IDYYojhkKT58E3204ho7YpRJxn4G0Dadn0wOt0I=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libxkbcommon
    nspr
    nss
    openssl
    pango
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  # chrome-sandbox is setuid, which the store forbids; drop it and let
  # Chromium fall back to its user-namespace sandbox.
  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
    rm "usr/share/Deadlock Mod Manager/chrome-sandbox"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r usr/share/icons usr/share/applications $out/share/
    cp -r "usr/share/Deadlock Mod Manager" $out/share/deadlock-mod-manager

    # dlopen'ed at runtime, invisible to autoPatchelf
    makeWrapper $out/share/deadlock-mod-manager/deadlock-mod-manager $out/bin/deadlock-mod-manager \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libnotify
          systemd
          wayland
          libxkbcommon
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
        ]
      } \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --unset GDK_SCALE \
      --add-flags --disable-auto-update

    runHook postInstall
  '';

  meta = {
    description = "Mod manager for Valve's Deadlock (CEF build)";
    homepage = "https://github.com/deadlock-mod-manager/deadlock-mod-manager";
    platforms = [ "x86_64-linux" ];
    mainProgram = "deadlock-mod-manager";
  };
}
