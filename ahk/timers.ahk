; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                             Timers                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

SetTimer, close_sublime_nag_windows, 250
close_sublime_nag_windows() { 
    ControlClick, Abbrechen, This is an unregistered copy
}
