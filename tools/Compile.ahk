#Requires AutoHotkey >=2.0
#ErrorStdOut
#SingleInstance Force

; Usage:
;   AutoHotkey64.exe tools\Compile.ahk path\to\WrapperAppleWin.ahk
;   tools\run_ahk.ps1 .\tools\Compile.ahk .\apple2e\AppleWin1.30.20\WrapperAppleWin.ahk

if (A_Args.Length < 1) {
	writeErr("Usage: Compile.ahk <script.ahk>")
	ExitApp(1)
}

srcInput := A_Args[1]
src := resolveInput(srcInput)

if !FileExist(src) {
	writeErr("입력 스크립트가 없습니다: " srcInput)
	ExitApp(1)
}

writeOut("컴파일 시작: " src)

; Ahk2Exe는 AutoHotkey와 같은 폴더에 있음 (v2 우선)
ahkDir := A_AhkPath ? RegExReplace(A_AhkPath, "\\[^\\]+$", "") : ""
ahk2exe := ""

envAhk2Exe := EnvGet("AHK2EXE_PATH")
envCompilerDir := EnvGet("AHK_COMPILER_DIR")
if (envAhk2Exe != "" && FileExist(envAhk2Exe)) {
	ahk2exe := envAhk2Exe
} else if (envCompilerDir != "" && FileExist(envCompilerDir "\Ahk2Exe.exe")) {
	ahk2exe := envCompilerDir "\Ahk2Exe.exe"
}

for path in [
	A_ProgramFiles "\AutoHotkey\v2\Ahk2Exe.exe",
	A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe",
	A_ProgramFiles "\AutoHotkey\Ahk2Exe.exe",
	ahkDir "\Ahk2Exe.exe"
] {
	if (ahk2exe != "")
		break
	if FileExist(path) {
		ahk2exe := path
		break
	}
}

if !FileExist(ahk2exe) {
	writeErr("Ahk2Exe를 찾을 수 없습니다. AutoHotkey v2 컴파일러가 필요합니다.`nAHK2EXE_PATH 또는 AHK_COMPILER_DIR 환경변수로 경로를 지정하세요.`n" A_AhkPath)
	ExitApp(1)
}

compilerDir := RegExReplace(ahk2exe, "\\[^\\]+$", "")
if (envCompilerDir != "" && FileExist(envCompilerDir))
	compilerDir := envCompilerDir
base := resolveBase(compilerDir, ahkDir)

try {
	compileOne(src, ahk2exe, base)
} catch as err {
	writeErr("compile failed: " src "`n" err.Message)
	ExitApp(1)
}

ExitApp

compileOne(src, ahk2exe, base) {
	trg := getDir(src) "\" getName(src, false) ".exe"
	cmd := '"' ahk2exe '" /in "' src '" /out "' trg '" /base "' base '" /compress 0 /cp 65001 /silent verbose'
	exitCode := RunWait(cmd, , "Hide")
	if (exitCode != 0)
		throw Error("Ahk2Exe exit code: " exitCode)
	writeOut("컴파일 완료: " trg)
}

resolveInput(path) {
	if RegExMatch(path, "i)^(?:[a-z]:\\|\\\\)")
		return path
	return normalizePath(A_WorkingDir "\" path)
}

getDir(path) {
	path := RegExReplace(path, "^(.*?)\\$", "$1")
	SplitPath(path, , &dir)
	return dir
}

getName(path, withExt := true) {
	path := RegExReplace(path, "^(.*?)\\$", "$1")
	SplitPath(path, &fileName, , &fileExt, &nameNoExt)
	return withExt ? fileName : nameNoExt
}

normalizePath(path) {
	return RegExReplace(path, "\\+", "\")
}

resolveBase(compilerDir, ahkDir) {
	v2Base := EnvGet("AHK_V2_BASE")
	if (v2Base != "" && FileExist(v2Base))
		return v2Base
	v2Default := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64.exe"
	if FileExist(v2Default)
		return v2Default
	consoleBin := compilerDir "\AutoHotkeySC.bin"
	if FileExist(consoleBin)
		return consoleBin
	guiBin := compilerDir "\Unicode 64-bit.bin"
	if FileExist(guiBin)
		return guiBin
	if (ahkDir != "") {
		consoleBin := ahkDir "\AutoHotkeySC.bin"
		if FileExist(consoleBin)
			return consoleBin
		guiBin := ahkDir "\Unicode 64-bit.bin"
		if FileExist(guiBin)
			return guiBin
	}
	throw Error("AHK base binary not found in compiler or AHK dir.")
}

writeErr(msg) {
	writeStd(msg, "**")
}

writeOut(msg) {
	writeStd(msg, "*")
}

writeStd(msg, stream := "*") {
	log := EnvGet("AHK_STDOUT_LOG")
	if (log != "") {
		FileAppend(msg "`n", log)
		return
	}
	FileAppend(msg "`n", stream)
}
