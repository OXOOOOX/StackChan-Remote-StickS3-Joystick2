@echo off
setlocal

set "ROOT=%~dp0"
set "PROJECT=%ROOT%StackChan-official\remote\code"

cd /d "%PROJECT%"

if not exist "sdkconfig.defaults" (
    echo sdkconfig.defaults is missing from %PROJECT%
    exit /b 1
)

if not exist "partitions_sticks3.csv" (
    echo partitions_sticks3.csv is missing from %PROJECT%
    exit /b 1
)

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
    set "IDF_CMD=python"
    set "IDF_SCRIPT=%IDF_PATH%\tools\idf.py"
) else (
    set "IDF_CMD=idf.py"
    set "IDF_SCRIPT="
)

if defined IDF_SCRIPT (
    %IDF_CMD% "%IDF_SCRIPT%" -D IDF_TARGET=esp32s3 -D SDKCONFIG_DEFAULTS=sdkconfig.defaults reconfigure
) else (
    %IDF_CMD% -D IDF_TARGET=esp32s3 -D SDKCONFIG_DEFAULTS=sdkconfig.defaults reconfigure
)
if errorlevel 1 exit /b %errorlevel%

if defined IDF_SCRIPT (
    %IDF_CMD% "%IDF_SCRIPT%" %* build flash
) else (
    %IDF_CMD% %* build flash
)
exit /b %errorlevel%
