import glob
import os, re
import subprocess

ROOT_PATH = "//NAS2/emul/image/Wii/_backup"

print( ">> Convert WBFS to GCZ")

def findFile( root, ext ):
	return glob.glob(f"{root}/**/*.{ext}", recursive=True)

def toGcz(path):
	src = path.replace("\\","/")
	trg = re.sub("(?i)\\.wbfs$",".gcz",src)
	cmd = f'wit -P copy "{src}" --gcz "{trg}" --gcz-zip'
	print(cmd)
	subprocess.Popen(cmd).wait()
	os.remove(src)

for i, file in enumerate(findFile(ROOT_PATH, "wbfs")) :
	print( f">> {i}: {file}" )
	toGcz(file)
	# if( i >= 0 ):
	# 	break


