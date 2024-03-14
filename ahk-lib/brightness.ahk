brightness_set(up) {
    Critical, On
    Run, Monitorian.exe /set %up%
    Sleep, 100
    Critical, Off
}
