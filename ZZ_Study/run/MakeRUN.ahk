#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
FileEncoding, EUC-KR

fileRun := %0%
; fileRun := "e:\download\Dying Light 2 (ko)\bin\ph\work\bin\x64\DyingLightGame_x64_rwdi.exe"

rootDir := getRoot(fileRun)

debug("file : " fileRun)
debug("root : " rootDir )

writeConfig(rootDir,fileRun)
FileUtil.copy(A_ScriptDir "\RUN.exe", rootDir)

ExitApp

getRoot(fileRun) {

  parent := fileRun
  root   := ""

	Loop, 20
	{
	  temp   := FileUtil.getParentDir(parent)
	  if(temp == parent) {
	  	break
	  }
	  parent := temp
	  name   := FileUtil.getName(parent)
	  debug("idx  : " a_index)
	  debug("dir  : "  parent)
	  debug("name : " name)
	  if(FileUtil.getName(parent) == "bin") {
	  	root := FileUtil.getParentDir(parent)
	  }		
	}

	if(root == "") {
		return FileUtil.getParentDir(fileRun)
	} else {
		return root
	}

}

writeConfig(rootDir, fileRun) {
	executor := "${cd}" StrReplace(fileRun, rootDir, "")
	content  =
	(
[init]
executor    = %executor%
#unblockPath = %executor%
	)
	FileUtil.write(rootDir "\RUN.ini", content)
}