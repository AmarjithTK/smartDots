
from pathlib import Path
from lib.nitcauth import NITCAuth

import os

print(os.getcwd())

basedir = os.path.dirname(os.path.abspath(__file__))

print(basedir)


# filepath = Path("storage/firewall.json")

# print(filepath.absolute())

nitcauth = NITCAuth(f"{basedir}/storage/firewall.json",basedir=basedir)

nitcauth.waitfortrigger()
