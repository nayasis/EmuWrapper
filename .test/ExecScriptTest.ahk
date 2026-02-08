#Requires AutoHotkey >=2.0
#Include ..\ZZ_Library\ExecScript.ahk

code := 'FileAppend("ok exec`n", "*")`nExitApp'
exec := ExecScript(code, [], "name=*")
if IsObject(exec) {
	out := exec.StdOut.ReadAll()
	if (out != "")
		FileAppend(out, "*")
}
ExitApp
