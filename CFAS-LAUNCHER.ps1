# CFAS Exam System - Ultimate Launcher
# Clean, Simple, Professional

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Try to load CFAS logo
$logoPath = Join-Path $scriptDir "frontend\public\cfas-logo.jpg"
$logo = $null
if (Test-Path $logoPath) {
    try {
        $logo = [System.Drawing.Image]::FromFile($logoPath)
    } catch {
        $logo = $null
    }
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'CFAS Exam System'
$form.Size = New-Object System.Drawing.Size(600, 550)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

# Logo PictureBox
if ($logo) {
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Size = New-Object System.Drawing.Size(120, 120)
    $pictureBox.Location = New-Object System.Drawing.Point(240, 30)
    $pictureBox.SizeMode = 'Zoom'
    $pictureBox.Image = $logo
    $form.Controls.Add($pictureBox)
    $titleTop = 160
} else {
    # Fallback emoji logo
    $emojiLabel = New-Object System.Windows.Forms.Label
    $emojiLabel.Text = '🎓'
    $emojiLabel.Font = New-Object System.Drawing.Font('Segoe UI', 72)
    $emojiLabel.Size = New-Object System.Drawing.Size(120, 120)
    $emojiLabel.Location = New-Object System.Drawing.Point(240, 30)
    $emojiLabel.TextAlign = 'MiddleCenter'
    $form.Controls.Add($emojiLabel)
    $titleTop = 160
}

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = 'CFAS EXAM SYSTEM'
$title.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$title.Size = New-Object System.Drawing.Size(560, 40)
$title.Location = New-Object System.Drawing.Point(20, $titleTop)
$title.TextAlign = 'MiddleCenter'
$title.ForeColor = [System.Drawing.Color]::FromArgb(41, 128, 185)
$form.Controls.Add($title)

# Subtitle
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Review Center Management System'
$subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$subtitle.Size = New-Object System.Drawing.Size(560, 30)
$subtitle.Location = New-Object System.Drawing.Point(20, ($titleTop + 45))
$subtitle.TextAlign = 'MiddleCenter'
$subtitle.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($subtitle)

# Info Panel
$infoPanel = New-Object System.Windows.Forms.Panel
$infoPanel.Size = New-Object System.Drawing.Size(540, 140)
$infoPanel.Location = New-Object System.Drawing.Point(30, ($titleTop + 90))
$infoPanel.BackColor = [System.Drawing.Color]::FromArgb(236, 240, 241)
$infoPanel.BorderStyle = 'FixedSingle'
$form.Controls.Add($infoPanel)

# Info title
$infoTitle = New-Object System.Windows.Forms.Label
$infoTitle.Text = 'System will start:'
$infoTitle.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$infoTitle.Size = New-Object System.Drawing.Size(520, 25)
$infoTitle.Location = New-Object System.Drawing.Point(10, 10)
$infoPanel.Controls.Add($infoTitle)

# Service 1
$service1 = New-Object System.Windows.Forms.Label
$service1.Text = '✓ Apache Web Server (Frontend)'
$service1.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$service1.Size = New-Object System.Drawing.Size(520, 25)
$service1.Location = New-Object System.Drawing.Point(20, 40)
$service1.ForeColor = [System.Drawing.Color]::FromArgb(39, 174, 96)
$infoPanel.Controls.Add($service1)

# Service 2
$service2 = New-Object System.Windows.Forms.Label
$service2.Text = '✓ MySQL Database Server'
$service2.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$service2.Size = New-Object System.Drawing.Size(520, 25)
$service2.Location = New-Object System.Drawing.Point(20, 65)
$service2.ForeColor = [System.Drawing.Color]::FromArgb(39, 174, 96)
$infoPanel.Controls.Add($service2)

# Service 3
$service3 = New-Object System.Windows.Forms.Label
$service3.Text = '✓ Laravel Backend API Server'
$service3.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$service3.Size = New-Object System.Drawing.Size(520, 25)
$service3.Location = New-Object System.Drawing.Point(20, 90)
$service3.ForeColor = [System.Drawing.Color]::FromArgb(39, 174, 96)
$infoPanel.Controls.Add($service3)

# URL Label
$urlLabel = New-Object System.Windows.Forms.Label
$urlLabel.Text = 'Access URL: http://192.168.11.40/exam-frontend'
$urlLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$urlLabel.Size = New-Object System.Drawing.Size(560, 30)
$urlLabel.Location = New-Object System.Drawing.Point(20, ($titleTop + 245))
$urlLabel.TextAlign = 'MiddleCenter'
$urlLabel.ForeColor = [System.Drawing.Color]::FromArgb(41, 128, 185)
$form.Controls.Add($urlLabel)

# Progress Panel (hidden initially)
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Size = New-Object System.Drawing.Size(540, 100)
$progressPanel.Location = New-Object System.Drawing.Point(30, ($titleTop + 90))
$progressPanel.BackColor = [System.Drawing.Color]::FromArgb(236, 240, 241)
$progressPanel.BorderStyle = 'FixedSingle'
$progressPanel.Visible = $false
$form.Controls.Add($progressPanel)

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Text = '⏳ Starting services...'
$progressLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$progressLabel.Size = New-Object System.Drawing.Size(520, 30)
$progressLabel.Location = New-Object System.Drawing.Point(10, 20)
$progressLabel.TextAlign = 'MiddleCenter'
$progressLabel.ForeColor = [System.Drawing.Color]::FromArgb(41, 128, 185)
$progressPanel.Controls.Add($progressLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(500, 30)
$progressBar.Location = New-Object System.Drawing.Point(20, 55)
$progressBar.Style = 'Marquee'
$progressBar.MarqueeAnimationSpeed = 30
$progressPanel.Controls.Add($progressBar)

# Buttons Panel
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Size = New-Object System.Drawing.Size(560, 60)
$buttonPanel.Location = New-Object System.Drawing.Point(20, ($titleTop + 290))
$buttonPanel.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($buttonPanel)

# Start Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = '🚀 START SYSTEM'
$startButton.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$startButton.Size = New-Object System.Drawing.Size(260, 50)
$startButton.Location = New-Object System.Drawing.Point(280, 5)
$startButton.BackColor = [System.Drawing.Color]::FromArgb(39, 174, 96)
$startButton.ForeColor = [System.Drawing.Color]::White
$startButton.FlatStyle = 'Flat'
$startButton.FlatAppearance.BorderSize = 0
$startButton.Cursor = 'Hand'
$buttonPanel.Controls.Add($startButton)

# Cancel Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = 'CANCEL'
$cancelButton.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$cancelButton.Size = New-Object System.Drawing.Size(260, 50)
$cancelButton.Location = New-Object System.Drawing.Point(10, 5)
$cancelButton.BackColor = [System.Drawing.Color]::FromArgb(189, 195, 199)
$cancelButton.ForeColor = [System.Drawing.Color]::FromArgb(44, 62, 80)
$cancelButton.FlatStyle = 'Flat'
$cancelButton.FlatAppearance.BorderSize = 0
$cancelButton.Cursor = 'Hand'
$buttonPanel.Controls.Add($cancelButton)

# Cancel button click
$cancelButton.Add_Click({
    $form.Close()
})

# Start button click
$startButton.Add_Click({
    # Hide info and buttons
    $infoPanel.Visible = $false
    $urlLabel.Visible = $false
    $buttonPanel.Visible = $false
    
    # Show progress
    $progressPanel.Visible = $true
    
    # Start services
    $batFile = Join-Path $scriptDir "START-EXAM-SYSTEM.bat"
    Start-Process -FilePath $batFile -WindowStyle Hidden
    
    # Wait 10 seconds
    for ($i = 1; $i -le 10; $i++) {
        $progressLabel.Text = "⏳ Starting services... ($i/10)"
        Start-Sleep -Seconds 1
    }
    
    # Update progress
    $progressLabel.Text = '✓ System started! Opening browser...'
    $progressBar.Style = 'Continuous'
    $progressBar.Value = 100
    
    # Open browser
    Start-Process "http://192.168.11.40/exam-frontend/"
    
    # Wait 2 seconds
    Start-Sleep -Seconds 2
    
    # Close form
    $form.Close()
})

# Show form
[void]$form.ShowDialog()

# Cleanup
if ($logo) {
    $logo.Dispose()
}
