EnvGet, userHome, userprofile

targetDir  := userHome "\AppData\Local\Eushully\Himegair__DG__SKI__Meister"
targetPath := userHome targetDir "\SYS4REG.INI"
sourcePath := RegExReplace( A_ScriptDir, "(^.+\\).+", "$1" ) "script\SYS4REG.INI"

debug( targetPath )
debug( sourcePath )

IfNotExist, % targetDir
	FileCreateDir, % targetDir

IfExist, % targetPath
	IniWrite, 1, %targetPath%, display, VirtualFullScreen

IfNotExist, % targetPath
  FileCopy, % sourcePath, % targetPath, 1

ExitApp

debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}