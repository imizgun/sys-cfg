"""Laptop (AMD; exact CPU unknown -> x86-64-v3 repos, safe for any recent AMD)."""

from lib import Host

HOST = Host(
    hostname="laptop",
    username="imizgun",
    description="Mikhail",
    distro="cachyos",
    march="v3",
    bootloader="limine",
    extra_modules=("packages.photo",),
)
