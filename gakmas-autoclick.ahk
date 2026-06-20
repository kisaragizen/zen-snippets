if not A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

global autoClick := false
global clickInterval := 150
global tipTimer := 0
global paused := false

AdjustInterval(delta) {
    global clickInterval, tipTimer, autoClick
    clickInterval := Max(50, Min(3000, clickInterval + delta))
    if autoClick
        SetTimer(Click, clickInterval)
    ToolTip("频率: " clickInterval " ms")
    if tipTimer
        SetTimer(tipTimer, 0)
    tipTimer := SetTimer(() => (ToolTip(), tipTimer := 0), -1000)
}

ToggleAutoClick() {
    global autoClick, clickInterval
    autoClick := !autoClick
    if autoClick {
        SetTimer(Click, clickInterval)
        SoundBeep(800, 150)
    } else {
        SetTimer(Click, 0)
        SoundBeep(400, 150)
    }
}

$RButton:: {
    global paused, autoClick, clickInterval
    if GetKeyState("LButton", "P")
        return
    if !KeyWait("RButton", "T1") {
        if paused {
            paused := false
            SoundBeep(600, 200)
        } else {
            paused := true
            if autoClick {
                autoClick := false
                SetTimer(Click, 0)
            }
            SoundBeep(300, 200)
        }
    } else {
        if !paused {
            ToggleAutoClick()
        } else {
            Send "{RButton}"
        }
    }
}

~LButton & RButton:: {
    start := A_TickCount
    while (A_TickCount - start < 1000) {
        if !GetKeyState("LButton", "P") || !GetKeyState("RButton", "P")
            return
        Sleep 10
    }
    SoundBeep(1000, 150)
    Sleep 150
    SoundBeep(1000, 150)
    ExitApp
}

#HotIf autoClick
WheelUp::AdjustInterval(-50)
WheelDown::AdjustInterval(50)
#HotIf
