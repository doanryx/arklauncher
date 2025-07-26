# ARK Ascended Launcher - GitHub Hosted Version
# Updated: $(Get-Date -Format "yyyy-MM-dd")

function Show-Launcher {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Kill ARK if running
    try {
        $arkProcesses = Get-Process -Name "ArkAscended" -ErrorAction SilentlyContinue
        if ($arkProcesses) {
            $arkProcesses | Stop-Process -Force
            Start-Sleep -Milliseconds 500
        }
    } catch {}

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "ARK Ascended Launcher (Cloud)"
    $form.Size = New-Object System.Drawing.Size(420,220)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true

    # Version label
    $versionLabel = New-Object System.Windows.Forms.Label
    $versionLabel.Text = "v1.0 | GitHub Hosted"
    $versionLabel.Location = New-Object System.Drawing.Point(20,20)
    $versionLabel.AutoSize = $true
    $form.Controls.Add($versionLabel)

    # Main label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "ARK Ascended Launcher"
    $label.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(20,50)
    $form.Controls.Add($label)

    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Launch ARK"
    $button.Size = New-Object System.Drawing.Size(150,40)
    $button.Location = New-Object System.Drawing.Point(120,100)
    $button.Add_Click({
        try {
            $exe = Join-Path $PSScriptRoot "ShooterGame\Binaries\Win64\ArkAscended.exe"
            if (-not $PSScriptRoot) {
                $exe = ".\ShooterGame\Binaries\Win64\ArkAscended.exe"
            }
            
            if (Test-Path $exe) {
                Start-Process $exe -ArgumentList "-noadmin" -WorkingDirectory (Split-Path $exe)
                $form.Close()
            } else {
                [System.Windows.Forms.MessageBox]::Show("ARK executable not found at:`n$exe","Error","OK","Error")
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,"Error","OK","Error")
        }
    })
    $form.Controls.Add($button)

    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# Check for updates
try {
    $latestVersion = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/version.txt" -ErrorAction SilentlyContinue
    if ($latestVersion -and $latestVersion -gt "1.0") {
        $updateResult = [System.Windows.Forms.MessageBox]::Show(
            "New version $latestVersion available! Update now?",
            "Update Available",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($updateResult -eq "Yes") {
            Start-Process "https://github.com/YOURUSERNAME/YOURREPO/releases/latest"
        }
    }
} catch {}

Show-Launcher