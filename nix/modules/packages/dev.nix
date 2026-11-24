{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  hm.home.packages = with pkgs; [
    # editors / IDEs
    zed-editor
    jetbrains.rust-rover
    jetbrains.rider
    jetbrains.idea
    claude-code
    t3code
    stm32cubemx
    yaak # patched, see overlays/fixes.nix

    # toolchains
    rustup
    gcc
    gnumake
    cmake
    xmake
    nasm
    clang-tools
    python3
    nodejs
    bun
    dotnet-sdk_11
    dotnet-ef

    # embedded (ESP32)
    espup # patched, see overlays/fixes.nix
    espflash

    # nix: language servers
    nil
    nixd

    # CLI
    gh
    yazi
    btop
    amdgpu_top
    jq
    bat
    fzf
    man
    yt-dlp
    ffmpeg
    flow-control
    inputs.nls.packages.${system}.default # `ls` alias (dotfiles/fish/conf.d/aliases.fish)
    gdu
    docker-compose
    lazydocker
    fastfetch
    file
    syswatch
    bottom

    # Wayland screenshots
    slurp
    grim
    wl-clipboard-rs
  ];
}
