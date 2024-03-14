hibernate() {
    i := 0
    Loop {
        if (i >= 300) {
            return
        }
        d_CapsLock := GetKeyState("CapsLock", "P")
        d_Control := GetKeyState("Ctrl")
        d_Alt := GetKeyState("Alt")
        if (d_CapsLock || d_Control || d_Alt) {
            Sleep, 10
            i += 1
            Continue
        }
        break
    }
    Run % A_ScriptDir . "/exec/hibernate.ahk"
}
