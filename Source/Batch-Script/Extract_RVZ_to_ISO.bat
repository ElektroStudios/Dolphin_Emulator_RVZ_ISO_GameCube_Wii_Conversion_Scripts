@ECHO OFF
REM CHCP 1252 1>NULL
SET "ScriptVersion=1.3"
SET "WindowTitle=Dolphin's RVZ to ISO extractor v%ScriptVersion%"
TITLE %WindowTitle%

:: SETTINGS
SET "SourceDirectoryPath=%~dp0"
SET "OutputDirectoryPath=%SourceDirectoryPath%"
SET "DoRecursiveRVZSearch=False" & REM True or False
:: ===================================================

:: WELCOME MESSAGE
ECHO: %WindowTitle% ^| By ElektroStudios (https://git.new/WuQUx1w)
ECHO:__________________________________________________________________________________
ECHO+
ECHO: SCRIPT SETTINGS
ECHO: ---------------
ECHO+
ECHO:Source Directory Path: %SourceDirectoryPath%
ECHO:Output Directory Path: %OutputDirectoryPath%
ECHO+
ECHO:Recursive ISO Search?: %DoRecursiveRVZSearch%
ECHO+
ECHO:----------------------------------------------------------------------------------
ECHO+
CHOICE /C YN /M "Press \"Y\" to continue with these settings, or \"N\" to exit."
IF %ERRORLEVEL% EQU 2 (EXIT)
PAUSE
CLS

:: MAIN PROCEDURE
MKDIR "%OutputDirectoryPath%" 1>NUL 2>&1 || (
	IF NOT EXIST "%OutputDirectoryPath%" (
		ECHO:Error trying to create output directory.
		PAUSE
		EXIt /B 1
	)
)

SET "RecursiveParams=/R "%SourceDirectoryPath%" %%# IN ("*.rvz")"
SET "NonRecursiveParams=%%# IN ("%SourceDirectoryPath%\*.rvz")"

If /I "%DoRecursiveRVZSearch%" EQU "True" (
	FOR %RecursiveParams% DO (
		ECHO:Converting "%%~fx#"...
		"DolphinTool.exe" convert --format=iso --input="%%~f#" --output="%OutputDirectoryPath%\%%~n#.iso"
	)

) ELSE (
	FOR %NonRecursiveParams% DO (
		ECHO:Converting "%%~fx#"...
		"DolphinTool.exe" convert --format=iso --input="%%~f#" --output="%OutputDirectoryPath%\%%~n#.iso"
	)

)

:: END
ECHO+
ECHO: Operation Completed!
ECHO+
PAUSE
EXIT /B 0