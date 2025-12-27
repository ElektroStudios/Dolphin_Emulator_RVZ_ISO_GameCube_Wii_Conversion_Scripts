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

# RVZ <> ISO Utility Conversion Script Files 
# for [Dolphin Emulator](https://dolphin-emu.org)

![](/Images/Gamecube.jpg) ![](/Images/Wii.png)
------------------

## 👋 Introduction

In this repository you will find utility scripts made in PowerShell to automate the conversion between GameCube and Wii's console ISO files to RVZ file format, and vice versa.

RVZ format is only supported by Dolphin emulator. It is the modern, optimal, lossless format of choice:
 - https://emulation.gametechwiki.com/index.php/Save_disk_space_for_ISOs#RVZ_.28Modern_Dolphin_format.29_-_GC.2FWii

These script files will use DolphinTool on background:
 - https://github.com/dolphin-emu/dolphin/blob/master/Readme.md#dolphintool-usage

## 📝 Requirements

 - **DolphinTool** standalone executable, which is included in **Dolphin** emulator package:
   - https://dolphin-emu.org/download/

 - **Microsoft PowerShell** (which is integrated in Microsoft Windows OS), or the cross-platform **PowerShell Core**:
   - https://github.com/PowerShell/PowerShell

 - At least one GameCube or Wii ISO or RVZ file to use any of these script files, obviously.

## 🤖 Getting Started

Download the latest release by clicking [here](https://github.com/ElektroStudios/Dolphin_Emulator_RVZ_Utility_Scripts/releases/latest),

### Converting ISO to RVZ

⚠️ **IMPORTANT — BEFORE USING:**  

> Please note that using block size values larger than 128 KB (131072 bytes) may cause emulation issues
> depending on the capabilities of the machine you use to emulate the ROMs. On a PC, a block size of 32 MB
> (33554432 bytes) should be generally safe and work well without any negative effects.
>
> However, the script files are provided **"as-is"**, so use them at your own risk.
> Make sure to review the settings before running the scripts, back up your ROMs, and test the compressed
> ROMs before deleting the original ones.

1. Download the `Convert_ISO_to_RVZ.ps1` (or simpler version `Convert_ISO_to_RVZ.bat`) script file from this repository (make click on the file in GitHub to view the code and copy it, and also you can find a button to download the raw file).

2. Open the script file in notepad and edit as you like the values of the Variables section at the very top of the script. The default values are:

```
$dolphinToolFullPath = "$PSScriptRoot\DolphinTool.exe"
$inputDirectoryPath = "$PSScriptRoot"
$outputDirectoryPath = ""
$recursiveSearch = $false
$overwriteConfirm = $true
$sendConvertedFilesToRecycleBin = $true
$compressionFormat = "lzma2" # none, zstd, bzip, lzma, lzma2
$compressionLevel  = 9       # zstd: 1~22, bzip/lzma/lzma2: 1~9
$blockSize         = 32mb
```
| Variable Name   |      Meaning      |
|----------|-------------|
| $dolphinToolFullPath |  The DolphinTool.exe full file path (it can be a relative path) |
| $inputDirectoryPath  |  The directory where to search for ISO files to convert them to RVZ format. |
| $outputDirectoryPath |  The directory where to write the converted RVZ files. |
| $recursiveSearch     |  Flag to indicate whether to perform a recursive search for ISO files. |
| $overwriteConfirm    |  Flag to confirm overwrite for any existing RVZ file in the output directory. |
| $sendConvertedFilesToRecycleBin  | Flag to send successfully converted ISO files to recycle bin. If you set this value to $false, converted ISO files will be kept. |
| $compressionFormat  |  Compression format |
| $compressionLevel   |  Compression level |
| $blockSize          |  Block size used for compression |

3. Run the script file, and wait until the conversion operation completes.

## 📸 Screenshots

![](/Images/Convert_ISO_to_RVZ.bat.png)

![](/Images/Convert_ISO_to_RVZ.ps1.png)

### Converting RVZ to ISO

1. Download the `Extract_RVZ_to_ISO.ps1` (or simpler version `Extract_RVZ_to_ISO.bat`) script file from this repository (make click on the file in GitHub to view the code and copy it, and also you can find a button to download the raw file).

2. Open the script file in notepad and edit as you like the values of the Variables section at the very top of the script. The default values are:

```
$dolphinToolFullPath = "$PSScriptRoot\DolphinTool.exe"
$inputDirectoryPath = "$PSScriptRoot"
$outputDirectoryPath = ""
$recursiveSearch = $false
$overwriteConfirm = $true
$sendConvertedFilesToRecycleBin = $true
```
| Variable Name   |      Meaning      |
|----------|-------------|
| $dolphinToolFullPath |  The DolphinTool.exe full file path (it can be a relative path). |
| $inputDirectoryPath  |  The directory where to search for RVZ files to extract them to ISO format. |
| $outputDirectoryPath |  The directory where to write the extracted ISO files. |
| $recursiveSearch     |  Flag to indicate whether to perform a recursive search for RVZ files. |
| $overwriteConfirm    |  Flag to confirm overwrite for any existing ISO file in the output directory. |
| $sendConvertedFilesToRecycleBin  | Flag to send successfully converted RVZ files to recycle bin. If you set this value to $false, RVZ files will be kept. |

3. Run the script file, and wait until the conversion operation completes.

## 📸 Screenshots

![](/Images/Extract_RVZ_to_ISO.bat.png)

![](/Images/Extract_RVZ_to_ISO.ps1.png)

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

<br></br>
<p align="center"><img src="/Images/github_circle.png" height=100></p>
<p align="center">__________________</p>
<h3 align="center">Becoming my sponsor on Github:</h3>
<p align="center">You can show me your support by clicking <a href="https://github.com/sponsors/ElektroStudios/">here</a>, <br align="center">contributing any amount you prefer, and unlocking rewards!</br></p>
<br></br>

<p align="center"><img src="/Images/paypal_circle.png" height=100></p>
<p align="center">__________________</p>
<h3 align="center">Making a Paypal Donation:</h3>
<p align="center">You can donate to me any amount you like via Paypal by clicking <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=E4RQEV6YF5NZY">here</a>.</p>
<br></br>

<p align="center"><img src="/Images/envato_circle.png" height=100></p>
<p align="center">__________________</p>
<h3 align="center">Purchasing software of mine at Envato's Codecanyon marketplace:</h3>
<p align="center">If you are a .NET developer, you may want to explore '<b>DevCase Class Library for .NET</b>', <br align="center">a huge set of APIs that I have on sale. Check out the product by clicking <a href="https://codecanyon.net/item/elektrokit-class-library-for-net/19260282">here</a></br><br align="center"><i>It also contains all piece of reusable code that you can find across the source code of my open source works.</i></p>
<br></br>

<h2 align="center"><u>Your support means the world to me! Thank you for considering it!</u> 👍</h2>
