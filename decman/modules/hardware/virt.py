from decman.plugins import pacman, systemd

from lib import SysModule


class Virt(SysModule):
    """KVM/QEMU via libvirt + virt-manager; swtpm for Windows 11 guests,
    OVMF for UEFI. SPICE USB redirection comes with spice-gtk (virt-manager dep)."""

    NAME = "hardware.virt"

    def groups(self):
        return {"libvirt", "kvm"}

    @pacman.packages
    def pacman_packages(self):
        return {"libvirt", "qemu-desktop", "swtpm", "edk2-ovmf", "dnsmasq", "virt-manager",
                "spice-gtk"}  # USB redirection to guests

    @systemd.units
    def units(self):
        # libvirt-guests: suspend/resume VMs across host shutdown (NixOS default)
        return {"libvirtd.service", "libvirt-guests.service"}


def module(host):
    return Virt(host)
