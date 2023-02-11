; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                            Startup                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

SetTimer, restart_programs, -1
restart_programs() {
    Process, Close, AltDrag.exe
    ; Process, Close, RBTray.exe
    ; Process, Close, RetroBar.exe

    ; www.autohotkey.com/board/topic/33849-refreshtray/?p=410313
    DetectHiddenWindows, On
    ControlGetPos,,,w,h,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
    width:=w, hight:=h
    While % ((h:=h-5)>0 and w:=width){
        While % ((w:=w-5)>0){
            PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
        }
    }
    DetectHiddenWindows, Off

    ; Run, explorer.exe C:\dev\rbtray\x64\RBTray.exe

    EnvGet, OutputVar, LOCALAPPDATA
    Run, % OutputVar . "\..\Roaming\AltDrag\AltDrag.exe -multi"

    ; Run, explorer.exe C:\Program Files\RetroBar\RetroBar.exe
}
