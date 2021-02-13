import glob
import os, re
import shutil
import subprocess
from pathlib import Path

ROOT_PATH = "//NAS2/emul/image/Wii/_backup"

print( ">> Convert WBFS to GCZ")

def findFile( root, ext ):
	return map(
		lambda path: path.replace("\\","/"),
		glob.glob(f"{root}/**/*.{ext}", recursive=True)
	)

def toGcz(path):
	src = path.replace("\\","/")
	trg = re.sub("(?i)\\.wbfs$",".gcz",src)
	cmd = f'wit -P copy "{src}" --gcz "{trg}" --gcz-zip'
	print(cmd)
	subprocess.Popen(cmd).wait()
	os.remove(src)

def compare( fileGcz ):
	src = fileGcz
	trg = re.sub("//NAS2/emul/","//NAS2/emul/@Recycle/", fileGcz)
	trg = re.sub("(?i)\\.gcz",".wbfs", trg)
	if( os.stat(src).st_size > os.stat(trg).st_size ):
		dir = os.path.dirname(src)
		os.remove(src)
		shutil.move(trg, dir)
		print( f"{src} >> {dir}" )


# for i, file in enumerate(findFile(ROOT_PATH, "gcz")) :
# 	print( f">> {i}: {file}" )
for file in findFile(ROOT_PATH, "gcz") :
	compare(file)
	# print( f">> {file}" )
	# toGcz(file)
	# if( i >= 0 ):
	# 	break


