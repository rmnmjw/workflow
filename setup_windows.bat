@echo off

:: https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------  

:: uninstall ...
winget uninstall "Windows-Sprachrekorder"
winget uninstall "Xbox Game Bar Plugin"
winget uninstall "Xbox Game Bar"
winget uninstall "Xbox Game Speech Window"
winget uninstall "Xbox Game Speech Window"
winget uninstall "Xbox Identity Provider"
winget uninstall "Skype"
winget uninstall "Smartphone-Link"
winget uninstall "Spotify"
winget uninstall "WhatsApp"


:: install ...
winget install --source winget --scope machine python3

winget install -e --id AltSnap.AltSnap
winget install -e --id Anki.Anki
winget install -e --id Brave.Brave
winget install -e --id Docker.DockerDesktop
winget install -e --id dotPDNLLC.paintdotnet
winget install -e --id FontForge.FontForge
winget install -e --id Git.Git
winget install -e --id Gyan.FFmpeg
winget install -e --id Lexikos.AutoHotkey
winget install -e --id Microsoft.Office
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id MiKTeX.MiKTeX
winget install -e --id Mozilla.Firefox
winget install -e --id Mozilla.Thunderbird
winget install -e --id namazso.OpenHashTab
winget install -e --id nim.nim
winget install -e --id OBSProject.OBSStudio
winget install -e --id OO-Software.ShutUp10
winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id SublimeHQ.SublimeMerge
winget install -e --id SublimeHQ.SublimeText.4
winget install -e --id TeamSpeakSystems.TeamSpeakClient
winget install -e --id Valve.Steam
winget install -e --id VideoLAN.VLC
winget install -e --id voidtools.Everything.Alpha
winget install -e --id Winamp.Winamp
winget install -e --id yt-dlp.yt-dlp

winget install Monitorian -s msstore

pause 