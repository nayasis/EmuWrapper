#Requires AutoHotkey >=2.0

try FileDelete(A_ScriptDir "\args.txt")
FileAppend("0=" %0% "`n1=" %1%, A_ScriptDir "\args.txt", "UTF-8")
