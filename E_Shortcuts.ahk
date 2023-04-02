
HKGUI_ENTRIES := APP_HOTKEY_IDS
HKGUI_ELEMENTS := Map(
    ID_PIN_WINDOWS, "Pin Window:",
    ID_CLR_WINDOWS, "Unpin Window:",
    ID_PIN_PROGRAM, "Pin Program:",
    ID_CLR_PROGRAM, "Unpin Program:"
)

WinKeyId(id) => id . "_wk"
HotKeyId(id) => id . "_hk"
ToWinKeyId(id) => StrReplace(id, "_hk") . "_wk"
ToHotKeyId(id) => StrReplace(id, "_wk") . "_hk"

class Shortcuts {
    controls := Map()
    eventHandler := this.handleEvents.bind(this)

    ; Callback receives a map containing new hotkeys
    __new(callback) {
        this.controls.clear()
        this.callback := BypassThisRef.bind(callback) 
        this.mainGui := Gui("+AlwaysOnTop")
        for id in HKGUI_ENTRIES {
            this.mainGui.add("Text", "xm w100", HKGUI_ELEMENTS[id])
            this.controls[WinKeyId(id)] := this.mainGui.add("CheckBox", "yp h20 Center v" . WinKeyId(id), "Win  +")
            this.controls[HotKeyId(id)] := this.mainGui.add("Hotkey", "yp h20 v" . HotKeyId(id))
            this.controls[WinKeyId(id)].onEvent("Click", this.eventHandler)
        }
        this.mainGui.add("Button", "x20 vDefault", "Default").onEvent("Click", this.eventHandler)
        this.mainGui.add("Button", "yp vSave",  "Save Shortcuts").onEvent("Click", this.eventHandler)
        this.mainGui.add("Button", "yp vCancel",  "Cancel").onEvent("Click", this.eventHandler)
    }

    handleEvents(gc, *)
    {
        switch gc.name {
            case "Default":
                this.update(APP_DEFAULT_HOTKEYS)
            case "Save":
                this.onSave()
            case "Cancel":
                this.mainGui.destroy()
            default:
                if (this.controls.has(gc.name)) {
                    cWin := this.controls[gc.name]
                    cHKey := this.controls[ToHotKeyId(gc.name)]
                    cHKey.opt(cWin.value ? "-Limit" : "Limit1")
                    if (!cWin.value) {
                        cHKey.value := ""
                    }
                }
        }
    }

    show(values) {
        this.update(values)
        this.mainGui.show()
    }

    update(values) {
        for key in HKGUI_ENTRIES {
            limit := ""
            value := values[key]
            if InStr(value, "#") {
                limit := "-Limit"
                this.controls[WinKeyId(key)].value := true
                value := StrReplace(value, "#")
            } else {
                limit := "Limit1"
            }
            this.controls[HotKeyId(key)].value := value
            this.controls[HotKeyId(key)].opt(limit)
        }
    }

    onSave() {
        dup := ExSet()
        hotkeys := Map()
        this.mainGui.opt("+OwnDialogs")
        for key in HKGUI_ENTRIES {
            hkVal := this.controls[HotKeyId(key)].value
            winVal := this.controls[WinKeyId(key)].value
            if (this.controls[HotKeyId(key)].value) {
                result := this.controls[WinKeyId(key)].value ? "#" : ""
                result .= this.controls[HotKeyId(key)].value
            } else {
                result := APP_DEFAULT_HOTKEYS[key]
            }
            if (dup.has(result)) {
                this.update(APP_DEFAULT_HOTKEYS)
                MsgBox("Failed: duplicate shortcuts!",, 0x30)
                return
            }
            dup.add(result)
            hotkeys[key] := result
        }
        this.update(hotkeys)
        this.callback(hotkeys)
        MsgBox("Saved Successfully")
    }
}
