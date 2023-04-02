﻿/*
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

#Include E_Config.ahk
#Include E_Trayer.ahk
#Include E_Logger.ahk
#Include E_Utility.ahk
#Include E_Windows.ahk
#Include E_Services.ahk
#Include E_Shortcuts.ahk

Global Preference := ExMap()
Global ProcessList := ExSet()

Global SystemTray := Trayer()
Global AppService := Services()
Global MainLogger := Logger(APP_LOG_FILE_DIR)

try {
    AppStart()
} catch as e {
    HandleError(e)
}

Initialize()
{
    UpdatePreference(ID_APPINIT, true)
    UpdatePreference(ID_SERVICE, true)
    UpdatePreference(ID_LOGGING, DEFAULT_LOGGING)
    UpdatePreference(ID_LOGFMAX, DEFAULT_LOGFMAX)
    for key, value in APP_DEFAULT_HOTKEYS {
        UpdatePreference(key, value)
    }
}

AppStart()
{
    FetchAppData()
    if (!Preference[ID_APPINIT]) {
        Initialize()
    }
    WriteLog("[App Started]")
    MainLogger.max(Preference[ID_LOGFMAX])
    SystemTray.init(Preference[ID_SERVICE])
    AppService.setWindowEventCallback(HandleWindowEvent)
    AppService.setHotKeyCallback(HandleHotkeyEvent)
    AppService.setHotKeys(Preference)
    UpdateAppService()
}

OnExit AppExit
AppExit(reason, code)
{
    try {
        AppService.unregister()
        UpdateAllWindows(false)
        WriteLog("[App Terminated]", true)
    }
}

OnError UncaughtError
UncaughtError(error, mode)
{
    warning := mode != "ExitApp" ? "WARNING!" : ""
    HandleError(error, !warning, warning)
    return warning ? 1 : 0
}

UpdateAppService(state?) {
    if (!IsSet(state))
        state := Preference[ID_SERVICE]
    else
        UpdatePreference(ID_SERVICE, state)
    if (state)
        AppService.register()
    else
        AppService.unregister()
    SystemTray.update(state)
    UpdateAllWindows(state)
    WriteLog("[Service " (state?"Enabled]":"Disabled]"))
}

RefreshApp() {
    FetchAppData()
    AppService.setHotKeys(Preference)
    MainLogger.max(Preference[ID_LOGFMAX])
    UpdateAppService()
}

ResetAppData()
{
    Preference.clear()
    ProcessList.clear()
    FileDelete APP_CONFIG_FILE
    Initialize()
}

HandleWindowEvent(process, window) {
    if ProcessList.has(process) and IsValidWindow(process, window) {
        UpdateWindowState(window)
        WriteLog("Auto pinned: " . process . " (" . window . ")")
    }
}

HandleHotkeyEvent(pin, program) {
    try {
        hWindow := WinGetID("A")
        pin_msg := pin ? "Pinned" : "Unpinned"
        if (!program) {
            ToggleAlwaysOnTop(hWindow, pin)
            WriteLog(pin_msg . " window: " . hWindow)
        } else {
            wProcess := GetWindowProcess(hWindow)
            if IsValidWindow(wProcess, hWindow) {
                if (pin or ProcessList.has(wProcess)) {
                    UpdateProcessList(wProcess, pin)
                    UpdateWindowState(hWindow, wProcess, pin)
                    WriteLog(pin_msg . " program: " . wProcess)
                }
            }
        }
    } catch as e {
        msg := "Failed to " . (pin ? "pin" : "unpin")
        msg .= " the " . (program ? "program" : "window")
        details := IsSet(hWindow) ? ": " . GetWindowDetails(hWindow) : ""
        HandleError(e, false, msg . details)
    }
}

UpdateAllWindows(state := true)
{
    for item in ProcessList {
        UpdateWindowState(, item, state)
    }
}

UpdateHotKeys(hotkeys) {
    for id in APP_HOTKEY_IDS {
        UpdatePreference(id, hotkeys[id])
    }
    AppService.setHotKeys(Preference)
}

ShowShortcutsWindow() {
    Shortcuts(UpdateHotKeys).show(Preference)
}

FetchAppData()
{
    Preference.clear()
    ProcessList.clear()
    pref := IniRead(APP_CONFIG_FILE, "Preference",, "")
    for index, value in StrSplit(pref, "`n") {
        item := StrSplit(value, "=")
        Preference[item[1]] := item[2]
    }
    process := IniRead(APP_CONFIG_FILE, "ProcessList",, "")
    for index, value in StrSplit(process, "`n") {
        ProcessList.add(StrSplit(value, "=")[1])
    }
}

UpdatePreference(key, value)
{
    Preference[key] := value
    IniWrite(value, APP_CONFIG_FILE, "Preference", key)
}

UpdateProcessList(process, add)
{
    if (add) {
        ProcessList.add(process)
        IniWrite(true, APP_CONFIG_FILE, "ProcessList", process)
    } else {
        ProcessList.delete(process)
        IniDelete(APP_CONFIG_FILE, "ProcessList", process)
    }
}

FlushLog() {
    WriteLog("", true)
}

WriteLog(msg, flush := false)
{
    if (Preference[ID_LOGGING]) {
        MainLogger.log(msg, flush)
    }
}

HandleError(e, fatal := true, msg := "")
{
    errMsg := (msg ? msg : "An Error Occured!") . "`n`n"
    if (e.message ~= ".*\S.*")
        errMsg .= "Issue:  " e.message "`n"
    if (e.what ~= ".*\S.*")
        errMsg .= "From:  " e.what "`n"
    if (e.extra ~= ".*\S.*")
        errMsg .= "Hint:  " e.extra "`n"
    If (!A_IsCompiled)
        errMsg .= "`n" e.file ":" e.line "`n`n"
    if (fatal)
        errMsg .= "The program will exit.`n"
    WriteLog("Error: " . errMsg)
    MsgBox(errMsg,, 0x1030)
    if (fatal) {
        ExitApp 1
    }
}
