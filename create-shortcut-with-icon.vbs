' ============================================================================
' CFAS Desktop Shortcut Creator with ICO Icon
' Creates desktop shortcut with proper CFAS icon
' ============================================================================

Option Explicit

Dim objShell, objFSO, strScriptPath, strExamMainPath
Dim strDesktopPath, strShortcutPath, objShortcut
Dim strLauncherScript, strIconPath, strMessage

' Create objects
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get paths
strScriptPath = WScript.ScriptFullName
strExamMainPath = objFSO.GetParentFolderName(strScriptPath)
strDesktopPath = objShell.SpecialFolders("Desktop")
strShortcutPath = strDesktopPath & "\CFAS Exam System.lnk"
strLauncherScript = strExamMainPath & "\CFAS-System-Launcher.ps1"
strIconPath = strExamMainPath & "\cfas-icon.ico"

' Check if launcher exists
If Not objFSO.FileExists(strLauncherScript) Then
    MsgBox "ERROR: Launcher script not found!" & vbCrLf & vbCrLf & _
           strLauncherScript, vbCritical, "CFAS Shortcut Creator"
    WScript.Quit 1
End If

' Check if icon exists
If Not objFSO.FileExists(strIconPath) Then
    MsgBox "ERROR: Icon file not found!" & vbCrLf & vbCrLf & _
           "Please run: CONVERT-LOGO-TO-ICO.bat first!" & vbCrLf & vbCrLf & _
           "Expected: " & strIconPath, vbCritical, "CFAS Shortcut Creator"
    WScript.Quit 1
End If

' Create shortcut
On Error Resume Next
Set objShortcut = objShell.CreateShortcut(strShortcutPath)
objShortcut.TargetPath = "powershell.exe"
objShortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoExit -File """ & strLauncherScript & """"
objShortcut.WorkingDirectory = strExamMainPath
objShortcut.Description = "Launch CFAS Exam System"
objShortcut.IconLocation = strIconPath & ",0"
objShortcut.Save

If Err.Number <> 0 Then
    MsgBox "ERROR: Failed to create desktop shortcut!" & vbCrLf & vbCrLf & _
           "Error: " & Err.Description, vbCritical, "CFAS Shortcut Creator"
    WScript.Quit 1
End If
On Error GoTo 0

' Success message
strMessage = "SUCCESS!" & vbCrLf & vbCrLf & _
             "Desktop shortcut created with CFAS icon!" & vbCrLf & vbCrLf & _
             "Shortcut: " & strShortcutPath & vbCrLf & _
             "Icon: " & strIconPath & vbCrLf & vbCrLf & _
             "You can now double-click the 'CFAS Exam System' icon" & vbCrLf & _
             "on your desktop to launch the exam system!"

MsgBox strMessage, vbInformation, "CFAS Shortcut Creator"

' Cleanup
Set objShortcut = Nothing
Set objFSO = Nothing
Set objShell = Nothing

WScript.Quit 0

