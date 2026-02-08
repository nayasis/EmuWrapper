#Requires AutoHotkey >=2.0
#Include ..\ZZ_Library\Cli.ahk

cli := Cli("cmd.exe /c echo ok cli", false)
output := cli.readPipe("UTF-8")
if (output != "")
	FileAppend(output, "*")
cli.close()
ExitApp
