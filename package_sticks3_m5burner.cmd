@echo off
setlocal

set "ROOT=%~dp0"
set "OUTPUT=%ROOT%StackChan-RemoteControl-StickS3-Joystick2_0x0.bin"
set "SCRIPT=%ROOT%StackChan-official\remote\code\package_sticks3_m5burner.cmd"

if not "%~1"=="" (
    if /I "%~1"=="--skip-build" (
        call "%SCRIPT%" --skip-build
        exit /b %errorlevel%
    ) else (
        set "OUTPUT=%~1"
    )
)

call "%SCRIPT%" "%OUTPUT%"
exit /b %errorlevel%
