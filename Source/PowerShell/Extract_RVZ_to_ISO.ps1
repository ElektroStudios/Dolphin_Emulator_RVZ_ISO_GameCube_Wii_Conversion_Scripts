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
    Write-Host " | This script will search for GameCube's RVZ     |"
    Write-Host " | files in the current working directory, and    |"
    Write-Host " | use DolphinTool to convert them to ISO format. |"
    Write-Host " |                                                |"
    Write-Host " +================================================+"
    Write-Host ""
    Write-Host " Script Settings         " -ForegroundColor DarkGray
    Write-Host " ========================" -ForegroundColor DarkGray
    Write-Host " Input Directory Path....: $inputDirectoryPath" -ForegroundColor DarkGray
    Write-Host " Recursive File Search...: $recursiveSearch" -ForegroundColor DarkGray
    Write-Host " DolphinTool Full Path...: $dolphinToolFullPath" -ForegroundColor DarkGray
    Write-Host " Confirm Overwrite ISO...: $overwriteConfirm" -ForegroundColor DarkGray
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

    $rvzFiles = $null
    if ($recursiveSearch) {
        $rvzFiles = Get-ChildItem -LiteralPath $inputDirectoryPath -Filter "*.*" -Recurse -File -ErrorAction Stop |
                    Where-Object { $_.Extension -ieq '.rvz' } |
                    ForEach-Object { New-Object System.IO.FileInfo -ArgumentList $_.FullName }
    } else {
        $rvzFiles = Get-ChildItem -LiteralPath $inputDirectoryPath -Filter "*.*" -File -ErrorAction Stop |
                    Where-Object { $_.Extension -ieq '.rvz' } |
                    ForEach-Object { New-Object System.IO.FileInfo -ArgumentList $_.FullName }
    }

    foreach ($rvzFile in $rvzFiles) {    
        $dolphinToolFile = New-Object System.IO.FileInfo($dolphinToolFullPath)
        if (-not $dolphinToolFile.Exists) {
            Write-Host " DolphinTool executable file path does not exist: $($dolphinToolFile.FullName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host ""
            Write-Host " Press any key to exit..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
            Exit(1)
        }

        if (-not $rvzFile.Exists) {
            Write-Host " Input RVZ file path does not exist: $($rvzFile.FullName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host ""
            Write-Host " Press any key to exit..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
            Exit(1)
        }

        $outputIsoFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($rvzFile.FullName, "iso"))
        if ($outputIsoFile.Exists) {
            Write-Warning " Output ISO file already exists: $($outputIsoFile.FullName)"
            Write-Warning " The output ISO file will be overwitten if you continue."
            Write-Host ""
            Confirm-Continue
            Write-Host ""
        }

        Write-Host " Extracting $($rvzFile.FullName)..."
        $dolphinToolConvert = New-Object System.Diagnostics.Process
        $dolphinToolConvert.StartInfo.FileName = $dolphinToolFile.FullName
        $dolphinToolConvert.StartInfo.WorkingDirectory = $dolphinToolFile.DirectoryName
        $dolphinToolConvert.StartInfo.Arguments = "convert --format=iso --input=`"$($rvzFile.FullName)`" --output=`"$($outputIsoFile.FullName)`""
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
                Write-Host " Verifying integrity of output ISO file..." -ForegroundColor DarkGray
                $dolphinToolVerify = New-Object System.Diagnostics.Process
                $dolphinToolVerify.StartInfo.FileName = $dolphinToolFile.FullName
                $dolphinToolVerify.StartInfo.WorkingDirectory = $dolphinToolFile.DirectoryName
                $dolphinToolVerify.StartInfo.Arguments = "verify --input=`"$($outputIsoFile.FullName)`""
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
                    Write-Warning " Verification procedure have found problems in output ISO file:"
                    Write-Warning $stdOutputVerify
                    Write-Warning $stdErrorVerify
                    Write-Host ""
                    Write-Host " Error verifying $($outputIsoFile.FullName)" -ForegroundColor Red
                    Write-Host ""
                    $outputIsoFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($rvzFile.FullName, "iso"))
                    if ($outputIsoFile.Exists) {
                        Write-Host " Press any key to delete the failed ISO file and continue extracting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                        try {
                            $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outputIsoFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        } catch {
                            Write-Host " Failed to delete $($outputIsoFile.FullName)" -ForegroundColor Red
                            Write-Host ""
                            Write-Host " Press any key to ignore and continue extracting the next file..."
                            $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                        }
                    } else {
                        Write-Host " Press any key to ignore and continue extracting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                    Write-Host ""
                    break
                } else {
                    # Write-Host $stdOutputVerify -ForegroundColor DarkGray
                    Write-Host " Verification successful." -ForegroundColor DarkGreen
                    if ($sendConvertedFilesToRecycleBin) {
                        Write-Host " Deleting input RVZ file..." -ForegroundColor DarkGray
                        $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($rvzFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        Write-Host " Deletion completed." -ForegroundColor DarkGray
                    }
                    Write-Host ""
                    break
                }
            }
            default {
                Write-Host " Error extracting $($rvzFile.FullName):" -ForegroundColor Red
                Write-Host ""
                Write-Warning $stdOutputConvert
                Write-Warning $stdErrorConvert
                Write-Host ""
                $outputIsoFile = New-Object System.IO.FileInfo -ArgumentList ([System.IO.Path]::ChangeExtension($rvzFile.FullName, "iso"))
                if ($outputIsoFile.Exists) {
                    Write-Host " Press any key to delete the failed ISO file and continue extracting the next file..."
                    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    try {
                        $null = [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outputIsoFile.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                    } catch {
                        Write-Host " Failed to delete $($outputIsoFile.FullName)" -ForegroundColor Red
                        Write-Host ""
                        Write-Host " Press any key to ignore and continue extracting the next file..."
                        $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                } else {
                    Write-Host " Press any key to ignore and continue extracting the next file..."
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

[System.Console]::Title = "Extract RVZ to ISO - by ElektroStudios"
#[System.Console]::SetWindowSize(146, 27)
[CultureInfo]::CurrentUICulture = "en-US"

try { Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "Process" } catch { }

Show-WelcomeScreen
Validate-Variables
Confirm-Continue
Convert-Files
Show-GoodbyeScreen
