# ============================================================================
# CFAS Exam System Launcher - Final Version with GUI
# Automatically starts Apache, MySQL, and opens browser
# ============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "CFAS Exam System Launcher"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(460, 40)
$titleLabel.Text = "CFAS EXAM SYSTEM"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 102, 204)
$titleLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($titleLabel)

# Subtitle Label
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Location = New-Object System.Drawing.Point(20, 60)
$subtitleLabel.Size = New-Object System.Drawing.Size(460, 25)
$subtitleLabel.Text = "Review Center Examination System"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$subtitleLabel.ForeColor = [System.Drawing.Color]::Gray
$subtitleLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($subtitleLabel)

# Status TextBox
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Location = New-Object System.Drawing.Point(20, 100)
$statusBox.Size = New-Object System.Drawing.Size(460, 180)
$statusBox.Multiline = $true
$statusBox.ScrollBars = "Vertical"
$statusBox.ReadOnly = $true
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$form.Controls.Add($statusBox)

# Start Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Location = New-Object System.Drawing.Point(150, 300)
$startButton.Size = New-Object System.Drawing.Size(200, 40)
$startButton.Text = "START SYSTEM"
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$startButton.BackColor = [System.Drawing.Color]::FromArgb(0, 153, 76)
$startButton.ForeColor = [System.Drawing.Color]::White
$startButton.FlatStyle = "Flat"
$startButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($startButton)

# Function to add status message
function Add-Status {
    param([string]$message)
    $statusBox.AppendText("$message`r`n")
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.ScrollToCaret()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

# Function to check if a process is running
function Test-ProcessRunning {
    param([string]$processName)
    return (Get-Process -Name $processName -ErrorAction SilentlyContinue) -ne $null
}

# Function to check if port is listening
function Test-PortListening {
    param([int]$port)
    $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    return $connections -ne $null
}

# Function to start XAMPP services
function Start-XAMPPServices {
    Add-Status "========================================="
    Add-Status "Starting CFAS Exam System..."
    Add-Status "========================================="
    Add-Status ""
    
    # Check if XAMPP is installed
    $xamppPath = "C:\xampp"
    if (-not (Test-Path $xamppPath)) {
        Add-Status "ERROR: XAMPP not found at $xamppPath"
        Add-Status "Please install XAMPP first!"
        [System.Windows.Forms.MessageBox]::Show("XAMPP not found! Please install XAMPP first.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
    
    Add-Status "[1/4] Checking Apache..."
    
    # Check if Apache is already running
    if (Test-PortListening -port 80) {
        Add-Status "✓ Apache is already running"
    } else {
        Add-Status "Starting Apache..."
        Start-Process -FilePath "$xamppPath\apache\bin\httpd.exe" -WindowStyle Hidden
        Start-Sleep -Seconds 3
        
        if (Test-PortListening -port 80) {
            Add-Status "✓ Apache started successfully"
        } else {
            Add-Status "✗ Failed to start Apache"
            Add-Status "Please start Apache manually from XAMPP Control Panel"
            [System.Windows.Forms.MessageBox]::Show("Failed to start Apache. Please start it manually from XAMPP Control Panel.", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    }
    
    Add-Status ""
    Add-Status "[2/4] Checking MySQL..."
    
    # Check if MySQL is already running
    if (Test-PortListening -port 3306) {
        Add-Status "✓ MySQL is already running"
    } else {
        Add-Status "Starting MySQL..."
        Start-Process -FilePath "$xamppPath\mysql\bin\mysqld.exe" -ArgumentList "--defaults-file=$xamppPath\mysql\bin\my.ini" -WindowStyle Hidden
        Start-Sleep -Seconds 5
        
        if (Test-PortListening -port 3306) {
            Add-Status "✓ MySQL started successfully"
        } else {
            Add-Status "✗ Failed to start MySQL"
            Add-Status "Please start MySQL manually from XAMPP Control Panel"
            [System.Windows.Forms.MessageBox]::Show("Failed to start MySQL. Please start it manually from XAMPP Control Panel.", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    }
    
    Add-Status ""
    Add-Status "[3/4] Verifying Backend API..."
    
    try {
        $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/public/api/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Add-Status "✓ Backend API is responding"
        } else {
            Add-Status "⚠ Backend API returned status: $($response.StatusCode)"
        }
    } catch {
        Add-Status "⚠ Backend API check failed (this is normal if Apache just started)"
    }
    
    Add-Status ""
    Add-Status "[4/4] Opening Frontend..."
    Start-Sleep -Seconds 2
    
    # Open browser
    Start-Process "http://192.168.11.40/exam-frontend"
    Add-Status "✓ Browser opened"
    
    Add-Status ""
    Add-Status "========================================="
    Add-Status "SYSTEM IS READY!"
    Add-Status "========================================="
    Add-Status ""
    Add-Status "Frontend: http://192.168.11.40/exam-frontend"
    Add-Status "Backend API: http://192.168.11.40/exam-backend/public/api"
    Add-Status ""
    Add-Status "Login Credentials:"
    Add-Status "  Username: admin"
    Add-Status "  Password: admin123"
    Add-Status ""
    Add-Status "You can close this window now."
    
    return $true
}

# Start button click event
$startButton.Add_Click({
    $startButton.Enabled = $false
    $startButton.Text = "STARTING..."
    $startButton.BackColor = [System.Drawing.Color]::Gray
    
    $result = Start-XAMPPServices
    
    if ($result) {
        $startButton.Text = "SYSTEM STARTED"
        $startButton.BackColor = [System.Drawing.Color]::FromArgb(0, 153, 76)
        
        # Auto-close after 10 seconds
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 10000
        $timer.Add_Tick({
            $form.Close()
        })
        $timer.Start()
    } else {
        $startButton.Text = "START SYSTEM"
        $startButton.BackColor = [System.Drawing.Color]::FromArgb(0, 153, 76)
        $startButton.Enabled = $true
    }
})

# Initial status message
Add-Status "Welcome to CFAS Exam System!"
Add-Status ""
Add-Status "Click 'START SYSTEM' to begin."
Add-Status ""
Add-Status "This will:"
Add-Status "  1. Start Apache web server"
Add-Status "  2. Start MySQL database"
Add-Status "  3. Verify backend API"
Add-Status "  4. Open the system in your browser"
Add-Status ""

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
