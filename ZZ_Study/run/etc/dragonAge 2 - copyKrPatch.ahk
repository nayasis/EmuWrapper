EnvGet, userHome, userprofile

targetPath := userHome "\Documents\BioWare\Dragon Age 2"
sourcePath := RegExReplace( A_ScriptDir, "(^.+\\).+", "$1" ) "bin\Dragon Age 2"

IfNotExist, % targetPath
{
	FileCopyDir, % sourcePath, % targetPath, 1
}

ExitApp

debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}