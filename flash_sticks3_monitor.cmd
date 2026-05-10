@echo off
setlocal

set "ROOT=%~dp0"
set "PROJECT=%ROOT%StackChan-official\remote\code"

cd /d "%PROJECT%"

where idf.py >nul 2>nul
if errorlevel 1 (
    if "%IDF_PATH%"=="" (
        echo idf.py was not found. Run this from an ESP-IDF Command Prompt.
        exit /b 1
    )
    if not exist "%IDF_PATH%\tools\idf.py" (
        echo %IDF_PATH%\tools\idf.py was not found.
        exit /b 1
    )
    python "%IDF_PATH%\tools\idf.py" -D IDF_TARGET=esp32s3 -D SDKCONFIG_DEFAULTS=sdkconfig.defaults reconfigure
    if errorlevel 1 exit /b %errorlevel%
    python "%IDF_PATH%\tools\idf.py" %* build flash monitor
) else (
    idf.py -D IDF_TARGET=esp32s3 -D SDKCONFIG_DEFAULTS=sdkconfig.defaults reconfigure
    if errorlevel 1 exit /b %errorlevel%
    idf.py %* build flash monitor
)
exit /b %errorlevel%
