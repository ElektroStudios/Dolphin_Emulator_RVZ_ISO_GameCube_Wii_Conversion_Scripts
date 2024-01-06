# RVZ <> ISO Utility Script Files for Dolphin Emulator 

![](https://i.imgur.com/kwMXeEt.jpg)

--------------------------

# What is this?

In this repository you will find utility scripts made in PowerShell to automate the conversion between GameCube console ISO files to RVZ file format, and vice versa.

RVZ format is only supported by Dolphin emulator. It is the modern, optimal, lossless format of choice:
 - https://emulation.gametechwiki.com/index.php/Save_disk_space_for_ISOs#RVZ_.28Modern_Dolphin_format.29_-_GC.2FWii

These script files will use DolphinTool on background:
 - https://github.com/dolphin-emu/dolphin/blob/master/Readme.md#dolphintool-usage

# Requirements

 - **DolphinTool** standalone executable, which is included in **Dolphin** emulator package:
   https://dolphin-emu.org/download/

 - **Microsoft PowerShell** (which is integrated in Microsoft Windows OS), or the cross-platform **PowerShell Core**:
    https://github.com/PowerShell/PowerShell

 - At least one GameCube ISO or RVZ file to use any of these script files, obviously.

--------------------------

# How to start?

### Converting ISO to RVJ

1. Download the `ISO to RVZ.ps1` script file from this repository (make click on the file in GitHub to view the code and copy it, and also you can find a button to download the raw file).

2. Open the script file in notepad and edit as you like the values of the Variables section at the very top of the script. The default values are:

```
$dolphinToolFullPath = "$PSScriptRoot\DolphinTool.exe"
$inputDirectoryPath = "$PSScriptRoot"
$recursiveSearch = $false
$overwriteConfirm = $true
$sendConvertedFilesToRecycleBin = $true
$compressionFormat = "lzma2" # none, zstd, bzip, lzma, lzma2
$compressionLevel  = 9       # zstd: 1~22, bzip/lzma/lzma2: 1~9
$dictionarySize    = 32mb
```
| Variable Name   |      Meaning      |
|----------|-------------|
| $dolphinToolFullPath |  The DolphinTool.exe full file path (it can be a relative path) |
| $inputDirectoryPath  |  The directory where to search for ISO files to convert them |
| $recursiveSearch  |  Flag to indicate recursive search for ISO files. |
| $overwriteConfirm  |  Flag to confirm overwrite for existing RVZ files |
| $sendConvertedFilesToRecycleBin  | Flag to send to recycle bin successfully converted ISO files. If you set this value to $false, converted ISO files will be kept. |
| $compressionFormat  |  Compression format |
| $compressionLevel   |  Compression level |
| $dictionarySize     |  Block size used for compression |

3. Run the script file, and wait until the conversion operation completes.

### Converting RVZ to ISO

1. Download the `RVZ to ISO.ps1` script file from this repository (make click on the file in GitHub to view the code and copy it, and also you can find a button to download the raw file).

2. Open the script file in notepad and edit as you like the values of the Variables section at the very top of the script. The default values are:

```
$dolphinToolFullPath = "$PSScriptRoot\DolphinTool.exe"
$inputDirectoryPath = "$PSScriptRoot"
$recursiveSearch = $false
$overwriteConfirm = $true
$sendConvertedFilesToRecycleBin = $true
```
| Variable Name   |      Meaning      |
|----------|-------------|
| $dolphinToolFullPath |  The DolphinTool.exe full file path (it can be a relative path) |
| $inputDirectoryPath  |  The directory where to search for RVZ files to convert them |
| $recursiveSearch  |  Flag to indicate recursive search for RVZ files. |
| $overwriteConfirm  |  Flag to confirm overwrite for existing ISO files |
| $sendConvertedFilesToRecycleBin  | Flag to send to recycle bin successfully converted RVZ files. If you set this value to $false, converted files will be kept. |

3. Run the script file, and wait until the conversion operation completes.

--------------------------

# Additional Commentaries
I'm not a PowerShell enthusiast, it's just a quick tool that I use to satisfy some programmatic needs, so the source code of the scripts in this repository are ugly (poorly structured code, many repeated lines, using .NET classes rather than pure Powershell, etc), but hey, it works, so I shared them as is.
