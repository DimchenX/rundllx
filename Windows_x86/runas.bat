@echo off
if not "%~1"=="" (
echo start "" %* > "%temp%\temp.bat"
echo @del "%temp%\temp.bat" >> "%temp%\temp.bat"
echo.
rundllx shell32 ShellExecuteA 1 0 0 "P%temp%\temp.bat" Prunas 0 R
echo.
)
