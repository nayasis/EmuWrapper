EnvGet, userHome, userprofile

targetDir  := userHome "\Documents\Paradox Interactive\Hearts of Iron IV"
sourceRoot := RegExReplace( A_ScriptDir, "(^.+\\).+", "$1" ) "bin"

debug( targetDir )
debug( sourceRoot )

IfNotExist, % targetDir
	FileCreateDir, % targetDir

IfNotExist, % targetDir "\mod"
{
	debug( "file copy : " sourceRoot "\mod -> " targetDir )
  FileCopyDir, % sourceRoot "\mod", % targetDir "\mod"
}

IfNotExist, % targetDir "\workshop"
{
	debug( "file copy : " sourceRoot "\workshop -> " targetDir )
  FileCopyDir, % sourceRoot "\workshop", % targetDir "\workshop"
}

ExitApp

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}