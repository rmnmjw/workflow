wallpaper_set(path) {
    RegWrite, REG_SZ, HKEY_CURRENT_USER, % "Control Panel\Desktop", Wallpaper, %path%
    
    loop, 8 {
        RunWait, %A_WinDir%\System32\RUNDLL32.EXE user32.dll`,UpdatePerUserSystemParameters
        Sleep, 250
    }
}
