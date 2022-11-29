; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                           Mouse Find                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

mouse_find_size := 32
mouse_find_large() {
    global mouse_find_size
    SetTimer, mouse_find_small, Delete
    SetTimer, mouse_find_small, 1000
    while (mouse_find_size < 256) {
        mouse_find_size += 16
        
        DllCall("SystemParametersInfo", "Int", 0x2029, "Int", 0, "Ptr", mouse_find_size, "Int", 0x01) ; https://www.autohotkey.com/boards/viewtopic.php?t=100911
        Sleep, 1
    }
}

mouse_find_small() {
    global mouse_find_size, mouse_find_target
    while (mouse_find_size > 32) {
        mouse_find_size -= 16
        DllCall("SystemParametersInfo", "Int", 0x2029, "Int", 0, "Ptr", mouse_find_size, "Int", 0x01) ; https://www.autohotkey.com/boards/viewtopic.php?t=100911
        Sleep, 1
    }
}
mouse_find_array_default(len) {
    pos := []
    loop, %len% {
        pos.Push({x:0, y:0})
    }
    return pos
}
mouse_find_pos_default() {
    MouseGetPos, mx, my
    return {x: mx, y: my}
}
SetTimer, mouse_find_timer, 100
mouse_find_timer() {
    global mouse_find_target
    static LEN := 7
    static positions := mouse_find_array_default(LEN)
    static index := 1, indexLast := LEN
    
    static xLast := mouse_find_pos_default().x, yLast := mouse_find_pos_default().y

    MouseGetPos, mx, my
    positions.InsertAt(indexLast, {x:mx-xLast, y:my-yLast})
    xLast := mx, yLast := my
    
    ; Shake detection ported from
    ; https://github.com/microsoft/PowerToys/blob/main/src/modules/MouseUtils/FindMyMouse/FindMyMouse.cpp : SuperSonar<D>::DetectShake()
    distanceTravelled := 0
    currentX := 0, minX := 0, maxX := 0
    currentY := 0, minY := 0, maxY := 0
    
    times := LEN+1-index
    Loop, %times% {
        real_index := index+A_Index-1
        p := positions[real_index]
        ; 
        currentX += p.x
        currentY += p.y
        distanceTravelled += Sqrt(p.x * p.x + p.y * p.y)
        minX := Min(currentX, minX)
        maxX := Max(currentX, maxX)
        minY := Min(currentY, minY)
        maxY := Max(currentY, maxY)
    }
    times := index-1
    Loop, %times% {
        p := positions[A_Index]
        ; 
        currentX += p.x
        currentY += p.y
        distanceTravelled += Sqrt(p.x * p.x + p.y * p.y)
        minX := Min(currentX, minX)
        maxX := Max(currentX, maxX)
        minY := Min(currentY, minY)
        maxY := Max(currentY, maxY)
    }
    
    if (distanceTravelled < 800) {
        return
    }
    
    rectangleWidth := maxX - minX
    rectangleHeight := maxY - minY
    diagonal := Sqrt(rectangleWidth * rectangleWidth + rectangleHeight * rectangleHeight)

    if (diagonal > 0 && distanceTravelled / diagonal > 2.5) {
        mouse_find_target := 256
        SetTimer, mouse_find_large, -1
    }
    
    indexLast := index
    index += 1
    if (index > LEN) {
        index := 1
    }
}

