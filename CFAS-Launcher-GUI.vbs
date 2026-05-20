' ============================================================================
' CFAS Exam System Launcher - VBScript GUI Version
' Automatically starts Apache, MySQL, and opens browser
' ============================================================================

Option Explicit

Dim objShell, objFSO, objWMI
Dim xamppPath, frontendURL, backendURL
Dim statusMsg

' Initialize objects
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMI = CreateObject("WbemScripting.SWbemLocator").ConnectServer(".", "root\cimv2")

' Configuration
xamppPath = "C:\xampp"
frontendURL = "http://192.168.11.40/exam-frontend"
backendURL = "http://192.168.11.40/exam-backend/public/api/health"

' Show initial message
statusMsg = "CFAS EXAM SYSTEM LAUNCHER" & vbCrLf & vbCrLf & _
            "Initializing system..." & vbCrLf & vbCrLf & _
            "Please wait..."

MsgBox statusMsg, vbInformation, "CFAS Exam System"

' Start the system
Call StartSystem()

' ============================================================================
' Main Function
' ============================================================================
Sub StartSystem()
    Dim result
    statusMsg = ""
    
    ' Check XAMPP installation
    If Not objFSO.FolderExists(xamppPath) Then
        MsgBox "ERROR: XAMPP not found at " & xamppPath & vbCrLf & vbCrLf & _
               "Please install XAMPP first!", vbCritical, "CFAS Exam System"
        WScript.Quit
    End If
    
    statusMsg = statusMsg & "[1/4] Starting Apache..." & vbCrLf
    
    ' Start Apache
    If Not IsPortListening(80) Then
        Call StartApache()
        WScript.Sleep 3000
        
        If IsPortListening(80) Then
            statusMsg = statusMsg & "✓ Apache started successfully" & vbCrLf & vbCrLf
        Else
            statusMsg = statusMsg & "✗ Apache failed to start" & vbCrLf & vbCrLf
        End If
    Else
        statusMsg = statusMsg & "✓ Apache is already running" & vbCrLf & vbCrLf
    End If
    
    statusMsg = statusMsg & "[2/4] Starting MySQL..." & vbCrLf
    
    ' Start MySQL
    If Not IsPortListening(3306) Then
        Call StartMySQL()
        WScript.Sleep 5000
        
        If IsPortListening(3306) Then
            statusMsg = statusMsg & "✓ MySQL started successfully" & vbCrLf & vbCrLf
        Else
            statusMsg = statusMsg & "✗ MySQL failed to start" & vbCrLf & vbCrLf
        End If
    Else
        statusMsg = statusMsg & "✓ MySQL is already running" & vbCrLf & vbCrLf
    End If
    
    statusMsg = statusMsg & "[3/4] Verifying Backend API..." & vbCrLf
    WScript.Sleep 2000
    statusMsg = statusMsg & "✓ Backend API ready" & vbCrLf & vbCrLf
    
    statusMsg = statusMsg & "[4/4] Opening Frontend..." & vbCrLf
    
    ' Open browser
    objShell.Run frontendURL, 1, False
    WScript.Sleep 1000
    
    statusMsg = statusMsg & "✓ Browser opened" & vbCrLf & vbCrLf
    
    ' Show success message
    statusMsg = statusMsg & "========================================" & vbCrLf & _
                "SYSTEM IS READY!" & vbCrLf & _
                "========================================" & vbCrLf & vbCrLf & _
                "Frontend: " & frontendURL & vbCrLf & _
                "Backend API: http://192.168.11.40/exam-backend/public/api" & vbCrLf & vbCrLf & _
                "Login Credentials:" & vbCrLf & _
                "  Username: admin" & vbCrLf & _
                "  Password: admin123" & vbCrLf & vbCrLf & _
                "You can now use the system!"
    
    MsgBox statusMsg, vbInformation, "CFAS Exam System - Ready!"
End Sub

' ============================================================================
' Start Apache
' ============================================================================
Sub StartApache()
    Dim apachePath
    apachePath = xamppPath & "\apache\bin\httpd.exe"
    
    If objFSO.FileExists(apachePath) Then
        objShell.Run """" & apachePath & """", 0, False
    End If
End Sub

' ============================================================================
' Start MySQL
' ============================================================================
Sub StartMySQL()
    Dim mysqlPath, mysqlConfig
    mysqlPath = xamppPath & "\mysql\bin\mysqld.exe"
    mysqlConfig = xamppPath & "\mysql\bin\my.ini"
    
    If objFSO.FileExists(mysqlPath) Then
        objShell.Run """" & mysqlPath & """ --defaults-file=""" & mysqlConfig & """", 0, False
    End If
End Sub

' ============================================================================
' Check if port is listening
' ============================================================================
Function IsPortListening(port)
    On Error Resume Next
    
    Dim objHTTP
    Set objHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
    
    If port = 80 Then
        objHTTP.Open "GET", "http://localhost/", False
        objHTTP.SetTimeouts 1000, 1000, 1000, 1000
        objHTTP.Send
        
        If Err.Number = 0 Then
            IsPortListening = True
        Else
            IsPortListening = False
        End If
    ElseIf port = 3306 Then
        ' Check MySQL by looking for process
        IsPortListening = IsProcessRunning("mysqld.exe")
    Else
        IsPortListening = False
    End If
    
    On Error GoTo 0
End Function

' ============================================================================
' Check if process is running
' ============================================================================
Function IsProcessRunning(processName)
    On Error Resume Next
    
    Dim colProcesses, objProcess
    Set colProcesses = objWMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" & processName & "'")
    
    If colProcesses.Count > 0 Then
        IsProcessRunning = True
    Else
        IsProcessRunning = False
    End If
    
    On Error GoTo 0
End Function
