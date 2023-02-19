scriptdir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

InstallFont("NOTO220MD_ORG.ttf" )

WScript.Quit

Function InstallFont( FontPath )

      Dim WshShell

      Set WshShell = WScript.CreateObject("WScript.Shell")

      Const FONTS = &H14&

      Set objShell = CreateObject("Shell.Application")

      Set objFolder = objShell.Namespace(FONTS)

      objFolder.CopyHere  scriptdir & "\" & FontPath

End Function