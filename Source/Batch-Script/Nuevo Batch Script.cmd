@Echo Off & Title Batch-script template by Elektro
(CHCP 1252)1>Nul
SetLocal EnableDelayedExpansion

:: # # # # # # # # # # # # #
:: # Variable declarations #
:: # # # # # # # # # # # # #
Set    "var=value"
Set /A "var=0"
Set /P "var=Input"

:: # # # # # # # # # #
:: # IF conditionals #
:: # # # # # # # # # #
If /I "%string%" EQU "value" (command) & REM Equals to...
If /I "%string%" NEQ "value" (command) & REM Non-Equals to...

If %number% EQU value (command) & REM Equals to...
If %number% NEQ value (command) & REM Non-Equals to...
If %number% LSS value (command) & REM Less than...
If %number% LEQ value (command) & REM Less than or Equals to...
If %number% GTR value (command) & REM Greater than...
If %number% GEQ value (command) & REM Greater than or Equals to...

:: # # # # #
:: # Loops #
:: # # # # #
REM FOR
FOR %%# IN (expression) DO (command)

REM FOR-Command Results
FOR /F "Tokens=* Delims=" %%# IN ('command') DO (
	Echo %%~#
)

REM FOR-File contents
FOR /F "UseBackQ Tokens=* Delims=" %%# IN ("TextFile.txt") DO (
	Echo %%~#
)

REM FOR-Range
FOR /L %%# IN (0, 1, 10) DO (
	Echo %%#
)

REM FOR-Files
FOR %%# IN ("*.*") DO (
	Echo %%~#
)

REM FOR-Files Recursive
FOR /R "%CD%" %%# IN ("*.*") DO (
	Echo %%~#
)

REM FOR-Directories
FOR /D %%# IN ("*") DO (
	Echo %%~#
)

REM FOR-Directories Recursive
FOR /D /R "%CD%" %%# IN ("*") DO (
	Echo %%~#
)

:: # # # # # # # #
:: # Hello World #
:: # # # # # # # #
Echo:Hello World!

:: # # # # # # # # # # # # # #
:: # Application Termination #
:: # # # # # # # # # # # # # #
Pause
Exit /B 0
