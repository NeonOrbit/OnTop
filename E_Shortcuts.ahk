/*
 * Copyright (C) 2023 NeonOrbit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

HKGUI_ENTRIES := APP_HOTKEY_IDS
HKGUI_ELEMENTS := Map(
    ID_PIN_WINDOWS, "Pin Window:",
    ID_CLR_WINDOWS, "Unpin Window:",
    ID_PIN_PROGRAM, "Pin Program:",
    ID_CLR_PROGRAM, "Unpin Program:"
)

IsWinKeyId(id) => InStr(id, "_wk")
IsHotKeyId(id) => InStr(id, "_hk")
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
            idWinKey := ToWinKeyId(id)
            idHotKey := ToHotKeyId(id)
            this.mainGui.add("Text", "xm w100", HKGUI_ELEMENTS[id])
            this.controls[idWinKey] := this.mainGui.add("CheckBox", "yp h20 Center v" . idWinKey, "Win  +")
            this.controls[idHotKey] := this.mainGui.add("Hotkey", "yp h20 v" . idHotKey)
            this.controls[idWinKey].onEvent("Click", this.eventHandler)
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
                if (this.controls.has(gc.name) and IsWinKeyId(gc.name)) {
                    cWinKey := this.controls[gc.name]
                    cHotKey := this.controls[ToHotKeyId(gc.name)]
                    cHotKey.opt(cWinKey.value ? "-Limit" : "Limit1")
                    if (!cWinKey.value) {
                        cHotKey.value := ""
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
                this.controls[ToWinKeyId(key)].value := true
                value := StrReplace(value, "#")
            } else {
                limit := "Limit1"
            }
            cHotKey := this.controls[ToHotKeyId(key)]
            cHotKey.value := value
            cHotKey.opt(limit)
        }
    }

    onSave() {
        dup := ExSet()
        hotkeys := Map()
        this.mainGui.opt("+OwnDialogs")
        for key in HKGUI_ENTRIES {
            cHotKey := this.controls[ToHotKeyId(key)]
            if (cHotKey.value) {
                result := this.controls[ToWinKeyId(key)].value ? "#" : ""
                result .= cHotKey.value
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
