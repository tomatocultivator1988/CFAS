@echo off
title Create CFAS Desktop Shortcut
color 0A

echo ========================================
echo Creating CFAS Desktop Shortcut
echo ========================================
echo.

cd /d "%~dp0"

powershell -ExecutionPolicy Bypass -NoExit -Command "& { Write-Host 'Creating desktop shortcut...' -ForegroundColor Cyan; Write-Host ''; $examMainPath = '%~dp0'; $desktopPath = [Environment]::GetFolderPath('Desktop'); $shortcutName = 'CFAS Exam System.lnk'; $shortcutPath = Join-Path $desktopPath $shortcutName; $launcherScript = Join-Path $examMainPath 'CFAS-System-Launcher.ps1'; if (-not (Test-Path $launcherScript)) { Write-Host 'ERROR: Launcher script not found!' -ForegroundColor Red; Write-Host $launcherScript -ForegroundColor Yellow; Write-Host ''; Write-Host 'Press Enter to exit...' -ForegroundColor Gray; Read-Host; exit 1 }; try { $WScriptShell = New-Object -ComObject WScript.Shell; $shortcut = $WScriptShell.CreateShortcut($shortcutPath); $shortcut.TargetPath = 'powershell.exe'; $shortcut.Arguments = '-ExecutionPolicy Bypass -NoProfile -NoExit -Command \"& { & ''$launcherScript''; Write-Host ''''; Write-Host ''Launcher finished. You can close this window.'' -ForegroundColor Green; Read-Host ''Press Enter to exit'' }\"'; $shortcut.WorkingDirectory = $examMainPath; $shortcut.Description = 'Launch CFAS Exam System with all services'; $shortcut.IconLocation = 'powershell.exe,0'; $shortcut.Save(); Write-Host ''; Write-Host '========================================' -ForegroundColor Green; Write-Host 'SUCCESS!' -ForegroundColor Green; Write-Host '========================================' -ForegroundColor Green; Write-Host ''; Write-Host 'Desktop shortcut created successfully!' -ForegroundColor Green; Write-Host ''; Write-Host 'Shortcut Location: ' -NoNewline; Write-Host $shortcutPath -ForegroundColor Cyan; Write-Host 'Launcher Script: ' -NoNewline; Write-Host $launcherScript -ForegroundColor Cyan; Write-Host ''; Write-Host 'You can now double-click the CFAS Exam System icon on your desktop' -ForegroundColor Green; Write-Host 'to launch the exam system!' -ForegroundColor Green; Write-Host ''; } catch { Write-Host ''; Write-Host 'ERROR: Failed to create desktop shortcut' -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Yellow; Write-Host ''; }; Write-Host 'Press Enter to exit...' -ForegroundColor Gray; Read-Host }"

echo.
echo Done!
pause
