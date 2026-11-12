from lib.packages import PackageSet

# Dropped with Nix: nil, nixd (Nix LSPs). dotnet-ef is a dotnet tool on Arch:
#   dotnet tool install --global dotnet-ef
# gnumake/gcc are in base-devel (core.base).


class Dev(PackageSet):
    PACMAN = {
        # editors
        "zed",
        # toolchains
        "rustup", "gcc", "clang", "cmake", "nasm", "xmake", "python", "nodejs", "bun",
        # embedded (ESP32)
        "espup", "espflash",
        # CLI
        "github-cli", "yazi", "btop", "jq", "bat", "fzf", "yt-dlp", "ffmpeg", "fastfetch",
        "ripgrep", "bind",  # rg; dig/nslookup
        # Wayland screenshots
        "slurp", "grim",
    }
    AUR = {
        # IDEs
        "rustrover", "rider", "intellij-idea-ultimate-edition",
        "claude-code",
        "nls-bin",                 # `ls` alias (dotfiles/fish/conf.d/aliases.fish)
        "flow-control-bin",
        "dotnet-sdk-preview-bin",  # .NET 11 (NixOS had dotnet-sdk_11); extra/ has only 10
    }


def module(host):
    return Dev(host)
