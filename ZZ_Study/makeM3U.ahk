#NoEnv

fileM3u := ""
content := ""

for n, param in A_Args {
	if( fileM3u == "" ) {
		fileM3u := getDir(param)
		fileM3u .= "\" getName(fileM3u) ".m3u"
	}
	content .= getName(param) "`n"
}

write(fileM3u,content)

ExitApp


debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}

getDir( path ) {
	path := RegExReplace( path, "^(.*?)\\$", "$1" )
	path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
	return path
}

getName( filePath, withExt:=true ) {
	filePath := RegExReplace( filePath, "^(.*?)\\$", "$1" )
	SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
	if( withExt == true )
		return fileName
	return fileNameWithoutExtension
}

write( path, content="" ) {
	this.makeParentDir( path )
	FileDelete, % path
	FileAppend, % content, % path
}