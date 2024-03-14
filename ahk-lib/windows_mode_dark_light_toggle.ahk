#include ../ahk-lib/wallpaper.ahk

; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62701
windows_mode_dark_light_toggle() {
    RegRead, appMode, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
    Sleep, 500
    RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme, % !appMode
    Sleep, 500

    if (appMode)
        wallpaper_set("C:\Users\rmn\Pictures\wallpaper\wallpaper_dark.jpg")
    else
        wallpaper_set("C:\Users\rmn\Pictures\wallpaper\wallpaper_light.jpg")
}
