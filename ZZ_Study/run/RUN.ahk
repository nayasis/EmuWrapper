#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

FileEncoding("UTF-8")
DetectHiddenWindows(true)

global applicationPid       := ""
global applicationCloseWait := ""
global applicationCloseWin  := ""
global applicationCloseProc := ""

baseName := FileUtil.getName(A_ScriptName, false)
fileIni := A_ScriptDir "\" baseName ".ini"
fileReg := A_ScriptDir "\" baseName ".reg"

runAsAdmin( fileIni )

prop := readProperties( fileIni )

setEnvVariable( fileIni, prop )
setRegistry( fileReg, prop )

runSub( "pre", fileIni, prop )
runMain( fileIni, prop )
runSub( "post", fileIni, prop )

closeApp()

ExitApp()

closeApp(*) {
	closeProcess()
	ResolutionChanger.restore()
	Taskbar.show(true)
	MouseCursor.show()	
	ExitApp()
}

closeProcess() {
	global applicationPid, applicationCloseWait, applicationCloseWin, applicationCloseProc
	debug(">> close process")
	if( applicationPid != "" ) {
		debug("  - applicationId: " applicationPid)
		ProcessClose(applicationPid)
	}
	if( applicationCloseWait != "" ) {
		debug("  - applicationCloseWait: " applicationCloseWait)
		ProcessClose(applicationCloseWait)
	}
	if( applicationCloseWin != "" ) {
		debug("  - applicationCloseWin: " applicationCloseWin)
		ProcessClose(applicationCloseWin)
	}
	if( applicationCloseProc != "" ) {
		debug("  - applicationCloseProc: " applicationCloseProc)
		ProcessClose(applicationCloseProc)
	}
}

runAsAdmin(fileIni) {
	value := readIni(fileIni, "init", "runAsAdmin", "", "false")
	if ( value == "true" ) {
		Environment.restartAsAdmin()
	}
}

runMidThread() {
	global fileIni, prop
	runSub( "mid", fileIni, prop )
}

runSub( section, fileIni, properties ) {

	debug(">> run " section)

  indices := ["", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  for _, loopField in indices
  {
		writeRule    := readIni(fileIni, section, "write" loopField,        properties, "_")
		writeCharset := readIni(fileIni, section, "write" loopField "Charset", properties, "CP0")
		if ( writeRule != "_" ) {
			writeTemplateFile(writeRule, properties, writeCharset)
		}
  }

  for _, loopField in indices
  {
		executor      := readIni(fileIni, section, "executor" loopField,         properties, "_")
		executorDir   := readIni(fileIni, section, "executor" loopField "Dir",   properties, "_")
		executorDelay := readIni(fileIni, section, "executor" loopField "Delay", properties, "_")
		executorWait  := readIni(fileIni, section, "executor" loopField "Wait",  properties, "true")
    executorDelay := RegExReplace( executorDelay, "[^0-9]", "" )
    if ( executorDelay != "" ) {
    	Sleep(executorDelay)
    }
		if ( executor != "_" ) {
			executorWait  := (executorWait == "true" || executorWait == "_")
			runSubHelper( executor, executorDir, executorWait, properties )
		}
  }

  resolution      := readIni(fileIni, section, "resolution",    properties, "_")
  resolutionDelay := readIni(fileIni, section, "resolutionSec", properties, "_")
  if( resolution != "_" ) {
    if( resolutionDelay != "_" && resolutionDelay != "" ) {
    	Sleep(resolutionDelay)
    }
    changeResolution(resolution)
  }

  for _, loopField in indices
  {
	  waitWin         := readIni(fileIni, section, "waitWin"   loopField,       properties, "_")
	  waitWinSec      := readIni(fileIni, section, "waitWin"   loopField "Sec", properties, "10")
	  waitProc        := readIni(fileIni, section, "waitProc"  loopField,       properties, "_")
	  waitProcSec     := readIni(fileIni, section, "waitProc"  loopField "Sec", properties, "10")

		if ( waitWin != "_" ) {
			applicationwaitWin := RegExReplace(waitWin,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- waitWin : " waitWin )
			WinWait(waitWin,, waitWinSec)
			if WinExist(waitWin) {
				debug("wait win close : " waitWin)
				WinWaitClose(waitWin)
			}
			else {
				break
			}
		}

		if ( waitProc != "_" ) {
			applicationCloseProc := waitProc
			debug("- waitProc : " waitProc )
			ProcessWait(waitProc, waitProcSec)
			if(ProcessExistsByName(waitProc)) {
				debug("wait proc close: " waitProc)
				ProcessWaitClose(waitProc)
			} else {
				break
			}
		}

  }

  for _, loopField in indices
  {
    closeWin        := readIni(fileIni, section, "closeWin"  loopField,       properties, "_")
    closeWinSec     := readIni(fileIni, section, "closeWin"  loopField "Sec", properties, "10")
    closeProc       := readIni(fileIni, section, "closeProc" loopField,       properties, "_")
    closeProcSec    := readIni(fileIni, section, "closeProc" loopField "Sec", properties, "10")

		if ( closeWin != "_" ) {
			applicationCloseWin := RegExReplace(closeWin,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- closeWin : " closeWin )
			WinWait(closeWin,, closeWinSec)
			WinClose(closeWin)
		}

		if ( closeProc != "_" ) {
			applicationCloseProc := RegExReplace(closeProc,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- closeProc : " closeProc )
			ProcessWait(closeProc, closeProcSec)
			ProcessClose(closeProc)
		}
  }

}

ProcessExistsByName(name) {
	return ProcessExist(name) != 0
}

runSubHelper( executor, executorDir, executorWait, properties ) {
	if ( executor == "_" )
		return
  if( InStr(executor, ":scriptEnter\", true) ) {
  	param := StrReplace(executor, ":scriptEnter\","")
  	scriptEnter(param)
  	return
  }
  if( InStr(executor, ":scriptClick\", true) ) {
  	param := StrReplace(executor, ":scriptClick\","")
  	param := StrSplit(param, ",")
  	debug(param[1] "," param[2] "," param[3])
  	scriptClick(param[1],param[2],param[3])
  	return
  }
  if( InStr(executor, ":scriptFocus\", true) ) {
  	param := StrReplace(executor, ":scriptFocus\","")
  	scriptFocus(param)
  	return
  }
	executor    := RegExReplace( executor,    "\\", "\\" )
	executorDir := RegExReplace( executorDir, "\\", "\\" )
	if ( executorDir == "_" ) {
		executorDir := getRunDir(executor)
	}
	if ( executorWait == true ) {
		appRunWait(executor, executorDir)
	} else {
		appRun(executor, executorDir)
	}
}

runMain( fileIni, properties ) {
	global applicationPid

  debug(">> run main")

  executor          := readIni(fileIni, "init",   "executor",     properties, "_")
  unblockPath       := readIni(fileIni, "init",   "unblockPath",  properties, "_")
  executorDir       := readIni(fileIni, "init",   "executorDir",  properties, "_")
  resolution        := readIni(fileIni, "init",   "resolution",   properties, "_")
  hideTaskbar       := readIni(fileIni, "init",   "hideTaskbar",  properties, "_")
  hideMouse         := readIni(fileIni, "init",   "hideMouse",    properties, "_")
  symlink           := readIni(fileIni, "init",   "symlink",      properties, "_")
  blockNetworkRule  := readIni(fileIni, "init",   "blockNetwork", properties, "_")
  isRunWait         := readIni(fileIni, "init",   "runwait",      properties, true)
  exitAltF4         := readIni(fileIni, "init",   "exitAltF4",    properties, true)
  fontPath          := readIni(fileIni, "init",   "font",         properties, "_")
  mountImage        := readIni(fileIni, "init",   "mountImage",   properties, "_")
  windowTarget      := readIni(fileIni, "window", "target",       properties, "_")
  windowSearchDelay := readIni(fileIni, "window", "searchDelay",  properties, 0)
  windowStart       := readIni(fileIni, "window", "start",        properties, "_")
  windowSize        := readIni(fileIni, "window", "size",         properties, "_")
  windowBorderless  := readIni(fileIni, "window", "borderless",   properties, false)
  windowNeedResize  := ( windowStart != "_" || windowSize != "_" )

  makeSymlink(symlink)

  if ( unblockPath != "_" ) {
  	unblockFile(unblockPath)
  }

	if ( resolution != "_" ) {
		changeResolution( resolution )
		if ( windowSize == "_" ) {
		    windowSize := resolution
		}
	}

	blockNetwork(blockNetworkRule)
  installFont(fontPath, properties)

	if ( mountImage != "_" ) {
		mountDisk(mountImage)
	}

  if ( exitAltF4 == "true" )
  	Hotkey("!F4", closeApp)

	if ( windowStart == "_" )
	  windowStart := "0,0"

	if ( windowSize == "_" )
		windowSize := A_ScreenWidth "x" A_ScreenHeight

	if ( hideTaskbar == "true" )
		Taskbar.hide()

	if ( hideMouse == "true" )
		MouseCursor.hide()

	if ( executor != "_" ) {

    SetTimer(runMidThread, -500)

		if ( executorDir == "_" )
		  executorDir := getRunDir(executor)

		debug( "executor     : " executor     )
		debug( "executorDir  : " executorDir  )
		debug( "windowTarget : " windowTarget )
		debug( "isRunWait    : " isRunWait    )

		if ( windowTarget != "_" ) {

			applicationPid := appRun(executor,executorDir,false,false)
			If(applicationPid == "")
				return
			Sleep(windowSearchDelay)
			WinWait(windowTarget,, 10)
			if !WinExist(windowTarget) {
				MsgBox("There is no window to wait.`n`n - " windowTarget)
				return
			} else {
				applicationPid := WinGetPID(windowTarget)
			  startX := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$1" ) )
			  startY := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$2" ) )
		    width  := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
		    height := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
				debug( "target:" windowTarget ", borderless:" windowBorderless ", need resize:" windowNeedResize ", start:(" startX "," startY "), resolution:" width "x" height )

				WinActivate(windowTarget)
		    if ( windowBorderless == "true" ) {
		    	debug("- set borderless")
					WinSetStyle("-0xC40000", windowTarget)
		    }
		    if( windowNeedResize == true )  {
		    	debug("- resize")
					WinMove(startX, startY, width, height, windowTarget)
					MouseMove(width + startY, height + startX)
		    }

				WinWaitClose(windowTarget)

			}

		} else if ( isRunWait == true ) {
			appRunWait(executor,executorDir,false)
			; applicationPid := appRun(executor,executorDir)
			; Process, Wait, % applicationPid
		} else {
			appRun(executor,executorDir,false,false)
		}

		if ( mountImage != "_" ) {
			unmountDisk(mountImage)
		}

	}

}

blockNetwork(param) {
	if (param == "_")
		return
	rules := StrSplit(param, ";")
	for i, rule in rules {
		arr := StrSplit(rule, "->")
		if (arr.Length == 2) {
			name := Trim(arr[1])
			path := Trim(arr[2])
			Network.block(name, path)
		}
	}
}

installFont(fontDir, properties) {
	if ( fontDir == "_" )
		return
	winDir := properties["windir"] "\Fonts"
	fonts  := FileUtil.getFiles(fontDir)
	for i, path in fonts {
		installed := winDir "\" FileUtil.getName(path)
		sourceHash := FileUtil.hashMD5(path)
		installedHash := FileUtil.isFile(installed) ? FileUtil.hashMD5(installed) : ""
		needInstall := (!FileUtil.isFile(installed) || sourceHash == "" || installedHash == "" || sourceHash != installedHash)
		if( needInstall ) {
			debug(">> install font : " path " -> " installed)
			debug("   md5 source : " sourceHash)
			debug("   md5 target : " installedHash)
			Environment.restartAsAdmin()
			FileCopy(path, installed, true)
			DllCall("AddFontResource", "Str", installed)
			SendMessage(0x1D, 0, 0,, "ahk_id 0xFFFF")
		}
	}
	
}

readProperties(file) {
	prop := FileUtil.readIni(file, "properties")
	if (Type(prop) != "Map")
		prop := Map()

	prop["cd"      ] := A_ScriptDir
	prop["cdWin"   ] := RegExReplace( A_ScriptDir, "\\", "\\" ) ; double file seperator slash
	prop["cdUnix"  ] := RegExReplace( A_ScriptDir, "\\", "/" ) ; normal file seperator
	prop["home"    ] := EnvGet("userprofile")
  prop["windir"  ] := EnvGet("SystemRoot")
  prop["appdata" ] := EnvGet("APPDATA")
  prop["sid"     ] := readSID()
  prop["drive"   ] := readDrive()
	return prop
}

readSID() {
	sid := ""
	Loop Reg, "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", "R"
  {
    if (A_LoopRegName = "ProfileImagePath")
    {
			try outputVar := RegRead(A_LoopRegKey, A_LoopRegName)
			catch
				outputVar := ""
      if InStr(outputVar, A_UserName)
        sid := RegExReplace(A_LoopRegKey, "i)^.*ProfileList\\")
    }
  }
  return sid
}

readDrive() {
	root := EnvGet("SystemDrive")
	root := StrReplace(root, ":")
	return root
}

setEnvVariable( fileIni, properties ) {

	env := readIni(fileIni, "init", "env", properties, "_")

	if( env == "_" )
	  return
	envs := StrSplit( "" env, ";" )

	for i, env in envs {

		overwrite := true

		key := "____"
		val := "____"

		path := StrSplit( env, "+=" )
		if ( path.Length == 2 ) {
			key := Trim( path[1] )
			val := Trim( path[2] )
			overwrite := false
		} else {
			path := StrSplit( env, "=" )
			if ( path.Length == 2 ) {
				key := Trim( path[1] )
				val := Trim( path[2] )
				overwrite := true
			} if ( path.Length == 1 ) {
				key := Trim( path[1] )
				val := ""
				overwrite := true
			}
		}

		if( key != "____" && val != "____" ) {

      key := bindValue( key, properties )
      val := bindValue( val, properties )

			debug( ">> EnvSet"                 )
			debug( "   key       : " key       )
			debug( "   value     : " val       )
			debug( "   overwrite : " overwrite )

			prevEnv := ""

			if( overwrite == false ) {
				prevEnv := EnvGet(key)
			}

			if( prevEnv != "" ) {
				EnvSet(key, prevEnv ";" val)
			} else {
				EnvSet(key, val)
			}

		}

	}

}

appRun(executor, executorDir:="", wait:=false, hide:=true) {
	if(wait == true) {
		debug(">> run - wait")
	} else {
		debug(">> run - no wait")
	}
	debug("- exe: " executor)
	debug("- dir: " executorDir)

  option := "UseErrorLevel"
	if(hide) {
		option .= " Hide"
	}

	debug("- option: " option)

	if(wait == true) {
		try {
			RunWait(executor, executorDir, option)
			processId := ""
		} catch Error as err {
			debug("Error Level : ERROR")
			MsgBox("There is no application to run.`n`n - " executor)
			debug(err.Message)
			processId := ""
		}
	} else {
		try {
			processId := Run(executor, executorDir, option)
		} catch Error as err {
			debug("Error Level : ERROR")
			MsgBox("There is no application to run.`n`n - " executor)
			debug(err.Message)
			processId := ""
		}
	}
	return processId
}

appRunWait(executor, executorDir:="", hide:=true) {
	return appRun(executor, executorDir, true, hide)
}

getRunDir(executor) {
	target := getRunTarget(executor)
	SplitPath(target, , &executorDir)
	return executorDir
}

getRunTarget(executor) {
	executor := Trim(executor)
	if ( executor == "" ) {
		return ""
	}

	if RegExMatch(executor, '^\s*"([^"]+)"', &match) {
		return match[1]
	}

	if RegExMatch(executor, 'i)^\s*(.+?\.(?:exe|bat|cmd|com|ahk|lnk|msi|ps1|vbs))(?=\s|$)', &match) {
		return match[1]
	}

	return StrSplit(executor, A_Space, , 2)[1]
}

readIni(fileIni, section, key, properties := "", defaultValue := "_") {
	value := FileUtil.readIni(fileIni, section, key, defaultValue)

	if (Type(properties) == "Map")
		return bindValue(value, properties)
	return value
}

scriptEnter(waitCmd) {
	WinWait(waitCmd)
	if WinExist(waitCmd)
	{
		WinActivate(waitCmd)
		Send("{Enter}")
	}
}

scriptFocus(waitCmd) {
	WinWait(waitCmd)
	if WinExist(waitCmd)
	{
		WinActivate(waitCmd)
	}
}

scriptClick(waitCmd, px, py) {
	WinWait(waitCmd)
	if WinExist(waitCmd)
	{
		WinActivate(waitCmd)
		Click(px, py)
	}
}

/**
* Set Registry from file
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
setRegistry(file, properties) {
	if !FileExist(file)
		return
	Registry.setProps(properties)
	Registry.write(file)
}

writeTemplateFile(writeRule, properties, charset := "CP0") {
	path := StrSplit(writeRule, "->")
	if ( path.Length != 2 ) {
		debug(">> write skipped: invalid rule - " writeRule)
		return
	}

	sourceFile := Trim(path[1])
	targetFile := Trim(path[2])
	if (sourceFile = "" || targetFile = "") {
		debug(">> write skipped: empty source/target - " writeRule)
		return
	}
	if !FileExist(sourceFile) {
		debug(">> write skipped: source missing - " sourceFile)
		return
	}

	debug(">> write file")
	debug("   source : " sourceFile)
	debug("   target : " targetFile)
	debug("   charset: " charset)

	content := FileRead(sourceFile)
	content := bindValue(content, properties)

	SplitPath(targetFile, , &targetDir)
	if (targetDir != "" && !DirExist(targetDir)) {
		DirCreate(targetDir)
	}

	file := FileOpen(targetFile, "w", normalizeWriteCharset(charset))
	file.Write(content)
	file.Close()
}

normalizeWriteCharset(charset) {
	charset := Trim(charset)
	if (charset = "" || charset = "_")
		return "CP0"

	upperCharset := StrUpper(charset)
	if (upperCharset = "UTF8")
		return "UTF-8"
	if (upperCharset = "UTF8-RAW" || upperCharset = "UTF-8-RAW")
		return "UTF-8-RAW"
	if (upperCharset = "UTF16")
		return "UTF-16"
	if (upperCharset = "UTF16-RAW" || upperCharset = "UTF-16-RAW")
		return "UTF-16-RAW"

	return charset
}

bindValue( value, properties ) {
	For key, val in properties
		value := StrReplace( value, "${" key "}", val )
	return value
}

unblockFile(path) {
	zoneIdentifier := path ":Zone.Identifier"
	if !DllCall("DeleteFile", "Str", zoneIdentifier, "Int") {
		lastError := A_LastError
		if (lastError != 2) {
			debug(">> unblock skipped: " zoneIdentifier " (error: " lastError ")")
		}
	}
}

makeSymlink( symlink ) {

	if ( symlink == "_" )
		return

	if(! FileUtil.hasSymlinkAuth()) {
		debug(">> No symlink creating auth. run as Admin again")
		Environment.restartAsAdmin()
		FileUtil.createSymlinkAuth()
	}

	links := StrSplit( symlink, ";" )

	for i, link in links {
		debug( "link : " link )
		path := StrSplit( link, "->" )
		if ( path.Length == 2 ) {
			sourceDir := Trim( path[1] )
			targetDir := Trim( path[2] )
			if (sourceDir = "" || targetDir = "")
				continue
			debug( ">> Make symlink" )
			debug( "   sourceDir : " sourceDir )
			debug( "   targetDir : " targetDir )
			try FileUtil.makeLink(sourceDir, targetDir, true)
			catch Error as err {
				debug("   symlink skipped: " err.Message)
			}
		}
	}

}

changeResolution( resolutionConfig ) {
	if ( resolutionConfig != "_" ) {
    width  := Trim( RegExReplace( resolutionConfig, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
    height := Trim( RegExReplace( resolutionConfig, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
		ResolutionChanger.change( width, height )
	}
}

mountDisk(path) {
	cmd := wrap(path)
	cmd := wrap("-ImagePath " cmd)
	cmd := "powershell -WindowStyle Hidden Mount-DiskImage " cmd
	appRunWait(cmd)
}

unmountDisk(path) {
	cmd := wrap(path)
	cmd := wrap("-ImagePath " cmd)
	cmd := "powershell -WindowStyle Hidden Dismount-DiskImage " cmd
	appRunWait(cmd)
}
