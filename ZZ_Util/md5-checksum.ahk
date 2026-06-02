#Requires AutoHotkey v2.0
#SingleInstance Force

global appGui := ""
global rows := Map()
global hashValues := Map()
global currentFile := ""
global hashPid := 0
global hashOutputFile := ""
global hashScriptFile := ""
global cfgPath := A_ScriptDir "\md5-checksum.cfg"
global algorithms := [
	{ key: "MD5", label: "MD5" },
	{ key: "SHA-1", label: "SHA-1" },
	{ key: "SHA-256", label: "SHA-256" },
	{ key: "SHA-512", label: "SHA-512" }
]

BuildGui()

if (A_Args.Length > 0)
	ProcessFile(A_Args[1])

return

BuildGui() {
	global appGui, rows, algorithms

	appGui := Gui("+Resize +MinSize760x112", "Checksum")
	appGui.MarginX := 0
	appGui.MarginY := 4
	appGui.SetFont("s9", "Segoe UI")
	appGui.OnEvent("Close", (*) => ExitApp())
	appGui.OnEvent("DropFiles", OnDropFiles)
	appGui.OnEvent("Size", GuiResized)

	for item in algorithms {
		y := A_Index = 1 ? "ym" : "y+2"
		title := appGui.AddText("xm " y " w54 h24 Right +0x200", item.label)
		check := appGui.AddCheckBox("x+2 yp w16 h24")
		value := appGui.AddText("x+1 yp w770 h24 +0x200", "")
		value.SetFont("s8", "Consolas")

		check.Value := LoadOption(item.key)
		check.OnEvent("Click", OptionChanged.Bind(item.key))
		value.OnEvent("DoubleClick", CopyHash.Bind(item.key))

		rows[item.key] := { title: title, check: check, value: value }
	}

	appGui.Show("w848 h112")
}

GuiResized(guiObj, minMax, width, height) {
	global rows, algorithms

	if (minMax = -1)
		return

	for item in algorithms
		rows[item.key].value.Move(,, width - 78)
}

LoadOption(key) {
	global cfgPath

	try
		return IniRead(cfgPath, "Hash", key, "1") != "0"
	catch
		return true
}

SaveOption(key, enabled) {
	global cfgPath

	try
		IniWrite(enabled ? "1" : "0", cfgPath, "Hash", key)
}

OptionChanged(key, ctrl, *) {
	global currentFile

	SaveOption(key, ctrl.Value)
	if (currentFile != "")
		ProcessFile(currentFile)
}

OnDropFiles(guiObj, guiCtrlObj, fileArray, *) {
	if (fileArray.Length > 0)
		ProcessFile(fileArray[1])
}

ProcessFile(path) {
	global currentFile, appGui, rows, algorithms, hashValues

	CancelHash()
	hashValues.Clear()
	ClearValues()

	if !FileExist(path) || InStr(FileExist(path), "D") {
		currentFile := ""
		appGui.Title := "Checksum"
		return
	}

	currentFile := path
	appGui.Title := "Checksum - " GetFileName(path)

	selected := []
	for item in algorithms {
		row := rows[item.key]
		if row.check.Value {
			row.value.Value := "Calculating..."
			selected.Push(item.key)
		}
	}

	if (selected.Length > 0)
		StartHash(path, selected)
}

StartHash(path, selected) {
	global hashPid, hashOutputFile, hashScriptFile

	token := FormatTime(, "yyyyMMddHHmmss") "-" A_TickCount
	hashScriptFile := A_Temp "\md5-checksum-" token ".ps1"
	hashOutputFile := A_Temp "\md5-checksum-" token ".out"

	FileAppend(PowerShellScript(), hashScriptFile, "UTF-8")
	Run("powershell.exe -NoProfile -ExecutionPolicy Bypass -File "
		. QuoteArg(hashScriptFile) " " QuoteArg(path) " " QuoteArg(hashOutputFile) " " QuoteArg(Join(selected, ",")),
		A_ScriptDir, "Hide", &hashPid)
	SetTimer(CheckHashProcess, 200)
}

CheckHashProcess() {
	global hashPid

	if (hashPid && ProcessExist(hashPid))
		return

	SetTimer(CheckHashProcess, 0)
	hashPid := 0
	LoadHashResult()
}

LoadHashResult() {
	global hashOutputFile, rows, algorithms, hashValues

	if (hashOutputFile == "" || !FileExist(hashOutputFile)) {
		CleanupHashFiles()
		return
	}

	result := Map()
	for line in StrSplit(FileRead(hashOutputFile, "UTF-8"), "`n", "`r") {
		pos := InStr(line, "=")
		if (pos > 0)
			result[SubStr(line, 1, pos - 1)] := SubStr(line, pos + 1)
	}

	if (!result.Has("OK") || result["OK"] != "1") {
		ClearValues()
		CleanupHashFiles()
		return
	}

	for item in algorithms {
		row := rows[item.key]
		if !row.check.Value
			continue

		if result.Has(item.key) {
			hashValues[item.key] := result[item.key]
			row.value.Value := result[item.key]
		}
	}

	CleanupHashFiles()
}

CopyHash(key, ctrl, *) {
	global hashValues

	if hashValues.Has(key)
		A_Clipboard := hashValues[key]
}

ClearValues() {
	global rows, algorithms

	for item in algorithms
		rows[item.key].value.Value := ""
}

CancelHash() {
	global hashPid

	SetTimer(CheckHashProcess, 0)
	if (hashPid && ProcessExist(hashPid)) {
		try
			ProcessClose(hashPid)
	}
	hashPid := 0
	CleanupHashFiles()
}

CleanupHashFiles() {
	global hashOutputFile, hashScriptFile

	for path in [hashOutputFile, hashScriptFile] {
		if (path != "" && FileExist(path)) {
			try
				FileDelete(path)
		}
	}
	hashOutputFile := ""
	hashScriptFile := ""
}

GetFileName(path) {
	SplitPath(path, &name)
	return name
}

QuoteArg(value) {
	return '"' StrReplace(value, '"', '\"') '"'
}

Join(values, delimiter) {
	text := ""
	for index, value in values {
		if (index > 1)
			text .= delimiter
		text .= value
	}
	return text
}

PowerShellScript() {
	return "
(
param([string]$Path, [string]$OutPath, [string]$Algorithms)

$ErrorActionPreference = 'Stop'
$encoding = [System.Text.UTF8Encoding]::new($false)
$algorithmNames = $Algorithms -split ',' | Where-Object { $_ }
$hashers = [ordered]@{}

foreach ($name in $algorithmNames) {
	switch ($name) {
		'MD5'     { $hashers[$name] = [System.Security.Cryptography.MD5]::Create(); break }
		'SHA-1'   { $hashers[$name] = [System.Security.Cryptography.SHA1]::Create(); break }
		'SHA-256' { $hashers[$name] = [System.Security.Cryptography.SHA256]::Create(); break }
		'SHA-512' { $hashers[$name] = [System.Security.Cryptography.SHA512]::Create(); break }
	}
}

if ($hashers.Count -eq 0) {
	[System.IO.File]::WriteAllLines($OutPath, @('OK=0'), $encoding)
	exit 0
}

$stream = $null
try {
	$stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
	$buffer = [byte[]]::new(4194304)

	while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
		foreach ($h in $hashers.Values) {
			[void]$h.TransformBlock($buffer, 0, $read, $buffer, 0)
		}
	}

	foreach ($h in $hashers.Values) {
		[void]$h.TransformFinalBlock([byte[]]::new(0), 0, 0)
	}

	$out = [System.Collections.Generic.List[string]]::new()
	$out.Add('OK=1')
	foreach ($name in $algorithmNames) {
		if (!$hashers.Contains($name)) { continue }
		$hex = -join ($hashers[$name].Hash | ForEach-Object { $_.ToString('X2') })
		$out.Add($name + '=' + $hex)
	}
	[System.IO.File]::WriteAllLines($OutPath, $out, $encoding)
} catch {
	[System.IO.File]::WriteAllLines($OutPath, @('OK=0'), $encoding)
} finally {
	if ($stream) { $stream.Dispose() }
	foreach ($h in $hashers.Values) { $h.Dispose() }
}
)"
}
