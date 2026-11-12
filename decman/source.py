# decman source: sudo decman --source ~/sys-cfg/decman/source.py
#
# decman exec()s this file inside a function after chdir'ing here, so keep it
# flat (no defs referencing these imports) — the logic lives in modules/.
import os
import socket

import decman

import hosts
import modules

HOST = hosts.load(os.environ.get("SYSCFG_HOST") or socket.gethostname())
decman.modules += modules.build(HOST)
