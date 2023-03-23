
APP_NAME := "OnTop", APP_VERSION := "2.0.0"

;@Ahk2Exe-Let Name = %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%
;@Ahk2Exe-Let Version = %A_PriorLine~U)^(.+"){3}(.+)".*$~$2%
;@Ahk2Exe-ExeName %A_ScriptName~\.[^\.]+$~%-v%U_Version%.exe%
;@Ahk2Exe-UpdateManifest 1, %U_Name%, %U_Version%.0
;@Ahk2Exe-SetName %U_Name%
;@Ahk2Exe-SetVersion %U_Version%.0
;@Ahk2Exe-SetDescription %U_Name%
;@Ahk2Exe-SetCopyright © %U_Name% Software ™
;@Ahk2Exe-SetMainIcon Resource\Icon.ico
;@Ahk2Exe-AddResource Resource\Icon.ico, 160
;@Ahk2Exe-AddResource Resource\Icon.ico, 206
;@Ahk2Exe-AddResource Resource\IconAlt.ico, 207
;@Ahk2Exe-AddResource Resource\IconAlt.ico, 208

/*@Ahk2Exe-Keep
    #SingleInstance Ignore
    TraySetIcon(A_ScriptFullPath, -206, 1)
*/

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

DEVELOPER := "NeonOrbit"
HELP_URL := "https://neonorbit.github.io/ontop"
UPDATE_URL := "https://github.com/NeonOrbit/OnTop/releases/latest"
SOURCE_SITE := "Github.com/NeonOrbit/OnTop"
