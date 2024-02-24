@Echo OFF
FOR %%# IN (*.rvz) DO (
	ECho:Extracting "%%~nx#"...
	"DolphinTool.exe" convert --format=iso --input="%%~f#" --output="%%~n#.iso"
)
Pause
Exit /B 0