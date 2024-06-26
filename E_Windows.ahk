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

EXPLORER_PROCESS := "explorer.exe"
UWP_APPS_PROCESS := "ApplicationFrameHost.exe"
UWP_APPS_CONTROL := "Windows.UI.Core.CoreWindow1"
EXPLORER_VALID_CLASSES := "^(CabinetWClass|#32770)$"
INVALID_WINDOW_CLASSES := "^(Windows.UI.Core.CoreWindow|Default IME)$"

IsValidWindow(process, uid)
{
    try {
        title := uid ? WinGetTitle("ahk_id " . uid) : ""
        if (process and title and !(process = A_ScriptName)) {
            cls := WinGetClass("ahk_id " . uid)
            if !(cls ~= INVALID_WINDOW_CLASSES) {
                if ((process != EXPLORER_PROCESS) or (cls ~= EXPLORER_VALID_CLASSES)) {
                    return true
                }
            }
        }
    }
    return false
}

ToggleAlwaysOnTop(uid, state)
{
    Loop 3 {  ; AOT flag sometimes fails to set.
        style := WinGetExStyle("ahk_id " . uid)
        if (((style & 0x8) && true) = state)
            break
        sleep ((A_Index - 1) * 2)
        WinSetAlwaysOnTop(state, "ahk_id " . uid)
    }
}

GetWindowProcess(uid) {
    process := WinGetProcessName("ahk_id " . uid)
    if (process = UWP_APPS_PROCESS) {
        process := ""
        hwnd := ControlGetHwnd(UWP_APPS_CONTROL, "ahk_id " . uid)
        if (hwnd) {
            process := WinGetProcessName("ahk_id " . hwnd)
        }
    }
    return process
}

GetWindowDetails(uid) {
    try {
        return WinGetProcessName("ahk_id " . uid) . " (" . uid . ")"
    } catch as e {
        return uid
    }
}

UpdateWindowState(uid := "", process := "", state := true)
{
    list := ""
    if (process) {
        list := WinGetList("ahk_exe " . process)
    }
    if (list) {
        index := list.length + 1
        While(--index) {
            id := list[index]
            if uid != id and IsValidWindow(process, id) {
                try {
                    ToggleAlwaysOnTop(id, state)
                }
            }
        }
    }
    if (uid) {
        try {
            parent := DllCall("GetParent", "UInt", uid)
            if (parent and IsValidWindow(WinGetProcessName("ahk_id " . parent), parent)) {
                ToggleAlwaysOnTop(parent, state)
            }
        }
        ToggleAlwaysOnTop(uid, state)
    }
}
