#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

pathRoot := "f:\download\dc"

debug( "start" )

files   := FileUtil.getFiles( pathRoot, "i).*\.(chd)", false, true )
srcDirs := {}

; gathering files
Loop, % files.MaxIndex()
{
	fileSrc := files[ A_Index ]
	srcDir  := FileUtil.getDir( fileSrc )

  if ( srcDirs[srcDir] == "" ) {
  	srcDirs[srcDir]  := []
  }

  srcDirs[srcDir].insert( fileSrc )
}

for srcDir, files in srcDirs {
	if ( files.MaxIndex() <= 1 )
		continue
	fileM3u := srcDir "/multi-disk.m3u"
	m3uText := ""
	for idx, fileName in files {
		m3uText .= FileUtil.getFileName( fileName ) "`n"
		; debug( "`t " FileUtil.getFileName( fileName ) )
	}
	FileUtil.delete( fileM3u )
	FileAppend, % m3uText, % fileM3u
}

debug( "end" )

ExitApp