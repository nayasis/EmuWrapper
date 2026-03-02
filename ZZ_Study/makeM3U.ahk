#Requires AutoHotkey >=2.0

fileM3u := ""
content := ""

for n, param in A_Args {
	if( fileM3u == "" ) {
		fileM3u := getDir(param)
		fileM3u .= "\" getName(fileM3u) ".m3u"
	}
	content .= getName(param) "`n"
}

if (fileM3u == "")
	ExitApp 1

write(fileM3u,content)

ExitApp


debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend(message, "*")
}

getDir( path ) {
	path := RegExReplace( path, "^(.*?)\\$", "$1" )
	path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
	return path
}

getName( filePath, withExt:=true ) {
	filePath := RegExReplace( filePath, "^(.*?)\\$", "$1" )
	SplitPath filePath, &fileName, &fileDir, &fileExtention, &fileNameWithoutExtension, &DriveName
	if( withExt == true )
		return fileName
	return fileNameWithoutExtension
}

write( path, content:="" ) {
	if (path == "")
		return false
	parentDir := RegExReplace(path, "\\[^\\]+$", "")
	if (parentDir != "" && !DirExist(parentDir))
		DirCreate(parentDir)
	if FileExist(path)
		FileDelete(path)
	; RetroArch reads BOM bytes as visible characters in the first disk path.
	FileAppend(content, path, "UTF-8-RAW")
	return true
}
