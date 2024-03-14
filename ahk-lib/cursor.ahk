; https://www.autohotkey.com/board/topic/8432-script-for-changing-mouse-pointer-speed/

cursor_speed_get() {
    DllCall("SystemParametersInfo", UInt, 0x70, UInt, 0, UIntP, result, UInt, 0) 
    return result
}

cursor_speed_set(speed:=6) {
    speed := Floor(speed)
    DllCall("SystemParametersInfo", UInt, 0x71, UInt, 0, UInt, speed, UInt, 0) 
}
