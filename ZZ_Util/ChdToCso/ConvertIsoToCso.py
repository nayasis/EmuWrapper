import glob
import os, re
import shutil
import subprocess
from pathlib import Path

ROOT_PATH = "e:/iso/ps2"

print( ">> Convert ISO to CSO")

def findFile( root, ext ):
	return map(
		lambda path: path.replace("\\","/"),
		glob.glob(f"{root}/**/*.{ext}", recursive=True)
	)

def runwait(cmd):
	print(cmd)
	subprocess.Popen(cmd).wait()

def toCso( fileIso ):
	src = fileIso
	trg = re.sub("(?i)(.+)\\.(.+?)$","\\1.cso", src)
	runwait( f"maxcso \"{src}\"" )
	if( os.path.getsize(trg) == 0 ):
		os.remove(trg)
		runwait( f"CisoPlus -com -l9 \"{src}\" \"{trg}\"" )
	os.remove(src)

for file in findFile(ROOT_PATH, "iso") :
	print( f"- {file}" )
	toCso(file)
	# if( i >= 0 ):
	# 	break


