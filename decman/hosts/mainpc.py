"""Desktop PC (Ryzen 5 7600 — Zen 4, AMD GPU). Was `nixos` under NixOS (nix/hosts/nixos)."""

from lib import Host, Mount

HOST = Host(
    hostname="mainpc",
    username="vkabaczko",
    description="Mikhail",
    distro="cachyos",
    march="znver4",
    bootloader="limine",
    mounts=(
        Mount(
            what="/dev/disk/by-uuid/92033fe1-2e9a-432b-b6e7-4369740c2196",
            where="/mnt/sda1",
            fstype="ext4",
        ),
    ),
    extra_modules=("packages.games",),
)
