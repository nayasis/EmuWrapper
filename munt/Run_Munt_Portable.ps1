param(
    [ValidateSet('MT-32', 'CM-32L')]
    [string]$DefaultProfile = 'MT-32'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$romDir = Join-Path $root 'rom'
$exePath = Join-Path $root 'mt32emu-qt.exe'
$baseKey = 'HKCU:\Software\muntemu.org\Munt mt32emu-qt'

$profiles = @{
    'MT-32' = @{
        controlROM = 'MT32_CONTROL.1987-10-07.v1.07.ROM'
        pcmROM     = 'MT32_PCM.ROM'
    }
    'CM-32L' = @{
        controlROM = 'CM32L_CONTROL.1989-12-05.v1.02.ROM'
        pcmROM     = 'CM32L_PCM.ROM'
    }
}

if (-not (Test-Path -LiteralPath $exePath)) {
    throw "Missing executable: $exePath"
}

if (-not (Test-Path -LiteralPath $romDir)) {
    throw "Missing ROM directory: $romDir"
}

foreach ($profileName in $profiles.Keys) {
    $profile = $profiles[$profileName]
    $controlPath = Join-Path $romDir $profile.controlROM
    $pcmPath = Join-Path $romDir $profile.pcmROM

    if (-not (Test-Path -LiteralPath $controlPath)) {
        throw "Missing control ROM for ${profileName}: $controlPath"
    }
    if (-not (Test-Path -LiteralPath $pcmPath)) {
        throw "Missing PCM ROM for ${profileName}: $pcmPath"
    }

    $profileKey = Join-Path $baseKey "Profiles\$profileName"
    New-Item -Path $profileKey -Force | Out-Null
    New-ItemProperty -Path $profileKey -Name 'romDir' -Value $romDir -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $profileKey -Name 'controlROM' -Value $profile.controlROM -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $profileKey -Name 'controlROM2' -Value '' -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $profileKey -Name 'pcmROM' -Value $profile.pcmROM -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $profileKey -Name 'pcmROM2' -Value '' -PropertyType String -Force | Out-Null
}

$masterKey = Join-Path $baseKey 'Master'
New-Item -Path $masterKey -Force | Out-Null
New-ItemProperty -Path $masterKey -Name 'defaultSynthProfile' -Value $DefaultProfile -PropertyType String -Force | Out-Null

Write-Host "Configured Munt profiles. Default profile: $DefaultProfile"
Start-Process -FilePath $exePath -WorkingDirectory $root
