@ECHO OFF

:: Script Version 1.2

SET "InputDirectoryPath=%~dp0"
SET "OutputDirectoryPath=%InputDirectoryPath%"
SET "DoRecursiveRVZSearch=False" & REM True or False

SET    "CompressionFormat=lzma2" & REM Available values: none, zstd, bzip, lzma, lzma2
SET /A "CompressionLevel=9" & REM Available values: [zstd: 1~22], [bzip, lzma, lzma2: 1~9]
SET /A "BlockSize=33554432" & REM Value In bytes.

ECHO: Script Settings:
ECHO: ----------------
ECHO:
ECHO: - Input Directory Path...: %InputDirectoryPath%
ECHO: - Output Directory Path..: %OutputDirectoryPath%
ECHO: - Do Recursive RVZ Search: %DoRecursiveRVZSearch%
ECHO:
ECHO: - Compression Format: %CompressionFormat%
ECHO: - Compression Level.: %CompressionLevel%
ECHO: - Block Size........: %BlockSize% Bytes
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

SET "RecursiveParams=/R "%InputDirectoryPath%" %%# IN ("*.iso")"
SET "NonRecursiveParams=%%# IN ("%InputDirectoryPath%\*.iso")"

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

ECHO+
ECHO: Operation Completed!
ECHO+
PAUSE
EXIT /B 0