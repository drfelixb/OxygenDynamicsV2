@echo off
setlocal
cd /d "%~dp0"

set "COMMIT_MESSAGE="
set /p "COMMIT_MESSAGE=Describe this GitHub update: "
if not defined COMMIT_MESSAGE (
    echo No commit message supplied. Nothing was changed.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Update-GitHub.ps1" -Message "%COMMIT_MESSAGE%"
set "UPDATE_EXIT_CODE=%ERRORLEVEL%"

if not "%UPDATE_EXIT_CODE%"=="0" (
    echo.
    echo GitHub update stopped with an error. Review the message above.
)

pause
exit /b %UPDATE_EXIT_CODE%
