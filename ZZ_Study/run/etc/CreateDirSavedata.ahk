#Requires AutoHotkey >=2.0

EnvGet, userHome, userprofile

targetDir  := userHome "\AppData\Roaming\FALCOM\ED4\SAVEDATA"
IfNotExist, % targetDir
	FileCreateDir, % targetDir
