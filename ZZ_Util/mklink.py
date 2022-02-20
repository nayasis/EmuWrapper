#!/usr/bin/env python3.7
import os
from pathlib import Path

PATH_ROOT = Path(os.getcwd()).parent
PATH_TRG  = f"{PATH_ROOT}\\ZZ_snapshot"

def mklink(src,trg):
	if os.path.islink(src):
		if os.path.realpath(src) == trg :
			return
		os.unlink(src)
	elif os.path.isdir(src):
		os.rmdir(src)
	elif os.path.isfile(src):
		return
	os.symlink(src,trg)
	print(f"link ({src} -> {trg}")

sources = [
	"WiiU\\share\\screenshots",
	"Retroarch\\share\\screenshots",
	"PSX2\\share\\snaps",
	"DreamCast\\demul 0.7a_20160818\\snap",
	"DreamCast\\demul 0.7a_20180428\\snap",
	"Mame\\0.224\\snap",
	"Mednafen\\1.24.3\\snaps",
  "NDS\\DeSmuME\\Screenshots",
]

for src in sources:
	PATH_SRC = f"{PATH_ROOT}\\{src}"
	mklink(PATH_SRC,PATH_TRG)