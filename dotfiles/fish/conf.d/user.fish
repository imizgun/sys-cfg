# Named user.fish so it sorts after plugin-*.fish in conf.d (bass must be loaded).
status is-interactive; or return

set fish_greeting

# espup (esp-rs Xtensa toolchain) generates this as a bash script; bass lets
# fish source it so PATH/LIBCLANG_PATH stay in sync across toolchain updates
# without hardcoding versioned paths here.
if test -f $HOME/export-esp.sh
    bass source $HOME/export-esp.sh
end
