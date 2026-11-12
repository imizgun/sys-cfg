import decman
from decman.plugins import pacman

from lib import SysModule, link


class Fish(SysModule):
    """fish + starship. Plugins (autopair, bass) via fisher from fish_plugins;
    bass has no Arch package. Login shell is set in core.users."""

    NAME = "programs.fish"

    def symlinks(self):
        h = self.host
        return (
            link(h, "fish/conf.d/aliases.fish", ".config/fish/conf.d/aliases.fish")
            | link(h, "fish/conf.d/user.fish", ".config/fish/conf.d/user.fish")
            | link(h, "fish/arch/integrations.fish", ".config/fish/conf.d/integrations.fish")
            | link(h, "fish/fish_plugins", ".config/fish/fish_plugins")
            | link(h, "starship.toml", ".config/starship.toml")
        )

    def _fisher_update(self):
        decman.sh("fish -c 'fisher update'", user=self.host.username, mimic_login=True)

    def on_enable(self, store):
        self._fisher_update()

    def on_change(self, store):
        self._fisher_update()

    @pacman.packages
    def pacman_packages(self):
        return {"fish", "fisher", "starship"}


def module(host):
    return Fish(host)
