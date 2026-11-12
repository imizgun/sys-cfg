import decman
from decman.plugins import aur

from lib import SysModule, link

# Store extensions (vicinae store: api.vicinae.com/v1/store/<author>/<name>).
# Installed if missing; updates/removal stay in vicinae's GUI.
# knoopx/nix is left out on purpose: it searches nixpkgs, useless without Nix.
STORE_EXTENSIONS = [
    "gelei/bluetooth",
    "costeer/color-converter",
    "nikbpetrov/it-tools",
    "leonkohli/process-manager",
    "knoopx/systemd",
]
# Raycast-store extensions are re-bundled by vicinae on install (the raw zip
# has node_modules), so they can't be unpacked declaratively — install once
# from vicinae's store UI:
#   gebeto/translate (Google Translate)

SETTINGS_STUB = '{\n   "imports": ["sys-cfg.json"]\n}\n'


class Vicinae(SysModule):
    """vicinae launcher. dotfiles/vicinae/sys-cfg.json is the declarative
    config; ~/.config/vicinae/settings.json must stay a writable real file
    (the GUI rewrites it), so it's only created with the import if missing.
    The server is started by niri (dotfiles/niri/cfg/autostart.kdl)."""

    NAME = "programs.vicinae"

    def symlinks(self):
        return link(self.host, "vicinae/sys-cfg.json", ".config/vicinae/sys-cfg.json")

    def after_update(self, store):
        user = self.host.username
        settings = f"{self.host.home}/.config/vicinae/settings.json"
        decman.sh(
            f"if [ ! -e {settings} ]; then printf '%s' '{SETTINGS_STUB}' > {settings}; "
            f"elif ! grep -q 'sys-cfg.json' {settings}; then "
            f"echo 'sys-cfg: {settings} does not import sys-cfg.json — add \"imports\": [\"sys-cfg.json\"]' >&2; fi",
            user=user, mimic_login=True,
        )
        ext_dir = f"{self.host.home}/.local/share/vicinae/extensions"
        for ext in STORE_EXTENSIONS:
            name = ext.split("/")[1]
            dest = f"{ext_dir}/store.vicinae.{name}"
            # bsdtar (libarchive, a pacman dependency) can't stream zips, so
            # download to a temp dir; the archive's top-level <name>/ is
            # stripped to match vicinae's layout. mv last, so a failed
            # download never leaves an empty dir that looks installed.
            decman.sh(
                f"[ -d {dest} ] || {{ t=$(mktemp -d) && "
                f"curl -fsSL https://api.vicinae.com/v1/store/{ext}/download -o $t/ext.zip && "
                f"mkdir $t/x && bsdtar -xf $t/ext.zip -C $t/x --strip-components 1 && "
                f"mkdir -p {ext_dir} && mv $t/x {dest}; rc=$?; rm -rf $t; exit $rc; }}",
                user=user, mimic_login=True,
            )

    @aur.packages
    def aur_packages(self):
        return {"vicinae-bin"}


def module(host):
    return Vicinae(host)
