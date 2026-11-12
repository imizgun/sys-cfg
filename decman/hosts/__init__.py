"""Host selection: hosts/<hostname>.py must define HOST: lib.Host."""

import importlib


def load(hostname: str):
    try:
        mod = importlib.import_module(f"hosts.{hostname}")
    except ModuleNotFoundError as e:
        if e.name == f"hosts.{hostname}":
            raise SystemExit(f"sys-cfg: no hosts/{hostname}.py (set SYSCFG_HOST to override)") from e
        raise
    return mod.HOST
