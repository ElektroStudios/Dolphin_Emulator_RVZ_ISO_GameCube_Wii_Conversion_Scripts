# Version 1.0

<#
===========================================================================================
|                                                                                         |
|                                        Variables                                        |
|                                                                                         |
===========================================================================================
#>

$dolphinToolFullPath = "$PSScriptRoot\DolphinTool.exe"

$inputDirectoryPath = "$PSScriptRoot"
$recursiveSearch = $false

$overwriteConfirm = $true
$sendConvertedFilesToRecycleBin = $false

$compressionFormat = "lzma2" # none, zstd, bzip, lzma, lzma2
$compressionLevel  = 9       # zstd: 1~22, bzip/lzma/lzma2: 1~9
$dictionarySize    = 32mb

# Default Dolphin values:
# -----------------------
# $compressionFormat = "zstd"
# $compressionLevel  = 5
# $dictionarySize    = 128kb

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
    Write-Host " $($host.ui.RawUI.WindowTitle)"
    Write-Host " +================================================+"
    Write-Host " |                                                |"
    Write-Host " | This script will search for GameCube's ISO     |"
    Write-Host " | files in the current working directory, and    |"
    Write-Host " | use DolphinTool to convert them to RVZ format. |"
    Write-Host " |                                                |"
    Write-Host " +================================================+"
    Write-Host ""
    Write-Host " Script Settings         " -ForegroundColor DarkGray
    Write-Host " ========================" -ForegroundColor DarkGray
    Write-Host " Input Directory Path....: $inputDirectoryPath" -ForegroundColor DarkGray
    Write-Host " Recursive File Search...: $recursiveSearch" -ForegroundColor DarkGray
    Write-Host " DolphinTool Full Path...: $dolphinToolFullPath" -ForegroundColor DarkGray
    Write-Host " Compression Format......: $compressionFormat" -ForegroundColor DarkGray
    Write-Host " Compression Level.......: $compressionLevel" -ForegroundColor DarkGray
    Write-Host " Compression Dict. Size..: $dictionarySize bytes" -ForegroundColor DarkGray
    Write-Host " Confirm Overwrite RVZ...: $overwriteConfirm" -ForegroundColor DarkGray
    Write-Host " Recycle Converted Files.: $sendConvertedFilesToRecycleBin" -ForegroundColor DarkGray
    Write-Host ""
}

function Confirm-Continue {
    Write-Host " Press 'Y' key to continue or 'N' to exit."
    Write-Host ""
    Write-Host " -Continue? (Y/N)"
    do {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $char = $key.Character.ToString().ToUpper()
        if ($char -ne "Y" -and $char -ne "N") {
            [console]::beep(1500, 500)
        }
    } while ($char -ne "Y" -and $char -ne "N")
    if ($char -eq "N") {Exit(1)}
}

function Validate-Variables {
    
    if (-not (Test-Path -LiteralPath $inputDirectoryPath -PathType Container)) {
        Write-Host " Input directory path does not exists!" -BackgroundColor Black -ForegroundColor Red
        Write-Host ""
        Write-Host " Press any key to exit..."
        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
        Exit(1)
    }

    if (-not (Test-Path -LiteralPath $dolphinToolFullPath -PathType Leaf)) {
        Write-Host " DolphinTool file path does not exists!" -BackgroundColor Black -ForegroundColor Red
        Write-Host ""
        Write-Host " Press any key to exit..."
        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
        Exit(1)
    }
}

function Convert-Files {

    Clear-Host
    Add-Type -AssemblyName Microsoft.VisualBasic

    $isoFiles = $null
    if ($recursiveSearch) {
        $isoFiles = Get-ChildItem -LiteralPath $inputDirectoryPath -Filter "*.*" -Recurse -File -ErrorAction Stop |
                    Where-Object { $_.Extension -ieq '.iso' } |
                    ForEach-Object { New-Object System.IO.FileInfo -ArgumentList $_.FullName }
    } else {
        $isoFiles = Get-ChildItem -LiteralPath $inputDirectoryPath -Filter "*.*" -File -ErrorAction Stop |
                    Where-Object { $_.Extension -ieq '.iso' } |
                    ForEach-Object { New-Object System.IO.FileInfo -ArgumentList $_.FullName }
    }

    foreach ($isoFile in $isoFiles) {    
        $dolphinToolFile = New-Object System.IO.FileInfo($dolphinToolFullPath)
        if (-not $dolphinToolFile.Exists) {
            Write-Host " DolphinTool executable file path does not exist: $($dolphinToolFile.FullName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host ""
            Write-Host " Press any key to exit..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
            Exit(1)
        }

        if (-not $isoFile.Exists) {
            Write-Host " Input ISO file path does not exist: $($isoFile.FullName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host ""
            Write-Host " Press any key to exit..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
            Exit(1)
        }

        $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))
        if ($outputRvzFile.Exists) {
            Write-Warning " Output RVZ file already exists: $($outputRvzFile.FullName)"
            Write-Warning " The output RVZ file will be overwitten if you continue."
            Write-Host ""
            Confirm-Continue
            Write-Host ""
        }

        Write-Host " Converting $($isoFile.FullName)..."
        $dolphinToolConvert = New-Object System.Diagnostics.Process
        $dolphinToolConvert.StartInfo.FileName = $dolphinToolFile.FullName
        $dolphinToolConvert.StartInfo.WorkingDirectory = $dolphinToolFile.DirectoryName
        $dolphinToolConvert.StartInfo.Arguments = "convert --format=rvz --input=`"$($isoFile.FullName)`" --output=`"$($outputRvzFile.FullName)`" --block_size=$dictionarySize --compression=$compressionFormat --compression_level=$compressionLevel"
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
                Write-Host " Conversion successful." -ForegroundColor DarkGreen
                Write-Host " Verifying integrity of output RVZ file..." -ForegroundColor DarkGray
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
                    Write-Warning " Verification procedure have found problems in output RVZ file:"
                    Write-Warning $stdOutputVerify
                    Write-Warning $stdErrorVerify
                    Write-Host ""
                    Write-Host " Error verifying $($outputRvzFile.FullName)" -ForegroundColor Red
                    Write-Host ""
                    $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))
                    if ($outputRvzFile.Exists) {
                        Write-Host " Press any key to delete the failed RVZ file and continue converting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                        try {
                            $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outputRvzFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        } catch {
                            Write-Host " Failed to delete $($outputRvzFile.FullName)" -ForegroundColor Red
                            Write-Host ""
                            Write-Host " Press any key to ignore and continue converting the next file..."
                            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                        }
                    } else {
                        Write-Host " Press any to ignore and continue converting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                    Write-Host ""
                    break
                } else {
                    # Write-Host $stdOutputVerify -ForegroundColor DarkGray
                    Write-Host " Verification successful." -ForegroundColor DarkGreen
                    if ($sendConvertedFilesToRecycleBin) {
                        Write-Host " Deleting input ISO file..." -ForegroundColor DarkGray
                        $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($isoFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        Write-Host " Deletion completed." -ForegroundColor DarkGray
                    }
                    Write-Host ""
                    break
                }
            }
            default {
                Write-Host " Error converting $($isoFile.FullName):" -ForegroundColor Red
                Write-Host ""
                Write-Warning $stdOutputConvert
                Write-Warning $stdErrorConvert
                Write-Host ""
                $outputRvzFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($isoFile.FullName, "rvz"))
                if ($outputRvzFile.Exists) {
                    Write-Host " Press any key to delete the failed RVZ file and continue converting the next file..."
                    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    try {
                        $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outputRvzFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                    } catch {
                        Write-Host " Failed to delete $($outputRvzFile.FullName)" -ForegroundColor Red
                        Write-Host ""
                        Write-Host " Press any key to ignore and continue converting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                } else {
                    Write-Host " Press any key to ignore and continue converting the next file..."
                    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                }
                Write-Host ""
                break
            }
        }
    }
}

function Show-GoodbyeScreen {
    Write-Host " Operation Completed!" -BackgroundColor Black -ForegroundColor Green
    Write-Host ""
    Write-Host " Press any key to exit..."
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

[System.Console]::Title = "Convert ISO to RVZ - by ElektroStudios"
#[System.Console]::SetWindowSize(146, 27)
[CultureInfo]::CurrentUICulture = "en-US"

try { Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "Process" } catch { }

Show-WelcomeScreen
Validate-Variables
Confirm-Continue
Convert-Files
Show-GoodbyeScreen
