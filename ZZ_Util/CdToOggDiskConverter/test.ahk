#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

IfWinExist, ahk_exe TurboRip.exe
{
	debug( "found!")
	WinGetText, out, ahk_exe TurboRip.exe
	debug( ">> out : " out )
}

path := "e:\download\mcd\Tomcat Alley (USA)\tmp\Tomcat Alley (USA)\"

max := ""

while True
{
	Sleep, 1000

  curr := lastModified( path )
  debug( "max : " max ", curr :" curr )

  if( max == curr ) {
  	debug( "no more !!")
  	break
  } else {
  	max := curr
  	
  }

}


ExitApp

lastModified( path ) {

  max := ""

	files := FileUtil.getFiles( path )

	for i,file in files
	{
		curr := FileUtil.getTime(file,"M")
		debug( "file : " file ",last : " curr)
		if( curr > max )
		  max := curr
	}

	return max

}