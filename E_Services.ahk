
class Services {
    callAddress := 0x0000
    registeredHook := 0x0000
    registeredHotKeys := ExSet()

    register() {
        Suspend(false)
        this.registerWindowEvent()
    }

    unregister() {
        Suspend(true)
        this.unregisterWindowEvent()
    }

    /* Callback receives two args
        -> param1: process name
        -> param2: window uid
    */
    setWindowEventCallback(callback) {
        this.windCallback := callback
    }

    /* Callback receives two boolean args
        -> param1: indicates pin/unpin request
        -> param2: whether to pin the app as well
    */
    setHotKeyCallback(callback) {
        this.hkeyCallback := BypassThisRef.bind(callback) 
    }

    registerWindowEvent() {
        if (this.registeredHook)
            this.unregisterWindowEvent()
        this.callAddress := CallbackCreate(this.onActiveWindowChange.bind(this, this.windCallback),, 3)
        this.registeredHook := DllCall("SetWinEventHook", 
            "UInt", 0x3, "UInt", 0x3, "Ptr", 0, "Ptr", this.callAddress, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr"
        )
    }

    unregisterWindowEvent() {
        if (this.registeredHook and DllCall("UnhookWinEvent", "Ptr", this.registeredHook)) {
            if (this.callAddress)
                CallbackFree(this.callAddress)
        }
        this.callAddress := 0x0000
        this.registeredHook := 0x0000
    }

    setHotKeys(hotkeys)
    {
        try {
            for key in this.registeredHotKeys {
                HotKey(key, "Off")
            }
        }
        this.registeredHotKeys.clear()
        try {
            for id in APP_HOTKEY_IDS {
                pin := InStr(id, "pin") ? true : false
                program := InStr(id, "program") ? true : false
                options := (program ? "S0" : "S") . " On"
                HotKey(hotkeys[id], this.onHotkeyPress.bind(this, pin, program), options)
                this.registeredHotKeys.add(hotkeys[id])
            }
        } catch as e {
            HandleError(e)
        }
    }

    onHotkeyPress(pin, program, *) {
        this.hkeyCallback(pin, program)
    }

    onActiveWindowChange(callback, registeredHook, vEvent, hWnd)
    {
        try {
            process := ""
            Loop 100 {
                try {
                    process := GetWindowProcess(hWnd)
                } catch as e {
                    ; UWP apps takes up to 5 sec
                    if (e.what = "ControlGetHwnd") {
                        sleep 50
                        continue
                    }
                }
                if (process)
                    break
                sleep 10
            }
            callback(GetWindowProcess(hWnd), hWnd)
        }
    }
}
