#NoEnv

SplitPath, A_WorkingDir,, parent

fileIni := parent "\bin\mods\ModsDB.ini"

debug( fileIni )

IniDelete, % fileIni, Mods

IniWrite, % """" parent "\bin\mods\KoreanPatchMod1\mod.ini""", % fileIni, Mods, KoreanPatchMod1
IniWrite, % """" parent "\bin\mods\KoreanPatchMod2\mod.ini""", % fileIni, Mods, KoreanPatchMod2
IniWrite, % """" parent "\bin\mods\KoreanPatchMod3\mod.ini""", % fileIni, Mods, KoreanPatchMod3

ExitApp


debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}