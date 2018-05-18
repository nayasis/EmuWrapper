EnvGet, userHome, userprofile

configFile := userHome "\Documents\WB Games\Batman Arkham City GOTY\BmGame\Config\UserEngine.ini"

IfExist, %configFile%
{
	IniWrite, 0, %configFile%, Engine.Engine, PhysXLevel
}

ExitApp