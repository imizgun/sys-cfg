# Arch only (decman links this into conf.d). On NixOS, Home Manager writes the
# same hooks into config.fish itself.
status is-interactive; or return

type -q starship; and starship init fish | source
type -q direnv; and direnv hook fish | source
