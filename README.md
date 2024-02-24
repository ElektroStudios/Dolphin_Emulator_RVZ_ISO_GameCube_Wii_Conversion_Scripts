<!-- Common Project Tags:
command-line 
console-applications 
desktop-app 
desktop-application 
tool 
tools 
vbnet 
windows 
windows-app 
windows-application 
windows-applications 
 -->

# RVZ <> ISO Utility Conversion Script Files for [Dolphin Emulator](https://dolphin-emu.org)

![](/Images/Gamecube.jpg)

------------------

## 👋 Introduction

In this repository you will find utility scripts made in PowerShell to automate the conversion between GameCube console ISO files to RVZ file format, and vice versa.

RVZ format is only supported by Dolphin emulator. It is the modern, optimal, lossless format of choice:
 - https://emulation.gametechwiki.com/index.php/Save_disk_space_for_ISOs#RVZ_.28Modern_Dolphin_format.29_-_GC.2FWii

These script files will use DolphinTool on background:
 - https://github.com/dolphin-emu/dolphin/blob/master/Readme.md#dolphintool-usage

## 📝 Requirements

 - **DolphinTool** standalone executable, which is included in **Dolphin** emulator package:
   - https://dolphin-emu.org/download/

 - **Microsoft PowerShell** (which is integrated in Microsoft Windows OS), or the cross-platform **PowerShell Core**:
   - https://github.com/PowerShell/PowerShell

 - At least one GameCube ISO or RVZ file to use any of these script files, obviously.

## 🤖 Getting Started

Download the latest release by clicking [here](https://github.com/ElektroStudios/Dolphin_Emulator_RVZ_Utility_Scripts/releases/latest),

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

### Additional Commentaries
Run the script files with administrator privileges. You can safely remove this line from the script files if it causes any issues to you:
```
try { Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "Process" } catch { }
```

I'm not a PowerShell enthusiast, it's just a quick tool that I use to satisfy some programmatic needs, so the source code of the scripts in this repository are ugly and some parts of the code a mess (poorly structured code, many repeated lines, resorting to .NET classes usage rather than pure Powershell and pipes, etc), but hey, it works as expected, so I shared them as is.

## 🔄 Change Log

Explore the complete list of changes, bug fixes, and improvements across different releases by clicking [here](/Docs/CHANGELOG.md).

## ⚠️ Disclaimer:

This Work (the repository and the content provided in) is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the Work or the use or other dealings in the Work.

This Work has no affiliation, approval or endorsement by the author(s) of [Dolphin Emulator](https://dolphin-emu.org/).

## 💪 Contributing

Your contribution is highly appreciated!. If you have any ideas, suggestions, or encounter issues, feel free to open an issue by clicking [here](https://github.com/ElektroStudios/Dolphin_Emulator_RVZ_Utility_Scripts/issues/new/choose). 

Your input helps make this Work better for everyone. Thank you for your support! 🚀

## 💰 Beyond Contribution 

This work is distributed for educational purposes and without any profit motive. However, if you find value in my efforts and wish to support and motivate my ongoing work, you may consider contributing financially through the following options:

 - ### Paypal:
    You can donate any amount you like via **Paypal** by clicking on this button:

    [![Donation Account](Images/Paypal_Donate.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=E4RQEV6YF5NZY)

 - ### Envato Market:
   If you are a .NET developer, you may want to explore '**DevCase Class Library for .NET**', a huge set of APIs that I have on sale.
   Almost all reusable code that you can find across my works is condensed, refined and provided through DevCase Class Library.

    Check out the product:
    
   [![DevCase Class Library for .NET](Images/DevCase_Banner.png)](https://codecanyon.net/item/elektrokit-class-library-for-net/19260282)

<u>**Your support means the world to me! Thank you for considering it!**</u> 👍
