@Echo OFF
FOR %%# IN (*.iso) DO (
	ECho:Converting "%%~nx#"...
	ECho:[Compression=lzma2, Compression Level=9, Block Size=32 MB]
	"DolphinTool.exe" convert --format=rvz --input="%%~f#" --output="%%~n#.rvz" ^
	                          --block_size=33554432 --compression=lzma2 --compression_level=9
)
Pause
Exit /B 0