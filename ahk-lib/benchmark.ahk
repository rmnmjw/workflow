; #######################
; #      BENCHMARK      #
; #######################
Critical, On
i := 0
ROUNDS := 10000
START := A_TickCount
while true {
    get_disk_space("C:\")
    
    i++
    if (i > ROUNDS) {
        break
    }
}
total := A_TickCount - START
one := total / ROUNDS
MsgBox,
(
    DONE.
    Total:     %total% ms
    One:      %one% ms
    Rounds: %ROUNDS%
)
Critical, Off
