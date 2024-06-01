# OnTop

A simple program for `WindowsOS` that allows you to pin a window on the top of all other windows.

### Description
The program allows you to keep a window always on top.
It also has options to pin an app (all windows of an app),
which remembers the app and automatically pins any windows open from it.

### Features
- Pin Window `(win+space)`:  Keeps a window on top of all other windows.
- Unpin Window `(win+alt+space)`:  Removes the AlwaysOnTop ability of a window.
- Pin Program `(win+shift+space)`:  Keeps an app (not just a window) always on top.
- Unpin Program `(win+shift+alt+space)`:  Removes the AlwaysOnTop ability of a previously pinned app.

The `Pin Window` ability is temporary, which means it will remain active only until the window is closed.
The `Pin Program` ability is sticky, which means it will remain in effect until the user manually unpins it.

To change the default shortcut keys, please right-click on the `OnTop` tray icon and open the `Shortcuts` menu.

### Download
- Latest version: [download](https://github.com/NeonOrbit/OnTop/releases/latest)

---------------------------------------------

### Build Instructions:
Compile from the source.
- Clone or download the repository.
- Download and install [AutoHotkey](https://github.com/AutoHotkey/AutoHotkey/releases).
- Open `AutoHotkey Desh` and select `Compile` tool (download if necessary).
- Drag and Drop `A_OnTop.ahk` into `Source (script file)` field and select `Convert`.
- Download and install [NSIS](https://nsis.sourceforge.io/Download).
- Open `NSIS` and select `Compile NSI Script`.
- Drag and Drop `Installer.nsi` into the NSI Compiler window.
- Output: `OnTop-version.exe`

## License

```
Copyright (C) 2023 NeonOrbit

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
