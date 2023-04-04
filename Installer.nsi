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

!include "MUI2.nsh"
!include "FileFunc.nsh"

!define APP_NAME "OnTop"
!define APP_VERSION "2.0.0"
!define DEVELOPER "NeonOrbit"

!define MUI_ICON "Resource\Icon.ico"
!define MUI_UNICON "Resource\IconAlt.ico"
!define XML_AUTO_LAUNCH "Resource\AutoLaunch.xml"
!define AUTO_LAUNCH_NAME "${APP_NAME}AutoLaunch"

!define SRC_FILE "${APP_NAME}-${APP_VERSION}.exe"


; ---------------------- Installer Info ----------------------;

!define MUI_BGCOLOR FFFFFF
!define MUI_PAGE_HEADER_TEXT "${APP_NAME} ${APP_VERSION} Installation"
!define MUI_WELCOMEPAGE_TITLE "${MUI_PAGE_HEADER_TEXT}"
!define MUI_WELCOMEPAGE_TEXT "\
    You are about to install ${APP_NAME} application.$\r$\n$\r$\n\
    The software is free and open source, \
    licensed under the Apache License (Version 2.0).$\r$\n$\r$\n\
    Developed by ${DEVELOPER}\
"
!define MUI_FINISHPAGE_TITLE "Installation Finished"
!define MUI_FINISHPAGE_TEXT "${APP_NAME} application installed successfully."
!define MUI_FINISHPAGE_BUTTON "Finish"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP_STRETCH FitControl 
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\win.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-grey.bmp"

!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_NAME}.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Start ${APP_NAME} to tray (required)"

!define MUI_FINISHPAGE_NOREBOOTSUPPORT


; ---------------------- Installer Configuration ----------------------;

Name ${APP_NAME}
OutFile "${APP_NAME}-v${APP_VERSION}.exe"
Unicode True

VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${DEVELOPER}"
VIAddVersionKey "FileDescription" "${APP_NAME}"
VIAddVersionKey "FileVersion" "${APP_VERSION}.0"
VIAddVersionKey "LegalCopyright" "(C) 2023 NeonOrbit"

ShowInstDetails show
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${APP_NAME}" "Install_Dir"

!insertmacro MUI_FUNCTION_GUIINIT

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH


; ---------------------- Installer Pages ----------------------;

Section "Core (required)"
    SectionIn RO
    
    ; Save installation path
    WriteRegStr HKLM "Software\${APP_NAME}" "Install_Dir" "$INSTDIR"

    InitPluginsDir
    File "/oname=$PLUGINSDIR\${AUTO_LAUNCH_NAME}" "${XML_AUTO_LAUNCH}"  ; Copy auto-start file

    closeprocess:
    nsExec::Exec 'cmd /c tasklist /fi "IMAGENAME eq ${APP_NAME}.exe" | find /i "${APP_NAME}.exe"'
    Pop $0
    Pop $1
    ${If} $0 != 1
        DetailPrint "Stopping app process..."
        nsExec::Exec 'taskkill /im "${APP_NAME}.exe" /f'
        Pop $0
        ${If} $0 != 0
            Push "Failed to stop ${APP_NAME} app process."
            Call RetryDialog
            Goto closeprocess
        ${EndIf}
        Sleep 500
    ${EndIf}

    ; Schedule auto-start
    DetailPrint "Creating auto-start entry..."
    autolanuch:
    nsExec::Exec 'schtasks /create /xml "$PLUGINSDIR\${AUTO_LAUNCH_NAME}" /tn "${AUTO_LAUNCH_NAME}" /f'
    Pop $0
    ${If} $0 != 0
        Push "Failed to set auto start entry."
        Call RetryDialog
        Goto autolanuch
    ${EndIf}

    ; Generate installation files
    SetOutPath $INSTDIR
    File "/oname=${APP_NAME}.exe" "${SRC_FILE}"
    WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Generate Uninstaller registry
    ${GetSize} "$INSTDIR" "/M=${APP_NAME}.exe /S=0K /G=0" $0 $1 $2
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\${APP_NAME}.exe,0"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${DEVELOPER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "InstallLocation" "$INSTDIR"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "EstimatedSize" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
SectionEnd

Section "Start Menu Shortcuts"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
SectionEnd

Section /o "Desktop Shortcuts"
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
SectionEnd

Section "Uninstall"
    nsExec::Exec 'taskkill /IM "${APP_NAME}.exe"'
    Sleep 500

    ; Remove files
    Delete "$INSTDIR\${APP_NAME}.exe"
    Delete "$INSTDIR\uninstall.exe"
    
    ; Remove auto-start entry
    nsExec::Exec 'schtasks /delete /tn "${AUTO_LAUNCH_NAME}" /f'

    ; Remove registry keys
    DeleteRegKey HKLM "Software\${APP_NAME}"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"

    ; Remove shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}.lnk"

    RMDir "$INSTDIR"
SectionEnd


; ---------------------- Custrom Functions ----------------------;

Function RetryDialog
    Pop $0
    MessageBox MB_RETRYCANCEL "$0" IDRETRY retry IDCANCEL cancel
    retry:
      Return
    cancel:
      Quit
FunctionEnd
