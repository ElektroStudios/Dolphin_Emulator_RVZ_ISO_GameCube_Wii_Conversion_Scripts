@ECHO OFF

:: Script Version 1.2

SET "InputDirectoryPath=%~dp0"
SET "OutputDirectoryPath=%InputDirectoryPath%"
SET "DoRecursiveRVZSearch=False" & REM True or False

ECHO: Script Settings:
ECHO: ----------------
ECHO:
ECHO: - Input Directory Path...: %InputDirectoryPath%
ECHO: - Output Directory Path..: %OutputDirectoryPath%
ECHO: - Do Recursive ISO Search: %DoRecursiveRVZSearch%
ECHO+
PAUSE
CLS

MKDIR "%OutputDirectoryPath%" 1>NUL 2>&1 || (
	IF NOT EXIST "%OutputDirectoryPath%" (
		ECHO:Error trying to create output directory.
		PAUSE
		EXIt /B 1
	)
)

SET "RecursiveParams=/R "%InputDirectoryPath%" %%# IN ("*.rvz")"
SET "NonRecursiveParams=%%# IN ("%InputDirectoryPath%\*.rvz")"

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

ECHO+
ECHO: Operation Completed!
ECHO+
PAUSE
EXIT /B 0