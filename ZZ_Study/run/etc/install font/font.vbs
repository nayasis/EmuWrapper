scriptdir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

InstallFont("NOTO220BD_BGI.ttf" )

WScript.Quit

Function InstallFont( FontPath )

      Dim WshShell

      Set WshShell = WScript.CreateObject("WScript.Shell")

      Const FONTS = &H14&

      Set objShell = CreateObject("Shell.Application")

      Set objFolder = objShell.Namespace(FONTS)

      objFolder.CopyHere  scriptdir & "\" & FontPath

End Function