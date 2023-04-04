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

APP_NAME := "OnTop", APP_VERSION := "2.0.0"

;@Ahk2Exe-Let Name = %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%
;@Ahk2Exe-Let Version = %A_PriorLine~U)^(.+"){3}(.+)".*$~$2%
;@Ahk2Exe-ExeName %U_Name%-%U_Version%.exe%
;@Ahk2Exe-UpdateManifest 1, %U_Name%, %U_Version%.0
;@Ahk2Exe-SetName %U_Name%
;@Ahk2Exe-SetVersion %U_Version%.0
;@Ahk2Exe-SetDescription %U_Name%
;@Ahk2Exe-SetCopyright Copyright (C) 2023 NeonOrbit
;@Ahk2Exe-SetMainIcon Resource\Icon.ico
;@Ahk2Exe-AddResource Resource\Icon.ico, 160
;@Ahk2Exe-AddResource Resource\Icon.ico, 206
;@Ahk2Exe-AddResource Resource\IconAlt.ico, 207
;@Ahk2Exe-AddResource Resource\IconAlt.ico, 208

/*@Ahk2Exe-Keep
    TraySetIcon(A_ScriptFullPath, -206, 1)
*/

#SingleInstance Force

SetTitleMatchMode 1
DetectHiddenWindows true

A_ScriptName := APP_NAME
A_MenuMaskKey := "vkFF"

APP_ICON := 206
ALT_ICON := 207

ID_APPINIT := "AppInit"
ID_SERVICE := "Service"
ID_LOGGING := "Logging"
ID_LOGFMAX := "LogFMax"

DEFAULT_LOGGING := false
DEFAULT_LOGFMAX := 100

ID_PIN_WINDOWS := "IdPinWindows"
ID_CLR_WINDOWS := "IdClrWindows"
ID_PIN_PROGRAM := "IdPinProgram"
ID_CLR_PROGRAM := "IdClrProgram"

DEFKEY_PIN_WINDOWS := "#SPACE"
DEFKEY_CLR_WINDOWS := "#!SPACE"
DEFKEY_PIN_PROGRAM := "#+SPACE"
DEFKEY_CLR_PROGRAM := "#+!SPACE"

APP_HOTKEY_IDS := [
    ID_PIN_WINDOWS, 
    ID_CLR_WINDOWS,
    ID_PIN_PROGRAM, 
    ID_CLR_PROGRAM
]

APP_DEFAULT_HOTKEYS := Map(
    ID_PIN_WINDOWS, DEFKEY_PIN_WINDOWS,
    ID_CLR_WINDOWS, DEFKEY_CLR_WINDOWS,
    ID_PIN_PROGRAM, DEFKEY_PIN_PROGRAM,
    ID_CLR_PROGRAM, DEFKEY_CLR_PROGRAM
)

APP_DEFAULT_DIR := A_AppData . "\" . APP_NAME
APP_CONFIG_FILE := APP_DEFAULT_DIR . "\Config.ini"
APP_LOG_FILE_DIR := APP_DEFAULT_DIR . "\LogFiles"

DirCreate APP_DEFAULT_DIR
SetWorkingDir APP_DEFAULT_DIR
DirCreate APP_LOG_FILE_DIR

APP_DEVELOPER := "NeonOrbit"
APP_UPDATE_URL := "https://github.com/NeonOrbit/OnTop/releases/latest"
APP_SOURCE_SITE := "Github.com/NeonOrbit/OnTop"

APP_START_HINT := ""
. APP_NAME . " is minimized to system tray.`n" 
. "Please right-click on the app tray icon to show the main menu."

APP_ABOUT_TEXT := ""
. APP_NAME . "  (" APP_VERSION . ")`n`n"
. "Developer:  " . APP_DEVELOPER . "`n`n"
. "Source Code:  " . APP_SOURCE_SITE . "`n"

APP_HELP_TEXT := ""
. "::::::::::-> " . APP_NAME . " (" APP_VERSION . ") <-::::::::::`n`n"
. "Features:`n`n"
. "|-> Pin Window (win+space):  Keeps a window on top of other windows.`n`n"
. "|-> Unpin Window (win+alt+space):  Removes the ontop ability of a window.`n`n"
. "|-> Pin Program (win+shift+space):  Keeps an app (not just a window) always on top.`n`n"
. "|-> Unpin Program (win+shift+alt+space):  Removes the ontop ability of a previously pinned app.`n`n"
. "`n"
. "[-] Pin Window* ability is temporary, which means it will remain only until the window is closed.`n"
. "[-] Pin Program* ability is sticky, it will remain in effect until the user unpin it manually.`n"
. "`n"
. "To change the default shortcut keys, please go to OnTop tray menu.`n"
