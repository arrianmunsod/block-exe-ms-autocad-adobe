# Block Microsoft Office, Adobe, and Autodesk Applications from Connecting to the Internet Using Windows Firewall

A PowerShell script that automatically searches selected Microsoft Office, Adobe, and Autodesk installation folders for `.exe` files and creates individual Windows Firewall outbound blocking rules for each executable it finds.

Compatible with **Windows 10 and Windows 11**.

## Features

- Automatically requests Administrator privileges.
- Searches predefined Microsoft Office, Adobe, and Autodesk installation directories.
- Recursively searches all subfolders for `.exe` files.
- Creates individual Windows Firewall outbound blocking rules.
- Detects existing rules and skips them to prevent duplicates.
- Displays the total number of executable files found, rules created, and rules skipped.
- Does not delete, modify, or uninstall applications.

## Repository Contents

| File | Description |
|---|---|
| `block-exe-ms-autocad-adobe.ps1` | Main PowerShell script that searches selected installation directories and creates Windows Firewall blocking rules. |

## Installation

### Step 1 — Download the PowerShell Script

1. Open this GitHub repository.
2. Click `block-exe-ms-autocad-adobe.ps1`.
3. Click the **Download raw file** button.
4. Save the file to your preferred location, such as your Desktop.

You only need the `.ps1` file. No additional files or installations are required.

## Usage

### Step 1 — Run the Script

1. Locate the downloaded `block-exe-ms-autocad-adobe.ps1` file.
2. Right-click the file.
3. Select **Run with PowerShell**.
4. When the User Account Control (UAC) prompt appears, click **Yes**.

The script automatically requests Administrator privileges if it is not already running with elevated permissions.

### Step 2 — Automatic Folder Scanning

Once the script starts, it automatically searches the predefined installation directories.

The default target folders include:

- Microsoft Office
- Adobe
- Autodesk

The script checks each configured directory and all its subfolders for `.exe` files.

You do not need to manually enter folder paths or executable filenames.

### Step 3 — Firewall Rules Are Created

For every executable file found, the script creates an individual Windows Firewall **Outbound Block** rule.

Example output:

```text
[BLOCKED] C:\Program Files\Adobe\Adobe Photoshop 2026\Photoshop.exe
[BLOCKED] C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE
[BLOCKED] C:\Program Files\Autodesk\AutoCAD 2026\acad.exe
```

If the script detects an existing matching firewall rule, it skips that executable.

Example:

```text
[SKIP] C:\Program Files\Adobe\Adobe Photoshop 2026\Photoshop.exe
```

This prevents duplicate rules from being created.

### Step 4 — Wait Until the Script Finishes

Once all configured folders have been processed, the script displays a summary.

Example:

```text
============================================================
Task completed.
============================================================
EXE files found : 150
Rules created   : 150
Rules skipped   : 0
============================================================

Press any key to exit...
```

The numbers will vary depending on the installed applications and existing firewall rules.

**EXE files found**

The total number of executable files discovered across the configured folders.

**Rules created**

The number of new Windows Firewall blocking rules successfully created.

**Rules skipped**

The number of executable files that already have matching firewall rules.

### Step 5 — Close the Window

When you see:

```text
Press any key to exit...
```

Press any key on your keyboard.

The PowerShell window will close.

The firewall rules remain active even after the script has finished.

## How to Verify the Firewall Rules

You can manually check the rules created by the script.

1. Press **Windows Key + R**.
2. Type:

```text
wf.msc
```

3. Press **Enter**.

This opens **Windows Defender Firewall with Advanced Security**.

Select:

**Outbound Rules**

Look for rules beginning with:

```text
Block EXE -
```

These are the rules created by the script.

## Adding More Folders

You can customize the script to include additional installation directories.

Open `block-exe-ms-autocad-adobe.ps1` using Notepad or another text editor.

Locate the `$TargetFolders` configuration section:

```powershell
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
```

Add your desired folder paths inside the parentheses.

For example:

```powershell
$TargetFolders = @(
    "C:\Program Files\Microsoft Office",
    "C:\Program Files\Adobe",
    "C:\Program Files\Autodesk",
    "C:\My Other Software"
)
```

Every folder path must be enclosed in quotation marks. Separate entries with commas, except for the last entry.

Save the modified script and run it again.

## Important Considerations

The script only searches the directories specified in `$TargetFolders`.

If an application stores its executable files somewhere else, those files will not be included unless their directory is added to the configuration.

Blocking an application's executables from accessing the network may affect:

- Online activation
- License verification
- Automatic updates
- Cloud synchronization
- Online features
- Sign-in functionality
- Other services that require Internet access

Use this script only on software for which you understand the consequences of blocking network access.

## Development Note

AI-assisted development. Code reviewed and tested by the author.

---

<p align="center">
  <a href="https://github.com/arrianmunsod">
    <strong>← BACK TO ARRIAN'S GITHUB PROFILE</strong>
  </a>
  <br>
  <sub>Explore more projects, scripts, and technical documentation.</sub>
</p>
