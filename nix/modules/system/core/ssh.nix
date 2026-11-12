{ username, ... }:

{
  # sshd, key-only. openFirewall (default true) opens tcp/22.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  # Shared with decman (modules/core/ssh.py): one public key per line.
  users.users.${username}.openssh.authorizedKeys.keyFiles = [
    ../../../../dotfiles/ssh/authorized_keys
  ];
}
