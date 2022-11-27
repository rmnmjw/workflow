; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                            Startup                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

startup_restart_alt_drag() {
    Process, Close, AltDrag.exe
    EnvGet, OutputVar, LOCALAPPDATA
    Run, % OutputVar . "\..\Roaming\AltDrag\AltDrag.exe -multi"
}

startup_restart_rbtray() {
    Process, Close, RBTray.exe
    Run, explorer.exe C:\dev\rbtray\x64\RBTray.exe
}

startup_refresh_taskbar_icons() {
    ; www.autohotkey.com/board/topic/33849-refreshtray/?p=410313
    tmp_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows, On
    ControlGetPos,,,w,h,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
    width:=w, hight:=h
    While % ((h:=h-5)>0 and w:=width){
        While % ((w:=w-5)>0){
            PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
        }
    }
    DetectHiddenWindows, %A_DetectHiddenWindows%
}

startup_restart_alt_drag()
startup_restart_rbtray()
startup_refresh_taskbar_icons()
