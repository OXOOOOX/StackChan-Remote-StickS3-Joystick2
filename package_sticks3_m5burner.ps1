param(
    [string]$Output = "StackChan-RemoteControl-StickS3-Joystick2_0x0.bin",
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$script = Join-Path $PSScriptRoot "StackChan-official\remote\code\package_sticks3_m5burner.ps1"
$outputPath = Join-Path $PSScriptRoot $Output

if ($SkipBuild) {
    & $script -Output $outputPath -SkipBuild
}
else {
    & $script -Output $outputPath
}
