# Desktop Shortcut Guide 🖱️

## Paano Gumawa ng Desktop Shortcut

### Quick Method (Automatic)
1. Double-click: `CREATE-DESKTOP-SHORTCUT.bat`
2. Shortcut will appear on your Desktop
3. Done! ✅

### What You Get
A desktop shortcut named: **"Start CFAS Exam System"**

### How to Use the Shortcut

#### Starting the System
1. **Double-click** the shortcut on Desktop
2. A notification will appear: "CFAS Exam System is starting..."
3. Wait 10 seconds for all services to start
4. System runs silently in background (no command windows)
5. Access: http://192.168.11.40/exam-frontend

#### What Starts Automatically
- ✅ Apache (Frontend)
- ✅ MySQL (Database)
- ✅ Laravel Backend Server (Port 8000)

### Stopping the System
Use: `STOP-EXAM-SYSTEM.bat` (or create a stop shortcut too)

---

## Manual Shortcut Creation

If automatic method doesn't work:

1. **Right-click** on Desktop → New → Shortcut
2. **Browse** to: `Exam-Main\START-EXAM-SYSTEM-SILENT.vbs`
3. **Name it**: "Start CFAS Exam System"
4. **Click** Finish
5. **Right-click** shortcut → Properties
6. **Change Icon** (optional): Browse to `C:\Windows\System32\shell32.dll` and pick icon #21

---

## Files Created

### Silent Startup Files
- `START-EXAM-SYSTEM-SILENT.vbs` - Starts system without showing command windows
- `STOP-EXAM-SYSTEM-SILENT.vbs` - Stops system silently
- `CREATE-DESKTOP-SHORTCUT.bat` - Creates desktop shortcut automatically

### Original Files (Still Available)
- `START-EXAM-SYSTEM.bat` - Original startup with visible windows
- `STOP-EXAM-SYSTEM.bat` - Original stop script

---

## Benefits of Silent Startup

✅ **No Command Windows** - Clean desktop, no clutter
✅ **Professional Look** - Just like a real application
✅ **Easy to Use** - One click to start everything
✅ **Notification** - Shows popup when starting
✅ **Background Running** - Services run invisibly

---

## Troubleshooting

### Shortcut Not Working?
1. Make sure you're in the `Exam-Main` folder
2. Run `CREATE-DESKTOP-SHORTCUT.bat` as Administrator
3. Check if `START-EXAM-SYSTEM-SILENT.vbs` exists

### Services Not Starting?
1. Open Task Manager (Ctrl+Shift+Esc)
2. Check if `httpd.exe`, `mysqld.exe`, and `php.exe` are running
3. If not, run `START-EXAM-SYSTEM.bat` (with visible window) to see errors

### Need to See What's Happening?
Use the original `START-EXAM-SYSTEM.bat` to see all startup messages

---

## Advanced: Create Stop Shortcut Too

Want a stop shortcut on Desktop?

1. Right-click Desktop → New → Shortcut
2. Browse to: `Exam-Main\STOP-EXAM-SYSTEM-SILENT.vbs`
3. Name it: "Stop CFAS Exam System"
4. Done!

---

## Summary

**To Create Shortcut:**
```
Double-click: CREATE-DESKTOP-SHORTCUT.bat
```

**To Start System:**
```
Double-click: Desktop shortcut "Start CFAS Exam System"
```

**To Stop System:**
```
Run: STOP-EXAM-SYSTEM.bat
```

Simple lang! 🎉
