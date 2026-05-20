Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strBackendPath = strScriptPath & "\backend"

' Change to backend directory and start PHP server hidden
strCommand = "cmd /c cd /d """ & strBackendPath & """ && php artisan serve --host=127.0.0.1 --port=8000"

' Run hidden (0 = hidden window)
WshShell.Run strCommand, 0, False

' Exit script
WScript.Quit
