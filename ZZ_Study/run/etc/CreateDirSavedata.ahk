#NoEnv

EnvGet, userHome, userprofile

targetDir  := userHome "\AppData\Roaming\FALCOM\ED4\SAVEDATA"
IfNotExist, % targetDir
	FileCreateDir, % targetDir
