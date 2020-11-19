#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

pathRoot := %0%
pathRoot := "\\NAS\emul\image\PS2\_HDL"

files := FileUtil.getFiles( pathRoot, "i).*\.(cue|iso)$", false, true )
total := files.MaxIndex()

for i, file in files {
	debug( ">> " Round(i/total*100,1) "% (" i "/" total ") : " file )
  toChd( file )
  FileUtil.delete(file)
}

ExitApp

toChd( src ) {

  trg := FileUtil.getParentDir(src) "\" FileUtil.getName(src,false) ".chd"

  command := """" A_ScriptDir "\util\chdman.exe"" createcd -i """ src """ -o """ trg """"
	; debug( command )
	RunWait, % command, % workDir, show, pid

}