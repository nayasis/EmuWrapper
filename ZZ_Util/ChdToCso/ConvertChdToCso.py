import os, re
import subprocess

ROOT_PATH = "e:/download/maxcso_v1.12.0_windows/work"

print( ">> Convert CHD to CSO")

def findFile( root, ext ):
	return [ f for f in os.listdir(root) if re.match(f'.*\\.{ext}$',f) ]

def toIso( root, path ):
	# extractcd -i "#{filepath}" -o "#{dir}\#{name}.cue" -ob "#{dir}\#{name}.bin"
	fullpath = f"{root}/{path}"
	base = os.path.splitext(fullpath)[0]
	cmd = f"chdman extractcd -f -i \"{fullpath}\" -o \"{base}.cue\" -ob \"{base}.iso\""
	print( cmd )
	subprocess.Popen(cmd).wait()

def toCso( root, path ):
	base = os.path.splitext(f"{root}/{path}")[0]
	fullpath = f"{base}.iso"
	cmd = f"maxcso \"{base}.iso\""
	print( cmd )
	subprocess.Popen(cmd).wait()
	if( os.path.getsize(f"{base}.cso") == 0 ):
		os.remove(f"{base}.cso")
		cmd = f"CisoPlus -com -l9 \"{base}.iso\" \"{base}.cso\""
		print( cmd )
		subprocess.Popen(cmd).wait()
		os.rename(f"{base}.chd", f"{base}.chd.fail")
	else:
		os.rename(f"{base}.chd", f"{base}.chd.done")	
	os.remove(f"{base}.iso")
	os.remove(f"{base}.cue")

for i, file in enumerate(findFile(ROOT_PATH, "chd")) :
	print( f"{i}: {file}" )
	toIso(ROOT_PATH,file)
	toCso(ROOT_PATH,file)
	# if( i >= 0 ):
	# 	break


