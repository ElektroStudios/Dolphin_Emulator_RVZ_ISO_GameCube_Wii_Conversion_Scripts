# RVZ <> ISO Utility Conversion Script Files for [Dolphin Emulator](https://dolphin-emu.org) - Change Log 📋

## v1.3 *(current)* 🆕
README.md and script files have been modified to warn users about possible emulation issues when using larger block sizes than 128 KB.
Minor aesthetic changes in the script files.

## v1.2 🔄
#### 🌟 Improvements for PowerShell script files:
 - Added new setting "$outputDirectoryPath" in the "Script Settings" block of the script files, to let the user define the output directory path for conversion and extraction operations.
 - Added basic error handling for creating the output directory.
 - Improved the block size value representation in the settings menu.
 - Improved script commentary lines for the "Script Settings" block.
 - Improved error information when a conversion or extraction operation fails.
 - Now the script will warn the user if no ISO/RVZ files were found within the specified input directory path.

#### 🌟 Improvements for Batch-Script files:
 - Batch-script files have been reworked from scratch, implementing many of the features mentioned above for the PowerShell script files.

## v1.1 🔄
Still in version 1.0, no changes were made, I just updated the description text shown when running the PowerShell scripts to include a Wii mention, clarifying this way that the scripts will work for Wii ISO files too.

## v1.0 🔄
Initial Release.