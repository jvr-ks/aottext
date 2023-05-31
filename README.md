# Aottext ![Icon](https://github.com/jvr-ks/aottext/blob/main/aottext.ico?raw=true)  
 
 
### Status: Beta-test
  
#### Description  
A "one sticky note" staying always on top (Windows > 10, 64 bit only).   
- takes less spaces on the desktop,  
- autosaves if content is changed \*1), always to a new file,  
- manual save (tagging) possible ("Save"-button),  
- history function (Alt-key + mousewheel),  
- zoom with Ctrl + mousewheel (default fontsize is defined in the config-file).   
 
All content is kept in memory, so not suitable for very large files.  
If the menu-buttons get deactivated by the operating-system, 
which happens from time to time,  
move the mouse over the text-edit-field to reactivate them!  
Aottext is excluded from the list of running apps (if AOT is enabled, which is the default).  
  
\*1) 
Content is saved if it was changed and:  
- on any "hide"-operation,  
- on exiting the app.  
- by pressing the "Save"-button.  
("Save"-button saves the content regardless of whether it has been changed or not).  
  
#### Hide the Aottext window  
Aottext is always on top, but sometimes this behavior is temporary unwanted.  
To hide the Aottext-window use one of the 4 actions:  
  
No. | hide with key | show with key | remarks  
------------ | ------------- | ------------- | -------------  
1 | [Left-shift] + [Right-mousebutton] | same again | #1 and #2 can be mixed  
2 | [Left-shift] + [Control] + "mouse-over" | Mouse-over minimized Edit-field | #1 and #2 can be mixed  
3 | [Alt] + [a] | same again |  
4 | H30 button | [Alt] + [a] twice | timeout: 30 seconds  
  
Or just close the app (content is auto-saved) and reopen it later.  
  
#### Download  
Via Updater is the preferred method!  
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Installation-directory (is created by the Updater) must be writable by the app!** 
  
To download **aottext.exe** 64 bit Windows from Github please use:  
  
[updater.exe 64bit](https://github.com/jvr-ks/aottext/raw/main/updater.exe)  
  
(Updater viruscheck please look at the [Updater repository](https://github.com/jvr-ks/updater)) 
  
* From time to time there are some false positiv virus detections  
[Virusscan](#virusscan) at Virustotal see below.  
  
#### Start installation / update:  
* Run "updater.exe", example: "C:\jvrks\aottext\updater.exe" once to download/update aottext.  
* Then start "aottext.exe", example: "C:\jvrks\aottext\aottext.exe" !  
(Create a dektop-icon or a taskbar entry).  
  
#### Configuration-file  
The Configuration-file ("aottext_<ComputerName>.ini") is generated automatically, if it doesn't exist already.  
There are two menu-buttons to edit the Configuration-file:  
"Menu" -> "Setup" -> "Edit Config"  
"Menu" -> "Setup" -> "Edit Config (external editor)"  
  
#### Configuration-file backup / autorestore
If the directory "C:\Users\<UserName>\AppData\Roaming\aottext\" is usable,
the app saves a copy of the Configuration-file to this backup-directory.  
If the Configuration-file is missing,  
an attempt is made to restore the file from the backup directory.  
Otherwise a new Configuration-file is created, containing default-values.  

#### Enable Unicode UTF-8  
Windows uses Unicode UTF-16 as the default,  
but the Scintilla control uses UTF-8.  
To use the full Unicode characterset, enable UTF-8 support in Windows:  
[Enable Unicode UTF-8 (Windows 10)](https://www.jvr.de/2022/07/30/unicode-in-console-windows-10-en_us/)

#### File history  
Inspecting all existing files in the "_saved"-directory by using Alt + Mousewheel Up/Down,  
independent of the mouseposition on the screen!  
Any changes made are always written to a **new** file!  
  
#### Autosave  
Any changes made are always written automatically to a **new** file!,  
if Alt + Mousewheel is used or when Aottext is exiting.  
The "Save"-button does this immediatedly, even if the content has not changed, 
but always to a new file! 
  
#### reActivate Window  
Sometimes the operating system takes away the focus of Aottext (Titlebar changes the color).  
If the mouse is moved over the Aottext window text enty field (not the title-bar),  
the focus is reactivated to Aottext.    
  
#### Hotkeys / Mousemove-modifiers  
Hide/Show Aottext hotkey is \[ALT] + \[a] (default).  
Set: Configuration-file -> \[config] -> aottextHotkey="!a"  
Quick-Hide mouse-hover-modifier is \[Ctrl] + \[Lshift] (default)  
  
Set: Configuration-file -> \[config] -> quickHideModifier1="Lshift" and quickHideModifier2="Ctrl"  
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/aottext/blob/main/hotkeys.md)  
  
#### Sourcecode 
[Sourcecode at Github](https://github.com/jvr-ks/aottext), "aottext.ahk" an [Autohotkey](https://www.autohotkey.com) script.  
Uses the [Scintilla](https://www.scintilla.org/) Textcontrol (Scintilla.dll).  
Block move with tab: Indentation is 2 spaces (fixed). 
Made with Autohotkey version 1.0 ...  
  
#### Fonts  
Default is "Segoe UI" but I prefer ["Source Code Pro"](https://github.com/adobe-fonts/source-code-pro/releases)  
Configuration-file -> \[config] fontSCI="Source Code Pro"  
Configuration-file -> \[config] fontsizeSCI=11  
  
#### Startparameter  
- **hidewindow**, if the app is started with windows, this parameter hides the app-window upon the windows start,  
  use the hotkey to open the app then.  
- **remove**, removes "aottext.exe" from memory.  
  
#### Menu button "ToTrash"  
Immediately moves the actual selected file to the "_trash" subdirectory,  
without any confirmation request.  
  
#### Hints  
-"Save"-button:  
The filename is generated from the current time with a resolution of one second.  
Do not press the "Save"-button more than once in less than a second, 
or you'll get an error-message then!  
Make sure that the date/time of your computer have the correct values.  
  
#### Latest changes:  
  
Version (>=)| Change  
------------ | -------------   
0.050 | new config entry: xPercentHidden, quickHideEnabled entry removed (allways "on" now)
0.045 | Autosave filename changed from "aottext_yyyyMMddhhmmss" to "aot_yyyyMMddhhmmss", button "YmaxXr"
0.044 | Lost focus bug fixed
0.043 | Bug (did not save new content) fixed
0.042 | Always using a localized Configuration-file, i.e. "aottext_COMPUTERNAME.ini"
0.041 | The Configuration-file -> quickhideHotkey is hardcoded and not changeable.
0.040 | Configuration-file changed! Delete the old one, a corrected new one will be created automatically!
0.029 | To trash button, moves the actual file to the "_trash" subdirectory!  
0.028 | Startparameter: hidewindow and remove  
0.027 | QuickHide enabled by default  
0.026 | A hotkey to hide / show the Aottext-window, Configuration-file -> \[config] -> aottextHotkey, default is \[Alt] + [a] ("!a")  
0.022 | Configuration-file changed! Delete the old one, a corrected new one will be created automatically!  
0.021 | Configuration-file -> \[config] -> saveDir="absolute paths are allowed"  
0.001 | under construction  
  
#### Known issues / bugs  
Issue / Bug | Type | fixed in version  
------------ | ------------- | -------------  
Sometimes all text becomes selected and the caret-position moves to the end | issue | -  
Files must at least contain one newline! | Scintilla issue | 0.008 (Aottext auto adds a newline)  
  
#### License: MIT  
Permission is hereby granted, free of charge,  
to any person obtaining a copy of this software and associated documentation files (the "Software"),  
to deal in the Software without restriction,  
including without limitation the rights to use,  
copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software,  
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all copies  
or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
  
Copyright (c) 2020 J. v. Roos  
  
Other parts License  
"SCI.ahk" from:  
https://github.com/RaptorX/scintilla-wrapper  
Copyright by Isaias Baez  
Has no License information!  
  
<a name="virusscan">  


##### Virusscan at Virustotal 
[Virusscan at Virustotal, aottext.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/c44ffbba37e4b31eb4a11ff3a8235bfb66f64292c3749d6195ba38c8e2b42346/detection/u-c44ffbba37e4b31eb4a11ff3a8235bfb66f64292c3749d6195ba38c8e2b42346-1685528732
)  
