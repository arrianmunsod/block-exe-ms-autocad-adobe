# ============================================================
# Block Microsoft Office, Adobe Products like Photoshop,
# Premiere, Acrobat, etc and Autodesk products from 
# connecting to the internet
# ============================================================

# -------- CONFIGURATION --------
$TargetFolders = @(
    "C:\Program Files\Microsoft Office",
    "C:\Program Files\Common Files\microsoft shared\OFFICE16",
    "C:\Program Files\Adobe",
    "C:\Program Files\Autodesk",
    "C:\Program Files\Common Files\Adobe",
    "C:\Program Files\Common Files\Autodesk",
    "C:\Program Files\Common Files\Autodesk Shared",
    "C:\Program Files (x86)\Adobe",
    "C:\Program Files (x86)\Common Files\Adobe",
    "C:\Program Files (x86)\Common Files\Autodesk Shared",
    "C:\ProgramData\Adobe",
    "C:\ProgramData\Autodesk"
)

$RulePrefix = "Block EXE - "
# -------------------------------


# ============================================================
# SELF-LAUNCH AS ADMINISTRATOR
# ============================================================

$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $IsAdmin) {

    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow

    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""

    exit
}


# ============================================================
# PROCESS EACH TARGET FOLDER
# ============================================================

$TotalFound = 0
$TotalCreated = 0
$TotalSkipped = 0


foreach ($TargetFolder in $TargetFolders) {

    # --------------------------------------------------------
    # CHECK TARGET FOLDER
    # --------------------------------------------------------

    if (-not (Test-Path -LiteralPath $TargetFolder -PathType Container)) {

        Write-Host ""
        Write-Host "ERROR: Folder does not exist:" -ForegroundColor Red
        Write-Host $TargetFolder -ForegroundColor Yellow
        Write-Host ""

        continue
    }


    # --------------------------------------------------------
    # FIND EXE FILES
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "============================================================"
    Write-Host "Searching for EXE files..." -ForegroundColor Cyan
    Write-Host "Folder: $TargetFolder"
    Write-Host "============================================================"
    Write-Host ""


    $ExeFiles = Get-ChildItem `
        -LiteralPath $TargetFolder `
        -Filter "*.exe" `
        -File `
        -Recurse `
        -ErrorAction SilentlyContinue


    if ($ExeFiles.Count -eq 0) {

        Write-Host "No EXE files were found." -ForegroundColor Yellow
        Write-Host ""

        continue
    }


    Write-Host "Found $($ExeFiles.Count) EXE file(s)." -ForegroundColor Green
    Write-Host ""


    $TotalFound += $ExeFiles.Count


    # --------------------------------------------------------
    # CREATE FIREWALL RULES
    # --------------------------------------------------------

    foreach ($Exe in $ExeFiles) {

        $ExePath = $Exe.FullName


        # Create a deterministic rule name based on executable path
        $Hash = [System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($ExePath)
            )
        ).Replace("-", "").Substring(0,16)


        $RuleName = "$RulePrefix$($Exe.Name) [$Hash]"


        # Check whether the rule already exists
        $ExistingRule = Get-NetFirewallRule `
            -DisplayName $RuleName `
            -ErrorAction SilentlyContinue


        if ($ExistingRule) {

            Write-Host "[SKIP] $ExePath" -ForegroundColor DarkYellow
            $TotalSkipped++
            continue
        }


        # Create outbound block rule
        New-NetFirewallRule `
            -DisplayName $RuleName `
            -Direction Outbound `
            -Program $ExePath `
            -Action Block `
            -Profile Any `
            -Enabled True `
            -Protocol Any `
            -Description "Blocks Internet/network access for $ExePath" `
            -ErrorAction Stop | Out-Null


        Write-Host "[BLOCKED] $ExePath" -ForegroundColor Green

        $TotalCreated++
    }
}


# ============================================================
# FINISHED
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "Task completed."
Write-Host "============================================================"
Write-Host "EXE files found : $TotalFound"
Write-Host "Rules created   : $TotalCreated"
Write-Host "Rules skipped   : $TotalSkipped"
Write-Host "============================================================"
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Cyan

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")