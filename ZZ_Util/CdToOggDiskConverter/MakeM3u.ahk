#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

; pathRoot := "f:\download\dc"
; pathRoot := "\\NAS\emul\image\PC88\Acchi Muite Hoi! (19xx)"
pathRoot := "\\NAS\emul\image\PC98"

debug( ">> start" )

files   := FileUtil.getFiles( pathRoot, "i).*\.(d88|fdd|fdi)$", false, true )
srcDirs := {}

debug( ">> read files")
; gathering files
Loop, % files.MaxIndex()
{
	fileSrc := files[ A_Index ]
	srcDir  := FileUtil.getDir( fileSrc )

  if ( srcDirs[srcDir] == "" ) {
  	srcDirs[srcDir]  := []
  }

  srcDirs[srcDir].insert( fileSrc )
  debug( srcDir " :: " fileSrc )
}

debug( ">> write m3u")

for srcDir, files in srcDirs {
	debug( srcDir " has " files.MaxIndex() )
	if ( files.MaxIndex() <= 1 )
		continue
	fileM3u := srcDir "/multi-disk.m3u"
	m3uText := ""
	for idx, fileName in files {
		m3uText .= FileUtil.getName( fileName ) "`n"
		debug( "`t " FileUtil.getName( fileName ) )
	}
	FileUtil.delete( fileM3u )
	FileAppend, % m3uText, % fileM3u
}

debug( ">> end" )

ExitApp