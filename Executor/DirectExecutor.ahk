#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

imageDir := %0%
; imageDir := "G:\emuloader\PC\PC001044"

option := getOption(imageDir)
; debug( ">> option`n" JSON.dump(option) )

file := option.execution.executable
runAdmin := option.execution.runAdmin

debug("file:" file)
debug("runAdmin:" runAdmin)
if( file == "" )
	ExitApp
if( ! FileUtil.isFile(imageDir "\" file) )
	ExitApp

cmd := wrap(imageDir "\" file)

if( runAdmin == "true" ) {
	RunWait *RunAs %cmd%
} else {
	RunWait %cmd%
}

ExitApp	


getOption(imageDir) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		return JSON.load(jsonText)
	}
	return {}
}


getExecutableFile(imageDir) {
  option := getOption(imageDir)
  return option.execution.executable
}