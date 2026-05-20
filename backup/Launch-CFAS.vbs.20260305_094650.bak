Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Path to the PowerShell launcher
strLauncher = strScriptPath & "\CFAS-System-Launcher.ps1"

' Check if launcher exists
If objFSO.FileExists(strLauncher) Then
    ' Run PowerShell with the launcher script
    ' WindowStyle 1 = Normal window (visible, doesn't auto-close)
    ' Wait = False (don't wait for completion)
    strCommand = "powershell.exe -ExecutionPolicy Bypass -NoProfile -NoExit -File """ & strLauncher & """"
    objShell.Run strCommand, 1, False
Else
    MsgBox "CFAS Launcher not found!" & vbCrLf & vbCrLf & strLauncher, vbCritical, "Error"
End If
