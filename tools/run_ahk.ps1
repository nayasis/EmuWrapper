param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Target,

  [string]$AhkExe = "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"
)

$logFile = Join-Path $env:TEMP ("ahk_stdout_{0}.log" -f ([guid]::NewGuid().ToString("n")))
$env:AHK_STDOUT_LOG = $logFile
New-Item -ItemType File -Path $logFile -Force | Out-Null

if ($Target -match '\.exe$') {
  & $Target /ErrorStdOut @Args 2>&1
  $found = $false
  for ($i = 0; $i -lt 40; $i++) {
    if (Test-Path $logFile) { $found = $true; break }
    Start-Sleep -Milliseconds 50
  }
  if ($found) {
    $stableCount = 0
    $lastSize = -1
    for ($i = 0; $i -lt 20; $i++) {
      $size = (Get-Item $logFile).Length
      if ($size -eq $lastSize) { $stableCount++ } else { $stableCount = 0 }
      if ($stableCount -ge 2) { break }
      $lastSize = $size
      Start-Sleep -Milliseconds 50
    }
    Get-Content -Raw $logFile
    Remove-Item $logFile -ErrorAction SilentlyContinue
  }
  try {
    $exePath = (Resolve-Path $Target).Path
    Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -eq $exePath } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  } catch {}
  exit $LASTEXITCODE
}

$compileScript = Join-Path $PSScriptRoot "Compile.ahk"
if ($Target -match '\.ahk$' -and (Test-Path $compileScript)) {
  & $AhkExe /ErrorStdOut /CP65001 $compileScript $Target @Args 2>&1
} else {
  & $AhkExe /ErrorStdOut /CP65001 $Target @Args 2>&1
}
$found = $false
for ($i = 0; $i -lt 40; $i++) {
  if (Test-Path $logFile) { $found = $true; break }
  Start-Sleep -Milliseconds 50
}
if ($found) {
  $stableCount = 0
  $lastSize = -1
  for ($i = 0; $i -lt 20; $i++) {
    $size = (Get-Item $logFile).Length
    if ($size -eq $lastSize) { $stableCount++ } else { $stableCount = 0 }
    if ($stableCount -ge 2) { break }
    $lastSize = $size
    Start-Sleep -Milliseconds 50
  }
  Get-Content -Raw $logFile
  Remove-Item $logFile -ErrorAction SilentlyContinue
}
exit $LASTEXITCODE
