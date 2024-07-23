#include _base.ahk

if (desktop_current == 1) {
    if (ctrl_down) {
        path := A_AppData . "\..\Local\Microsoft\WindowsApps\Spotify.exe"
        window_toggle("ahk_class Chrome_WidgetWin_1 ahk_exe Spotify.exe", path)
    } else {
        window_toggle("ahk_exe sublime_merge.exe")
    }
}
