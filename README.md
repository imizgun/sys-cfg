# sys-cfg

NixOS config and dotfiles for my machines: `nixos` (the PC) and `laptop`.

```
nix/        NixOS + Home Manager flake (see nix/README.md)
dotfiles/   plain config files the nix modules link into ~/.config
```

Apply: `nh os switch` (alias `nix-rebuild`); update + apply: `nh os switch --update`.
