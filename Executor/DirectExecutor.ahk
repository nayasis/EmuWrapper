#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\ZZ_Library\Include.ahk"
#Include "%A_ScriptDir%\..\ZZ_Library\EmulCommon.ahk"

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "g:\emuloader\PC\PC004756"

option    := getOption(imageDir)
execution := option.has("execution") ? option.execution : JSON.Obj()

exeFile  := execution.executable
runAdmin := execution.runAdmin
notHide  := execution.notHideLoader

debug("file:" exeFile)
debug("runAdmin:" runAdmin)
if (exeFile == "")
	ExitApp()
if (!FileUtil.isFile(imageDir "\" exeFile))
	ExitApp()

cmd := wrap(imageDir "\" exeFile)

if (notHide == "true") {
	if (runAdmin == "true") {
		Run("*RunAs " cmd)
	} else {
		Run(cmd)
	}
} else {
	if (runAdmin == "true") {
		RunWait("*RunAs " cmd)
	} else {
		RunWait(cmd)
	}
}

ExitApp()
getExecutableFile(imageDir) {
	option := getOption(imageDir)
	return option.has("execution") ? option.execution.executable : ""
}
