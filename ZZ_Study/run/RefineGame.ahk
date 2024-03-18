#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
FileEncoding, CP949

targetDir := %0%

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
	if(FileUtil.exist(rootDir "\bin\font")) {
		content .= "`nfont        = ${cd}\bin\font"
	} else {
    content .= "`n#font        = ${cd}\bin\font"
	}
	FileUtil.write(rootDir "\RUN.ini", content)
}