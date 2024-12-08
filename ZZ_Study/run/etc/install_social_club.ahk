#NoEnv
#Include, c:\app\emulator\ZZ_Library\Common.ahk
#Include, c:\app\emulator\ZZ_Library\FileUtil.ahk

installSocialClub()

ExitApp

installSocialClub() {

	RegRead, installPath, HKEY_LOCAL_MACHINE\SOFTWARE\Rockstar Games\Rockstar Games Social Club, InstallFolder
	if ( installPath == "" ) {
		RegRead, installPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Rockstar Games\Rockstar Games Social Club, InstallFolder
	}

	if ( FileUtil.exist( installPath "\libcef.dll" ) ) {
		debug("social club already installed at " installPath)
		return
	}

	Environment.restartAsAdmin()

	installer := FileUtil.getDir(A_LineFile) "\Social-Club-Setup.exe"
	if(! FileUtil.exist(installer)) {
		installer := FileUtil.getDir(A_LineFile) "\script\Social-Club-Setup.exe"
	}
	if(! FileUtil.exist(installer)) {
		MsgBox, % "There is no social club installer at " installer
	}
	
	Run, % installer
	WinWait, ahk_exe Social-Club-Setup.exe,,60
	IfWinNotExist
	{
		MsgBox, % "Fail to install Social Club."
		ExitApp
	}

	activateInstaller()

	BlockInput On

	SetKeyDelay, 50
	Send {Enter}
	Send {Tab}
	Send {Space}
	Send {Tab}{Tab}
	Send {Enter}

	Sleep, 5000
	while WinExist("ahk_exe Social-Club-Setup.exe")
	{
		activateInstaller()
		Send {Enter}
		Sleep, 500
	}

	BlockInput Off

	blockSocialClubNetwork()

}

activateInstaller() {
	WinActivate, ahk_exe Social-Club-Setup.exe	
}

blockSocialClubNetwork() {
	Network.block("block_social_club_1", "c:\Program Files (x86)\Rockstar Games\Social Club\subprocess.exe")
	Network.block("block_social_club_2", "c:\Program Files\Rockstar Games\Social Club\subprocess.exe")
}