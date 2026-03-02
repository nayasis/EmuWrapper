#Requires AutoHotkey >=2.0
#SingleInstance Force
#ErrorStdOut

SetWorkingDir A_ScriptDir

scriptPath := A_ScriptFullPath
selfBaseName := StrLower(RegExReplace(A_ScriptName, "\.[^\.]+$"))
files := []

Loop Files, A_ScriptDir "\*.ahk", "F" {
	loopBaseName := StrLower(RegExReplace(A_LoopFileName, "\.[^\.]+$"))
	if (loopBaseName = selfBaseName) {
		continue
	}
	files.Push(A_LoopFileFullPath)
}

if (files.Length = 0) {
	MsgBox "컴파일할 .ahk 파일이 없습니다.", "0_compile_all", "Iconi"
	ExitApp
}

try {
	ahk2exe := resolveAhk2Exe()
	base := toShortPath(resolveBase(ahk2exe))
} catch as err {
	MsgBox "컴파일러 초기화 실패:`n" err.Message, "0_compile_all", "Iconx"
	ExitApp 1
}

ui := Gui("-SysMenu +ToolWindow +AlwaysOnTop", "RA AHK wrapper compiler")
statusText := ui.AddText("w560", "준비 중...")
progress := ui.AddProgress("w560 h22", 0)
ui.Show()

failed := []

for idx, src in files {
	SplitPath src, &fileName
	progress.Value := Floor(((idx - 1) * 100) / files.Length)
	statusText.Value := Format("[{1}/{2}] 컴파일 중: {3}", idx, files.Length, fileName)
	Sleep 10

	errMsg := ""
	if !compileOne(src, ahk2exe, base, &errMsg) {
		failed.Push(fileName)
	}

	progress.Value := Floor((idx * 100) / files.Length)
	Sleep 10
}

ui.Destroy()

okCount := files.Length - failed.Length
summary := Format("완료: {1}/{2} 성공", okCount, files.Length)

if (failed.Length > 0) {
	detail := ""
	limit := Min(failed.Length, 10)
	Loop limit {
		detail .= failed[A_Index] "`n"
	}
	if (failed.Length > limit) {
		detail .= Format("... 외 {1}건", failed.Length - limit)
	}
	MsgBox summary "`n`n실패 목록(" failed.Length "):`n" detail, "일괄 컴파일 완료", "Icon!"
} else {
	MsgBox summary, "일괄 컴파일 완료", "Iconi"
}

ExitApp

compileOne(src, ahk2exe, base, &errMsg) {
	SplitPath src, , &srcDir, , &nameNoExt
	trg := srcDir "\" nameNoExt ".exe"
	cmd := Format('"{}" /in "{}" /out "{}" /base "{}" /compress 0 /cp 65001 /silent verbose'
		, ahk2exe, src, trg, base)
	cmdLine := A_ComSpec ' /d /s /c "' cmd '"'

	try {
		exitCode := RunWait(cmdLine, , "Hide")
	} catch as err {
		errMsg := err.Message
		return false
	}

	if (exitCode != 0) {
		errMsg := "Ahk2Exe exit code: " exitCode
		return false
	}

	errMsg := ""
	return true
}

resolveAhk2Exe() {
	envAhk2Exe := EnvGet("AHK2EXE_PATH")
	envCompilerDir := EnvGet("AHK_COMPILER_DIR")

	if (envAhk2Exe != "" && FileExist(envAhk2Exe)) {
		return envAhk2Exe
	}
	if (envCompilerDir != "" && FileExist(envCompilerDir "\Ahk2Exe.exe")) {
		return envCompilerDir "\Ahk2Exe.exe"
	}

	ahkDir := RegExReplace(A_AhkPath, "\\[^\\]+$", "")
	candidates := [
		A_ProgramFiles "\AutoHotkey\v2\Ahk2Exe.exe",
		A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe",
		A_ProgramFiles "\AutoHotkey\Ahk2Exe.exe",
		ahkDir "\Ahk2Exe.exe"
	]

	for path in candidates {
		if FileExist(path) {
			return path
		}
	}

	throw Error("Ahk2Exe를 찾을 수 없습니다.")
}

resolveBase(ahk2exePath) {
	envBase := EnvGet("AHK_V2_BASE")
	if (envBase != "" && FileExist(envBase)) {
		return envBase
	}

	v2Default := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64.exe"
	if FileExist(v2Default) {
		return v2Default
	}

	compilerDir := RegExReplace(ahk2exePath, "\\[^\\]+$", "")
	consoleBin := compilerDir "\AutoHotkeySC.bin"
	if FileExist(consoleBin) {
		return consoleBin
	}

	guiBin := compilerDir "\Unicode 64-bit.bin"
	if FileExist(guiBin) {
		return guiBin
	}

	throw Error("AHK base binary를 찾을 수 없습니다.")
}

toShortPath(path) {
	if !FileExist(path) {
		return path
	}
	buf := Buffer(260 * 2, 0)
	len := DllCall("GetShortPathNameW", "Str", path, "Ptr", buf, "UInt", buf.Size // 2, "UInt")
	return len ? StrGet(buf) : path
}
