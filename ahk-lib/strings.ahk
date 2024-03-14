; https://www.autohotkey.com/boards/viewtopic.php?t=76052
strings_get_random_chars_of(chars, len) {
    output  := ""
    loop, %len% {
        Random, r, 1, StrLen(chars)
        output .= SubStr(chars, r, 1)
    }
    return output
}

strings_enter_random_text(len) {
    output  := strings_get_random_chars_of("0123456789abcdefghijklmnopqrstuvwxyz", len)
    Send, %output%
}

strings_enter_random_number(len) {
    output := strings_get_random_chars_of("0123456789", len)
    Send, %output%
}
