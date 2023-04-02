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
EXPLORER_VALID_CLASS_01 := "#32770"
EXPLORER_VALID_CLASS_02 := "CabinetWClass"

IsValidWindow(process, uid)
{
    title := WinGetTitle("ahk_id " . uid)
    if (process and title ~= ".*\S.*" and !(process = A_ScriptName)) {
        if (process = EXPLORER_PROCESS) {
            class := WinGetClass("ahk_id " . uid)
            if !(class = EXPLORER_VALID_CLASS_01 or 
                 class = EXPLORER_VALID_CLASS_02) {
                return false
            }
        }
        return true
    }
    return false
}

ToggleAlwaysOnTop(uid, state)
{
    Loop 3 {
        style := WinGetExStyle("ahk_id " . uid)
        if (((style & 0x8) && true) = state)
            break
        WinSetAlwaysOnTop(state, "ahk_id " . uid)
    }
}

GetWindowProcess(uid) {
    process := WinGetProcessName("ahk_id " . uid)
    if (process = UWP_APPS_PROCESS) {
        hwnd := ControlGetHwnd("Windows.UI.Core.CoreWindow1", "ahk_id " . uid)
        process := ""
        if (hwnd) {
            process := WinGetProcessName("ahk_id " . hwnd)
        }
    }
    return process
}

GetWindowDetails(uid) {
    info := uid ? WinGetTitle("ahk_id " . uid) : ""
    info .= uid ? " | " . WinGetProcessName("ahk_id " . uid)  : ""
    return info
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
            if IsValidWindow(process, id) {
                ToggleAlwaysOnTop(id, state)
            }
        }
    }
    if (uid) {
        ToggleAlwaysOnTop(uid, state)
        try {
            parent := DllCall("GetParent", "UInt", uid)
            if (parent and IsValidWindow(WinGetProcessName("ahk_id " . parent), parent)) {
                sleep 10
                ToggleAlwaysOnTop(parent, state)
            }
        }
    }
}
