; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                         Text Functions                        ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

; https://www.autohotkey.com/boards/viewtopic.php?t=76052
enter_random_string(len) {
    symbols := "0123456789abcdefghijklmnopqrstuvwxyz"
    output  := ""
    loop, %len% {
        Random, r, 1, StrLen(symbols)
        output .= SubStr(symbols, r, 1)
    }
    Send, %output%
}
