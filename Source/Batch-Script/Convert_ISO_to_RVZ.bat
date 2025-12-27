@ECHO OFF
REM CHCP 1252 1>NULL
SET "ScriptVersion=1.3"
SET "WindowTitle=Dolphin's ISO to RVZ converter v%ScriptVersion%"
TITLE %WindowTitle%

:: SETTINGS
SET "SourceDirectoryPath=%~dp0"
SET "OutputDirectoryPath=%SourceDirectoryPath%"
SET "DoRecursiveRVZSearch=False" & REM True or False

SET "CompressionFormat=lzma2"
SET /A "CompressionLevel=9"
SET /A "BlockSize=33554432" & REM Value In bytes.

REM
REM Avalable Compression Formats | Compression Level min ~ max range
REM -----------------------------|----------------------------------
REM            bzip, lzma, lzma2 | 1 ~ 9
REM                         zstd | 1 ~ 22

REM Default Dolphin values:
REM -----------------------
REM CompressionFormat: zstd
REM CompressionLevel: 5
REM BlockSize: 128 KB (131072 bytes)

:: ===================================================

:: WELCOME MESSAGE
ECHO: %WindowTitle% ^| By ElektroStudios (https://git.new/WuQUx1w)
ECHO:__________________________________________________________________________________
ECHO+
ECHO: SCRIPT SETTINGS
ECHO: ---------------
ECHO+
ECHO: Source Directory Path: %SourceDirectoryPath%
ECHO: Output Directory Path: %OutputDirectoryPath%
ECHO+
ECHO: Recursive RVZ Search?: %DoRecursiveRVZSearch%
ECHO+
ECHO: Compression Format: %CompressionFormat%
ECHO:  Compression Level: %CompressionLevel%
SETLOCAL ENABLEDELAYEDEXPANSION
CALL :FormatBlockSize %BlockSize% BlockSizeFormatted
ECHO:         Block Size: %BlockSize% Bytes (!BlockSizeFormatted!)
ENDLOCAL
ECHO+
ECHO:==================================================================================
ECHO:Please note that the settings above are hard-coded in the script file.
ECHO:This means you must edit the script manually (for example, using Notepad)
ECHO:to change any settings. The values are documented, so it is straightforward.
ECHO+
ECHO:Also, please note that using block size values larger than 128 KB (131072 bytes)
ECHO:may cause emulation issues depending on the capabilities of the machine you use
ECHO:to emulate the ROMs. On a PC, a block size of 32 MB (33554432 bytes) should be
ECHO:generally safe to achieve optimal compression without any negative effects.
ECHO:However, the script files are provided "as-is", so use them at your own risk.
ECHO:==================================================================================
ECHO.
CHOICE /C YN /M "Press \"Y\" to continue with these settings, or \"N\" to exit."
IF %ERRORLEVEL% EQU 2 (EXIT)
CLS

:: MAIN PROCEDURE
MKDIR "%OutputDirectoryPath%" 1>NUL 2>&1 || (
	IF NOT EXIST "%OutputDirectoryPath%" (
		ECHO:Error trying to create output directory.
		PAUSE
		EXIt /B 1
	)
)

SET "RecursiveParams=/R "%SourceDirectoryPath%" %%# IN ("*.iso")"
SET "NonRecursiveParams=%%# IN ("%SourceDirectoryPath%\*.iso")"

If /I "%DoRecursiveRVZSearch%" EQU "True" (
	FOR %RecursiveParams% DO (
		ECHO:Converting "%%~fx#"...
		"DolphinTool.exe" convert --format=rvz --input="%%~f#" --output="%OutputDirectoryPath%\%%~n#.rvz" ^
		                          --block_size=%BlockSize% --compression=%CompressionFormat% --compression_level=%CompressionLevel%
	)

) ELSE (
	FOR %NonRecursiveParams% DO (
		ECHO:Converting "%%~fx#"...
		"DolphinTool.exe" convert --format=rvz --input="%%~f#" --output="%OutputDirectoryPath%\%%~n#.rvz" ^
		                          --block_size=%BlockSize% --compression=%CompressionFormat% --compression_level=%CompressionLevel%
	)

)

:: END
ECHO+
ECHO: Operation Completed!
ECHO+
PAUSE
EXIT /B 0

:FormatBlockSize
SET "size=%~1"
IF "!size!"=="" SET "size=0"
REM Bytes
IF !size! LSS 1024 (
    SET "%2=!size! Bytes"
    GOTO :EOF
)
REM Kilobytes
IF !size! LSS 1048576 (
    SET /A sizeKB = size / 1024
    SET /A remainder = size - sizeKB * 1024
    SET /A rem = remainder * 10 / 1024
    SET "%2=!sizeKB!.!rem! KB"
    GOTO :EOF
)
REM Megabytes
SET /A sizeMB = size / 1048576
SET /A remainder = size - sizeMB * 1048576
SET /A rem = remainder * 10 / 1048576
SET "%2=!sizeMB!.!rem! MB"
GOTO :EOF