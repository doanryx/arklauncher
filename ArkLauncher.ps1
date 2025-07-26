<#
ARK Ascended Launcher
Version: 2.0
GitHub: https://github.com/doanryx/arklauncher
#>

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Configuration
$ARK_EXE_PATH = ".\ShooterGame\Binaries\Win64\ArkAscended.exe"
$GITHUB_REPO = "https://github.com/doanryx/arklauncher"
$VERSION = "2.0"

# Kill existing ARK processes
function Close-ARKProcesses {
    $processes = Get-Process -Name "ArkAscended" -ErrorAction SilentlyContinue
    if ($processes) {
        try {
            $processes | Stop-Process -Force
            Start-Sleep -Seconds 1
            return $true
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "Failed to close ARK processes!`nPlease close manually and try again.",
                "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return $false
        }
    }
    return $true
}

# Check for updates
function Check-ForUpdates {
    try {
        $latestVersion = (Invoke-RestMethod "$GITHUB_REPO/raw/main/version.txt" -ErrorAction Stop).Trim()
        if ([version]$latestVersion -gt [version]$VERSION) {
            $updateResult = [System.Windows.Forms.MessageBox]::Show(
                "New version $latestVersion available!`nCurrent version: $VERSION`n`nOpen download page?",
                "Update Available",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            
            if ($updateResult -eq "Yes") {
                Start-Process "$GITHUB_REPO/releases/latest"
            }
        }
    } catch {
        Write-Host "Update check failed: $_" -ForegroundColor Yellow
    }
}

# Main UI Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "ARK Ascended Launcher v$VERSION"
$form.Size = New-Object System.Drawing.Size(450, 250)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

# UI Elements
$label = New-Object System.Windows.Forms.Label
$label.Text = "ARK Ascended Launcher"
$label.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($label)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "Version: $VERSION"
$versionLabel.Location = New-Object System.Drawing.Point(20, 50)
$versionLabel.AutoSize = $true
$form.Controls.Add($versionLabel)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready to launch"
$statusLabel.Location = New-Object System.Drawing.Point(20, 150)
$statusLabel.AutoSize = $true
$form.Controls.Add($statusLabel)

$button = New-Object System.Windows.Forms.Button
$button.Text = "Launch ARK Ascended"
$button.Size = New-Object System.Drawing.Size(150, 40)
$button.Location = New-Object System.Drawing.Point(150, 100)
$button.Add_Click({
    $button.Enabled = $false
    $statusLabel.Text = "Closing existing ARK processes..."
    $form.Refresh()

    if (Close-ARKProcesses) {
        $statusLabel.Text = "Launching ARK Ascended..."
        $form.Refresh()

        if (Test-Path $ARK_EXE_PATH) {
            try {
                Start-Process $ARK_EXE_PATH -ArgumentList "-noadmin" -WorkingDirectory (Split-Path $ARK_EXE_PATH)
                $form.Close()
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Failed to launch ARK:`n$_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
                $statusLabel.Text = "Launch failed"
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show(
                "ARK executable not found at:`n$ARK_EXE_PATH",
                "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            $statusLabel.Text = "Executable not found"
        }
    }
    $button.Enabled = $true
})
$form.Controls.Add($button)

# Check for updates on startup
Check-ForUpdates

# Show the form
$form.Add_Shown({$form.Actresh()})
[void]$form.ShowDialog()

# Self-cleanup if running from temp location
if ($MyInvocation.MyCommand.Path -like "$env:temp\*") {
    Remove-Item $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
}