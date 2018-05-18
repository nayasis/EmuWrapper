#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

imageFilePath := %0%

executableFilePath := getExecutableFile( imageFilepath )
if( executableFilePath == "" )
	ExitApp

SplitPath, executableFilePath, , executorDir

RunWait, % executableFilePath, % executorDir,, processId

ExitApp	

getExecutableFile( imageFilePath ) {
	
	dirConf := imageFilepath "\_EL_CONFIG"
	FileUtil.makeDir( dirConf )

	; read json option
	IfExist %dirConf%\option\option.json
	{

		FileRead, jsonText, %dirConf%\option\option.json
		jsonObj := JSON.load( jsonText )

		if( jsonObj.execution.executable != "" )
		{
			return imageFilePath "\" jsonObj.execution.executable
		}

	}

	return ""

}