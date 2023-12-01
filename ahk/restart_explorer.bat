@echo off
rem https://superuser.com/questions/1700083/how-to-restart-explorer-without-losing-open-windows

setlocal enabledelayedexpansion

powershell  @^(^(New-Object -com shell.application^).Windows^(^)^).Document.Folder.Self.Path >> prevfolderpaths.txt

taskkill /im explorer.exe /f

start explorer.exe

FOR /F "tokens=*" %%f IN (prevfolderpaths.txt) DO (

set "var=%%f"
set "firstletters=!var:~0,2!"

IF "!firstletters!" == "::" ( start /min shell:%%~f ) ELSE ( start /min "" "%%~f" )

)

del "prevfolderpaths.txt"




rem powershell $open_folders = @((New-Object -com shell.application).Windows()).Document.Folder.Self.Path; Stop-Process -Name explorer -Force;  foreach ($element in $open_folders){Invoke-Item $($element)}