# Install Git for Windows

## You Need Git First!

Git is not installed on your computer. You need to install it before you can upload to GitHub.

## Option 1: Download Git (Recommended)

### Step 1: Download
Visit: https://git-scm.com/download/win

Or direct download: https://github.com/git-for-windows/git/releases/latest

### Step 2: Install
1. Run the downloaded installer
2. Use default settings (just keep clicking "Next")
3. Important: Make sure "Git from the command line and also from 3rd-party software" is selected
4. Finish installation

### Step 3: Verify
Open a new PowerShell window and type:
```bash
git --version
```

You should see something like: `git version 2.43.0.windows.1`

## Option 2: Use GitHub Desktop (Easier!)

If you don't want to use command line, use GitHub Desktop instead:

### Step 1: Download GitHub Desktop
Visit: https://desktop.github.com/

### Step 2: Install
1. Run the installer
2. Sign in with your GitHub account (or create one)
3. Done!

### Step 3: Upload Your Project
1. Open GitHub Desktop
2. File → Add Local Repository
3. Browse to: `C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main`
4. Click "Add Repository"
5. Click "Publish repository"
6. Choose repository name and visibility (Public/Private)
7. Click "Publish"

Done! Your code is now on GitHub!

## Option 3: Quick Install Script

Run this PowerShell command to download Git installer:

```powershell
# Download Git installer
$url = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
$output = "$env:TEMP\GitInstaller.exe"
Invoke-WebRequest -Uri $url -OutFile $output
Start-Process $output
```

## After Installing Git

Once Git is installed, come back and run:

```bash
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
git init
git add .
git commit -m "Initial commit: CFAS Exam System"
```

Then create a repository on GitHub and push:

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

## Which Option Should You Choose?

### Choose GitHub Desktop if:
- ✓ You want the easiest way
- ✓ You prefer visual interface
- ✓ You're not comfortable with command line

### Choose Git Command Line if:
- ✓ You want more control
- ✓ You're comfortable with terminal
- ✓ You want to learn Git commands

## Need Help?

Both options work perfectly! GitHub Desktop is recommended for beginners.

## Next Steps After Installation

1. Create a GitHub account (if you don't have one): https://github.com/signup
2. Install Git or GitHub Desktop
3. Upload your project
4. Share the repository link!
