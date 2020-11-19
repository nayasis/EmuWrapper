#NoEnv

while( err != "0" ) {
	RunWait, % "FF7_Launcher.exe"
	err := ErrorLevel ""
	debug( err )
}

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}