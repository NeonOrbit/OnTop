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

TrayListMain := A_ScriptName ",Service,Refresh,ResetAll,Shortcuts,,AppList,Support,,Exit"
TrayListSrvc := "Enable,Disable"
TrayListSupp := "Log,Help,Update,About"

class Trayer {
    serviceSub := Menu()
    supportSub := Menu()
    eventHandler := this.handleEvents.bind(this)

    init(state) {
        A_TrayMenu.delete()
        Loop Parse, TrayListMain, ","
        {
            if (!A_LoopField)
                A_TrayMenu.add()
            else
                A_TrayMenu.add(A_LoopField, this.eventHandler)
        }
        Loop Parse, TrayListSrvc, ","
            this.serviceSub.add(A_LoopField, this.eventHandler)
        Loop Parse, TrayListSupp, ","
            this.supportSub.add(A_LoopField, this.eventHandler)
        A_TrayMenu.disable("1&")
        A_TrayMenu.add("Service", this.serviceSub)
        A_TrayMenu.add("Support", this.supportSub)
    }

    update(state, hotkeys)
    {
        position := state ? 1 : 2
        icon := state ? -APP_ICON : -ALT_ICON
        srvs := state ? "Running" : "Stopped"
        if (A_IsCompiled) {
            TraySetIcon(A_ScriptFullPath, icon, 1)
        }
        A_TrayMenu.rename("1&", srvs)
        A_IconTip := A_ScriptName . " (" . srvs . ")"
        this.serviceSub.check(position . "&")
        this.serviceSub.uncheck((position ^ 3) . "&")
        this.updateInfo(hotkeys)
    }

    updateInfo(hotkeys) {
        info := StrSplit(A_IconTip, "`n",, 2)[1] . "`n"
        for id in APP_HOTKEY_IDS {
            hkey := StrUpper(hotkeys[id])
            hkey := StrReplace(hkey, "+", "Shift+")
            hkey := StrReplace(hkey, "#", "Win+")
            hkey := StrReplace(hkey, "^", "Ctrl+")
            hkey := StrReplace(hkey, "!", "Alt+")
            info .= "`n" . APP_DEFAULT_HOTKEY_FUNCS[id] . ":  " . hkey
        }
        A_IconTip := info
    }

    handleEvents(item, pos, obj)
    {
        state := pos = 1 ? true : false
        switch (item) {
            case "Enable", "Disable":
                Critical
                UpdateAppService(state)
            case "Refresh":
                this.refresh()
            case "ResetAll":
                this.refresh(true)
            case "Shortcuts":
                ShowShortcutsWindow()
            case "AppList":
                this.showAppList()
            case "Log":
                FlushLog()
                Run APP_LOG_FILE_DIR
            case "Help":
                MsgBox(APP_HELP_TEXT,, 0x40000)
            case "Update":
                Run APP_UPDATE_URL
            case "About":
                MsgBox(APP_ABOUT_TEXT,, 0x40000)
            case "Exit":
                if (MsgBox("Exit the app now?",, 0x40134) = "Yes") {
                    ExitApp(0)
                }
        }
    }

    refresh(reset := false)
    {
        Critical("On")
        if (reset) {
            if (MsgBox("Reset to default?",, 0x40134) = "Yes") {
                UpdateAllWindows(false)
                ResetAppData()
            } else {
                return
            }
        }
        RefreshApp()
        Critical("Off")
    }

    showAppList()
    {
        list := "Active Apps List:`n`n"
        if (!ProcessList.count) {
            list .= "  List is Empty"
        } else {
            for item in ProcessList {
                list .= "  " . A_Index . ". " . item "`n"
            }
        }
        MsgBox(list,, 0x40000)
    }
}
