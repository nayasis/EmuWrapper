#SingleInstance Force
#Persistent
SetBatchLines -1
Process,Priority,,H
sevPrc:=dllCall("LoadLibrary","Str","7-zip64.dll","Ptr")
global sevProc := dllCall("GetProcAddress","Ptr",sevPrc,"AStr","SevenZip","Ptr")
cnt:=100,file:="zipTest.7z"
global dlltme

timing:=a_tickcount
Loop % cnt
    7ZipCLine("e """ file """ -p" a_index " -y -hide")
timing:=a_tickcount - timing
msgbox % "Timing: " timing " Average: " timing//cnt "`nDll timing: " dlltme " Average: " dlltme//cnt
dllCall("FreeLibrary","Ptr",sevPrc)
exitapp

7ZipCLine(sCommand) {
;    DllCall("Winmm\timeBeginPeriod", uint, 3)
    nSize := 32768
    VarSetCapacity(tOutBuffer,nSize)
    tme:=a_tickcount
    aRet := dllCall(sevProc, "Ptr", hWnd,"AStr", sCommand,"Ptr", &tOutBuffer,"Int", nSize)
    dlltme+=a_tickcount - tme
;    DllCall("Winmm\timeEndPeriod", UInt, 3)
    if(!ErrorLevel)
        return ErrorLevel := aRet
    return 0
}