#NoEnv
#include c:\app\emulator\ZZ_Library\Include.ahk

RunAs, Administrator, Wjdghktn066^
debug( "~ start")

; Environment.restartAsAdmin()

output := FileUtil.cli( """c:\app\emulator\ZZ_Util\ps2-hdl-dump\hdl_dump_090.exe"" query | findstr ""hdd""" )
debug( output )

debug( "~ end")

ExitApp