$ScriptVersion = "1.3"

<#
===========================================================================================
|                                                                                         |
|                                      Script Settings                                    |
|                                                                                         |
===========================================================================================
#>

$dolphinToolFullPath = "$PSScriptRoot\DolphinTool.exe"

$sourceDirectoryPath = "$PSScriptRoot"
$recursiveSearch = $false # If $true, performs a recursive ISO file search in the source directory path.

$outputDirectoryPath = "" # Leave empty to use the same directory as source ISO files.

$overwriteConfirm = $true # If $true, will prompt the user to overwrite any existing ISO file in order to continue.
$sendConvertedFilesToRecycleBin = $false # If $true, successfully converted ISO files will be sent to recycle bin, otherwise, the files will be kept.

$compressionFormat = "lzma2" # Available values: none, zstd, bzip, lzma, lzma2
$compressionLevel  = 9
$blockSize         = 32mb # Higher values can improve file compression, but will require much more available RAM on your computer.

# ┌─────────────────────┬───────────────────┐
# │ Avalable            │ Compression Level │
# │ Compression Formats │ min ~ max range   │     
# ├─────────────────────┼───────────────────┤
# │   bzip, lzma, lzma2 │ 1 ~ 9             │
# │                zstd │ 1 ~ 22            │
# └─────────────────────┴───────────────────┘

# ┌──────────────────────────────────┐
# │      Default Dolphin values      │
# ├──────────────────────────────────┤
# │ CompressionFormat: zstd          │
# │ CompressionLevel: 5              │
# │ BlockSize: 128 KB (131072 bytes) │
# └──────────────────────────────────┘

<#
===========================================================================================
|                                                                                         |
|                                    .NET Code                                            |
|                                                                                         |
===========================================================================================
#>

Add-Type @'
    using System;
    using System.Runtime.InteropServices;
    using System.Text;

    public static class FileSizeHelper {
        public static string FormatByteSize(long fileSize) {
            StringBuilder buffer = new StringBuilder(16);
            NativeMethods.StrFormatByteSize(fileSize, buffer, buffer.Capacity);
            return buffer.ToString().Replace(",0 ", " ");
        }
    }

    internal static class NativeMethods {
        [DllImport("Shlwapi.dll", CharSet = CharSet.Auto)]
        internal static extern long StrFormatByteSize(long fileSize, StringBuilder buffer, int bufferSize);
    }
'@


<#
===========================================================================================
|                                                                                         |
|                                    Functions                                            |
|                                                                                         |
===========================================================================================
#>

function Show-WelcomeScreen {
    Clear-Host
    Write-Host ""
    Write-Host " $($host.ui.RawUI.WindowTitle) | By ElektroStudios (https://git.new/WuQUx1w)"
    Write-Host ""
    Write-Host "+=================================================+"
    Write-Host "|                                                 |"
    Write-Host "| This script will search for GameCube and Wii    |"
    Write-Host "| ISO files in the current working directory, and |"
    Write-Host "| use DolphinTool to convert them to RVZ format.  |"
    Write-Host "|                                                 |"
    Write-Host "+=================================================+"
    Write-Host ""
    Write-Host "Script Settings         " -ForegroundColor DarkGray
    Write-Host "========================" -ForegroundColor DarkGray
    Write-Host "Source Directory Path....: $sourceDirectoryPath" -ForegroundColor DarkGray
    Write-Host "Output Directory Path...: $(if ([string]::IsNullOrWhiteSpace($outputDirectoryPath)) { "Not specified. (Same directory as ISO files)" } else { $outputDirectoryPath.Replace($sourceDirectoryPath, ".") })" -ForegroundColor DarkGray
    Write-Host "DolphinTool File Path...: $($dolphinToolFullPath.Replace($sourceDirectoryPath, "."))" -ForegroundColor DarkGray
    Write-Host "Recursive File Search...: $recursiveSearch" -ForegroundColor DarkGray
    Write-Host "Compression Format......: $compressionFormat" -ForegroundColor DarkGray
    Write-Host "Compression Level.......: $compressionLevel" -ForegroundColor DarkGray
    Write-Host "Compression Block Size..: $([FileSizeHelper]::FormatByteSize($blockSize)) ($blockSize bytes)" -ForegroundColor DarkGray
    Write-Host "Confirm Overwrite RVZ...: $overwriteConfirm" -ForegroundColor DarkGray
    Write-Host "Recycle Converted Files.: $sendConvertedFilesToRecycleBin" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "================================================================================="
    Write-Host "Please note that the settings above are hard-coded in the script file."
    Write-Host "This means you must edit the script manually (for example, using Notepad)"
    Write-Host "to change any settings. The values are documented, so it is straightforward."
    Write-Host ""
    Write-Host "Also, please note that using block size values larger than 128 KB (131072 bytes)"
    Write-Host "may cause emulation issues depending on the capabilities of the machine you use"
    Write-Host "to emulate the ROMs. On a PC, a block size of 32 MB (33554432 bytes) should be"
    Write-Host "generally safe to achieve optimal compression without any negative effects."
    Write-Host ""
    Write-Host "However, the script files are provided ""as-is"", so use them at your own risk."
    Write-Host "Make sure to review the settings before running the scripts, back up your ROMs,"
    Write-Host "and test the performance of compressed ROMs before deleting the original ones."
    Write-Host "================================================================================="
    Write-Host ""
}

function Confirm-Continue {
    Write-Host "Press 'Y' key to continue or 'N' to exit."
    Write-Host ""
    Write-Host "-Continue? (Y/N)"
    do {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $char = $key.Character.ToString().ToUpper()
        if ($char -ne "Y" -and $char -ne "N") {
            [console]::beep(1500, 500)
        }
    } while ($char -ne "Y" -and $char -ne "N")
    if ($char -eq "N") {Exit(1)}
}

function Validate-Settings {
    
    if (-not (Test-Path -LiteralPath $sourceDirectoryPath -PathType Container)) {
        Write-Host "ERROR: Source directory path does not exist: $($sourceDirectoryPath)" -BackgroundColor Black -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..."
        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
        Exit(1)
    }

    if (-not (Test-Path -LiteralPath $dolphinToolFullPath -PathType Leaf)) {
        Write-Host "ERROR: DolphinTool executable file path does not exist: $($dolphinToolFullPath)" -BackgroundColor Black -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..."
        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
        Exit(1)
    }
}

function Convert-Files {

    Clear-Host
    Add-Type -AssemblyName Microsoft.VisualBasic

    $isoFiles = $null
    if ($recursiveSearch) {
        $isoFiles = Get-ChildItem -LiteralPath $sourceDirectoryPath -Filter "*.*" -Recurse -File -ErrorAction Stop |
                    Where-Object { $_.Extension -ieq '.iso' } |
                    ForEach-Object { New-Object System.IO.FileInfo -ArgumentList $_.FullName }
    } else {
        $isoFiles = Get-ChildItem -LiteralPath $sourceDirectoryPath -Filter "*.*" -File -ErrorAction Stop |
                    Where-Object { $_.Extension -ieq '.iso' } |
                    ForEach-Object { New-Object System.IO.FileInfo -ArgumentList $_.FullName }
    }

    if ($isoFiles.Count -eq 0) {
        Write-Warning "No ISO files were found in source directory path."
    }

    foreach ($isoFile in $isoFiles) {    
        $dolphinToolFile = New-Object System.IO.FileInfo($dolphinToolFullPath)
        if (-not $dolphinToolFile.Exists) {
            Write-Host "ERROR: DolphinTool executable file path does not exist: $($dolphinToolFile.FullName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host ""
            Write-Host "Press any key to exit..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
            Exit(1)
        }

        if (-not $isoFile.Exists) {
            Write-Host "ERROR: Source ISO file path does not exist: $($isoFile.FullName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host ""
            Write-Host "Press any key to exit..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
            Exit(1)
        }

        if ([string]::IsNullOrWhiteSpace($outputDirectoryPath)) {
            $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))
        } else {
            try {
                if (-Not (Test-Path -Path $outputDirectoryPath)) {
                    $directory = New-Item -Path $outputDirectoryPath -ItemType Directory -ErrorAction Stop
                }

            } catch {
                Write-Host "Error trying to create output directory: $_" -BackgroundColor Black -ForegroundColor Red
                Write-Host ""
                Write-Host "Press any key to exit..."
                $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                Exit(1)
            }
            $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::Combine($outputDirectoryPath, [System.IO.Path]::GetFileName([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))))
        }

        if ($outputRvzFile.Exists) {
            Write-Warning "Output RVZ file already exists: $($outputRvzFile.FullName)"
            Write-Warning "The output RVZ file will be overwitten if you continue."
            Write-Host ""
            Confirm-Continue
            Write-Host ""
        }

        Write-Host "Converting $($isoFile.FullName)..."
        $dolphinToolConvert = New-Object System.Diagnostics.Process
        $dolphinToolConvert.StartInfo.FileName = $dolphinToolFile.FullName
        $dolphinToolConvert.StartInfo.WorkingDirectory = $dolphinToolFile.DirectoryName
        $dolphinToolConvert.StartInfo.Arguments = "convert --format=rvz --input=`"$($isoFile.FullName)`" --output=`"$($outputRvzFile.FullName)`" --block_size=$blockSize --compression=$compressionFormat --compression_level=$compressionLevel"
        $dolphinToolConvert.StartInfo.RedirectStandardOutput = $true
        $dolphinToolConvert.StartInfo.RedirectStandardError = $true
        $dolphinToolConvert.StartInfo.UseShellExecute = $false
        $dolphinToolConvert.StartInfo.CreateNoWindow = $false
        $startedConvert   = $dolphinToolConvert.Start() # | Out-Null
        $exitedConvert    = $dolphinToolConvert.WaitForExit()
        $exitCodeConvert  = $dolphinToolConvert.ExitCode
        $stdOutputConvert = $dolphinToolConvert.StandardOutput.ReadToEnd()
        $stdErrorConvert  = $dolphinToolConvert.StandardError.ReadToEnd()

        switch ($exitCodeConvert) {
            0 {
                Write-Host "Conversion successful." -ForegroundColor DarkGreen
                Write-Host "Verifying integrity of output RVZ file..." -ForegroundColor DarkGray
                $dolphinToolVerify = New-Object System.Diagnostics.Process
                $dolphinToolVerify.StartInfo.FileName = $dolphinToolFile.FullName
                $dolphinToolVerify.StartInfo.WorkingDirectory = $dolphinToolFile.DirectoryName
                $dolphinToolVerify.StartInfo.Arguments = "verify --input=`"$($outputRvzFile.FullName)`""
                $dolphinToolVerify.StartInfo.RedirectStandardOutput = $true
                $dolphinToolVerify.StartInfo.RedirectStandardError = $true
                $dolphinToolVerify.StartInfo.UseShellExecute = $false
                $dolphinToolVerify.StartInfo.CreateNoWindow = $false
                $startedVerify   = $dolphinToolVerify.Start() # | Out-Null
                $exitedVerify    = $dolphinToolVerify.WaitForExit()
                $exitCodeVerify  = $dolphinToolVerify.ExitCode
                $stdOutputVerify = $dolphinToolVerify.StandardOutput.ReadToEnd()
                $stdErrorVerify  = $dolphinToolVerify.StandardError.ReadToEnd()
                if (-not ($stdOutputVerify | Select-String "Problems Found: No")) {
                    Write-Warning "Verification procedure have found problems in output RVZ file:"
                    Write-Warning $stdOutputVerify
                    Write-Warning $stdErrorVerify
                    Write-Host ""
                    Write-Host "Error verifying $($outputRvzFile.FullName)" -ForegroundColor Red
                    Write-Host ""
                    $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))
                    if ($outputRvzFile.Exists) {
                        Write-Host "Press any key to delete the failed RVZ file and continue converting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                        try {
                            $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outputRvzFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        } catch {
                            Write-Host "ERROR: Failed to delete $($outputRvzFile.FullName)" -ForegroundColor Red
                            Write-Host ""
                            Write-Host "Press any key to ignore and continue converting the next file..."
                            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                        }
                    } else {
                        Write-Host "Press any to ignore and continue converting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                    Write-Host ""
                    break
                } else {
                    # Write-Host $stdOutputVerify -ForegroundColor DarkGray
                    Write-Host "Verification successful." -ForegroundColor DarkGreen
                    if ($sendConvertedFilesToRecycleBin) {
                        Write-Host "Deleting source ISO file..." -ForegroundColor DarkGray
                        $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($isoFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        Write-Host "Deletion completed." -ForegroundColor DarkGray
                    }
                    Write-Host ""
                    break
                }
            }
            default {
                Write-Warning $stdOutputConvert
                Write-Warning $stdErrorConvert
                Write-Host ""
                Write-Host "Error Converting $($isoFile.FullName):" -ForegroundColor Red
                Write-Host ""
                Write-Host "Execution Command: ""$($dolphinToolFile.Name)"" $($dolphinToolConvert.StartInfo.Arguments)" -ForegroundColor Red
                Write-Host ""
                Write-Host "Exit Code: $exitCodeConvert" -ForegroundColor Red
                Write-Host ""
                $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))
                if ($outputRvzFile.Exists) {
                    Write-Host "Press any key to delete the failed RVZ file and continue converting the next file..."
                    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    try {
                        $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outputRvzFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                    } catch {
                        Write-Host "ERROR: Failed to delete $($outputRvzFile.FullName)" -ForegroundColor Red
                        Write-Host ""
                        Write-Host "Press any key to ignore and continue converting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                } else {
                    Write-Host "Press any key to ignore and continue converting the next file..."
                    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                }
                Write-Host ""
                break
            }
        }
    }
}

function Show-GoodbyeScreen {
    Write-Host "Operation Completed!" -BackgroundColor Black -ForegroundColor Green
    Write-Host ""
    Write-Host "Press any key to exit..."
    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    Exit(0)
}

<#
===========================================================================================
|                                                                                         |
|                                         Main                                            |
|                                                                                         |
===========================================================================================
#>

[System.Console]::Title = "Dolphin's ISO to RVZ converter v$ScriptVersion"
#[System.Console]::SetWindowSize(146, 27)
[CultureInfo]::CurrentUICulture = "en-US"

try { Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "Process" } catch { }

Show-WelcomeScreen
Validate-Settings
Confirm-Continue
Convert-Files
Show-GoodbyeScreen
