#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

imageDir := %0%
; imageDir := "G:\emuloader-decompress\PC\PC-001168"

file := getExecutableFile( imageDir )
debug("file:" file)
if( file == "" )
	ExitApp

if( FileUtil.isFile(imageDir "\" file) ) {
	RunWait, % imageDir "\" file, % imageDir,, processId		
}

ExitApp	

getExecutableFile( imageDir ) {
	
	dirConf := imageDir "\_EL_CONFIG"
	debug(dirConf)

	; read json option
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		debug(jsonText)
		jsonObj := JSON.load(jsonText)
		debug(jsonObj.execution.executable)
		return jsonObj.execution.executable
	}
	return ""

}