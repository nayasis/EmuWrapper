#NoEnv
#include c:\app\emulator\ZZ_Library\Include.ahk

emulatorPid := ""
imageDir := %0%
;imageDir := "\\NAS2\emul\image\Model3\Daytona 2"
;imageDir := "\\NAS2\emul\image\Model3\dayto2pe"
imageDir := "\\NAS2\emul\image\Model3\Scud"

romPath := getExecutableRom( imageDir )
debug("romPath : " romPath)

if ( romPath != "" ) {
	cmd := "Supermodel.exe " wrap(romPath) " -res=1920,1080 -fullscreen"
	debug( cmd )
	RunWait, % cmd,,,emulatorPid
} else {
	Run, % "Supermodel.exe",,,emulatorPid
}

ExitApp


getExecutableRom(imageDir) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		jsonObj := JSON.load( jsonText )
		romName := FileUtil.getFile(imageDir, jsonObj.run.rom ".*")
	}
	if(romName != "")
		return romName
	else
		return FileUtil.getFile(imageDir, ".*\.(zip|7z)$")
}