' ============================================================================
' CFAS Desktop Shortcut Creator (VBS)
' Simple VBS script to create desktop shortcut without PowerShell issues
' ============================================================================

Option Explicit

Dim objShell, objFSO, strScriptPath, strExamMainPath
Dim strDesktopPath, strShortcutPath, objShortcut
Dim strLauncherScript, strMessage

' Create objects
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get paths
strScriptPath = WScript.ScriptFullName
strExamMainPath = objFSO.GetParentFolderName(strScriptPath)
strDesktopPath = objShell.SpecialFolders("Desktop")
strShortcutPath = strDesktopPath & "\CFAS Exam System.lnk"
strLauncherScript = strExamMainPath & "\CFAS-System-Launcher.ps1"

' Check if launcher exists
If Not objFSO.FileExists(strLauncherScript) Then
    MsgBox "ERROR: Launcher script not found!" & vbCrLf & vbCrLf & _
           strLauncherScript, vbCritical, "CFAS Shortcut Creator"
    WScript.Quit 1
End If

' Create shortcut
On Error Resume Next
Set objShortcut = objShell.CreateShortcut(strShortcutPath)
objShortcut.TargetPath = "powershell.exe"
objShortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoExit -File """ & strLauncherScript & """"
objShortcut.WorkingDirectory = strExamMainPath
objShortcut.Description = "Launch CFAS Exam System"

' Try to use the CFAS logo as icon (if it exists)
Dim strLogoPath
strLogoPath = strExamMainPath & "\frontend\public\cfas-logo.jpg"
If objFSO.FileExists(strLogoPath) Then
    objShortcut.IconLocation = strLogoPath & ",0"
Else
    ' Fallback to PowerShell icon
    objShortcut.IconLocation = "powershell.exe,0"
End If

objShortcut.Save

If Err.Number <> 0 Then
    MsgBox "ERROR: Failed to create desktop shortcut!" & vbCrLf & vbCrLf & _
           "Error: " & Err.Description, vbCritical, "CFAS Shortcut Creator"
    WScript.Quit 1
End If
On Error GoTo 0

' Success message
strMessage = "SUCCESS!" & vbCrLf & vbCrLf & _
             "Desktop shortcut created successfully!" & vbCrLf & vbCrLf & _
             "Shortcut: " & strShortcutPath & vbCrLf & vbCrLf & _
             "You can now double-click the 'CFAS Exam System' icon" & vbCrLf & _
             "on your desktop to launch the exam system!"

MsgBox strMessage, vbInformation, "CFAS Shortcut Creator"

' Cleanup
Set objShortcut = Nothing
Set objFSO = Nothing
Set objShell = Nothing

WScript.Quit 0
