# Aottext ![Icon](https://github.com/jvr-ks/aottext/blob/main/aottext.ico?raw=true)  
 
 
### Status of version 2: BETA test
  
#### Description  
A "one sticky note" staying always on top (Windows &gt; 10, 64 bit only).  
- can show the content in 3 different window positions:
- - normal mode: at the bottom of the screen,  
- - vertical mode: on the right side vertically oriented,  
- - small mode: on the left side screen bottom with reduced heigth (return to normal mode with mousover the editarea)
  
- takes less spaces on the desktop,  
- autosaves if content is changed \*1), always to a new file,  
- manual save (tagging) possible ("Save"-button),  
- history function (Shift-key + mousewheel),  
- zoom with Ctrl + mousewheel (default FontSize is defined in the Configurationfile: "guiMainEditFontSize").   
  
All content is kept in memory, so not suitable for very large files.  
Aottext is excluded from the tasklist (if "Autosmall" is enabled).  
  
\*1) 
Content is saved if it was changed and:  
- on any "hide"-operation,  
- on exiting the app.  
- by pressing the "Save"-button.  
("Save"-button saves the content regardless of whether it has been changed or not).  
  
#### Aottext usage  
  
Key(s) / Button | Operation | Remarks  
------------ | ------------- | -------------  
\[SMode] button | "small" position | 
\[NMode] button | "normal" position | 
\[VMode] button | "vertical" position | 
\[Exit] button | close the app (content is auto-saved) and reopen it later. :-) 
\[Mouseover] edit field | return to "NMode" | if "SMode" is active
\[Left-shift] + \[Right-mousebutton] | toggle "NMode" - "SMode" | pressed anywere on the screen 
\[Alt] + \[Right-mousebutton]| toggle "NMode" - "VMode" | pressed anywere on the screen  
\[Alt] + \[a] | toggle hide/show Aottext | always returns to "NMode"  
\[Shift] + \[Mouswheel] | content history  | browse through all files
  
#### Hide the Aottext window: Autosmall  
If "Op"  -&gt; "Settings" -&gt; "Autosmall" is selected,  
the Aottext-window is automatically moved/resized to the "SMode"-position,    
if it is **out of focuss**.  
  
#### Enable Unicode UTF-8  
To use the full Unicode characterset, enable UTF-8 support in Windows:  
[Enable Unicode UTF-8 (Windows 10)](https://www.jvr.de/2022/07/30/unicode-in-console-windows-10-en_us/)

#### File history  
Inspecting all existing files in the "_saved"-directory by using Shift + Mousewheel Up/Down,  
independent of the mouseposition on the screen!  
Any changes made are always written to a **new** file!  
  
#### File Encoding  
UTF-8 BOM  (besides "*.ini" files)  
  
#### Autosave  
Any changes made are always written automatically to a **new** file!,  
if Shift + Mousewheel is used or when Aottext is exiting.  
The "Save"-button does this immediatedly, even if the content has not changed, 
but always to a new file! 
  
#### Line wrapping  
To switch off line wrapping, each mode has a wrap configuration of its own, "Settings" ➝ "NoWrapNMode" etc. (especially useful in the VMode).  
  
#### reActivate Window  
Sometimes the operating system takes away the focus of Aottext (Titlebar changes the color).  
If the mouse is moved over the Aottext text edit field (not the title-bar),  
the focus is reactivated to Aottext.    
  
#### Hotkeys / Mousemove-modifiers  
Hide/Show Aottext hotkey is \[ALT] + \[a] (default).  
Set: Configurationfile -&gt; \[config] -&gt; aottextHotkey="!a"  
  
* **Quick-Hide mouse-hotkey is \[Ctrl] + \[RButton] (hardcoded)**  
* **Quick-Show mouse-hotkey is \[LShift] + \[RButton] (hardcoded)**  
    
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/aottext/blob/main/hotkeys.md)  
  
#### Menu button "ToTrash"  
Immediately moves the actual selected file to the "_trash" subdirectory,  
without any confirmation request.  
  
#### Menu button "Insert"  
The file insertUnicodeFile (default is "insertUnicode.txt" as defined in the Configuration file) contains name \| value pairs (characters to insert into the text).  
If an entry is selected, it is copied to the clipboard.  
If you did not change the file name in the Configuration file and the project "Unicodetable" is installed (located)  
in the sibling directory "..\unicodetable",  
the file "..\unicodetable\insertUnicode.txt" is used instead.  
This way Aottext uses the list made with "Unicodetable.exe".  
  
#### Hints  
-"Save" button:  
The filename is generated from the current time with a resolution of one second.  
Do not press the "Save"-button more than once in less than a second, 
or you'll get an error-message then!  
Make sure that the date/time of your computer have the correct values.  
  
#### Fonts  
The font used in the text is seletable ("Setting" → "Font of text").  
At the top of the font list are some prefered fonts, change them by editing the Configurationfile  
section "[preferedFonts]",  
entries:  
preferredFont1="Consolas" \*1)  
preferredFont2="Noto colored emoji"  
preferredFont3="OCR-A BT"  
...  
up to 20  
  
The selected font and size are saved in the Configurationfile →; \[config] guiMainEditFontName="Consolas"  
and Configurationfile → \[config] guiMainEditFontSize=10  
  
The menu is using Windows menus, changing the font would change the font of all other apps (menus) too!  
  
\*1) Drawback of the "Consolas" font is its ugly Smiley character: "☺" should be: &#128522;
  
#### Configuration file  
(**Changed from version >= 0.015**)  

The Configuration file is "aottext.ini".  
(For development and test purposes the file "_aottext.ini" may be use, which takes precedence).  
  
There are two menu-buttons to edit the Configurationfile:  
"Menu" -&gt; "Op" -&gt; "Settings" -&gt; "Edit Config"  
"Menu" -&gt; "Op" -&gt; "Settings" -&gt; "Edit Config (external editor)"  
  
#### Startparameter  
- **hidewindow**, if the app is started with windows, this parameter hides the app-window upon the windows start,  
  use the hotkey to open the app then.  
- **remove**, removes "aottext.exe" from memory.  
  
#### Start installation / update:  
* Run "updater.exe", example: "C:\jvrks\aottext\updater.exe" once to download/update aottext.  
(Menu -&gt; Op -&gt; Update -&gt; Start updater)  
* Then start "aottext.exe", example: "C:\jvrks\aottext\aottext.exe" !  
* Create a desktop-icon and/or a taskbar entry.  
Hint: **To create a taskbar entry, "Autosmall" must be switched off temporarily (Menu -&gt; Op -&gt; Settings -&gt; Autosmall)**  
("Autosmall" does not hide the window but activates the small mode!)  
  
#### First start onetime layout finetune:  
The default layout looks like this:  
```
                                                                                   VMode   
                                                                                   ┌──────┐
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                                                                   │      │
                                              NMode                                │      │
                                             ┌───────────────────┐                 │      │
                                             │                   │                 │      │
                                             │                   │                 │      │
                                             │                   │                 │      │
                                             │                   │                 │      │
 SMode                                       │                   │                 │      │
┌───────────────────────────┐                │                   │                 └──────┘
└───────────────────────────┘                └───────────────────┘                         
  
```
Please resize / reposition the window in each position ("NMode", "VMode" and "SMode") once. 
  
#### Download  
Via "Updater" is the preferred method!  
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Installation-directory (is created by the Updater) must be writable by the app!**  
  
To download **aottext.exe** 64 bit Windows from Github please use:  
  
[updater.exe 64bit](https://github.com/jvr-ks/aottext/raw/main/updater.exe)  
  
(Updater viruscheck please look at the [Updater repository](https://github.com/jvr-ks/updater)) 
  
* From time to time there are some false positiv virus detections  
[Virusscan](#virusscan) at Virustotal see below.  
  
#### Sourcecode 
[Sourcecode at Github](https://github.com/jvr-ks/aottext), "aottext.ahk" an [Autohotkey](https://www.autohotkey.com) script.  
Uses the [Scintilla](https://www.scintilla.org/) Textcontrol (Scintilla.dll).  
Block move with tab: Indentation is 2 spaces (fixed). 
Made with Autohotkey version 1.0 ...  
  
#### Latest changes:  
Version (&gt;=)| Change  
------------ | -------------  
0.018 | \[Control] + \[Right-mousebutton] toggle "NMode" - "VMode" replace by \[Alt] + \[Right-mousebutton] 
0.017 | Lexer enabled (AHK code)
0.015 | Each mode has a text wrap configuration of its own (especially useful in the VMode).   
0.013 | Conf. file location changed, "Setup" renamed to "Settings"
0.011 | Added transparency to SMode, removed Configfile backup mechanism, Shift + Mousewheel instead of Alt + Mousewheel
0.005 | "Hide" renamed to "SMode", \[Right-mousebutton] both operations changed to "toggle"  
0.002 | Quick-Hide mouse-hotkeys changed (hardcoded): LShift & RButton -&gt; HIDE, LControl & RButton -&gt; SHOW (NMode)
0.001 | File-history hotkey changed to LShift & WheelUp / LShift & WheelDown
0.001 | Reset version to "0.001" (Upgraded Aottext from AHK1 to AHK2)
0.055 | Fileencoding changed to UTF-8-BOM (configfile: UTF-16 LE-BOM), new menu entry: "Insert"
0.054 | Gui size not overwritten if maximized
0.053 | Menu -&gt; setup -&gt; Autosmall
0.050 | new config entry: xPercentHidden, quickHideEnabled entry removed (allways "on" now)
0.045 | Autosave filename changed from "aottext_yyyyMMddhhmmss" to "aot_yyyyMMddhhmmss", button "YmaxXr"
0.044 | Lost focus bug fixed
0.043 | Bug (did not save new content) fixed
0.042 | Always using a localized Configurationfile, i.e. "aottext_COMPUTERNAME.ini"
0.041 | The Configurationfile -&gt; quickhideHotkey is hardcoded and not changeable.
0.040 | Configurationfile changed! Delete the old one, a corrected new one will be created automatically!
0.029 | To trash button, moves the actual file to the "_trash" subdirectory!  
0.028 | Startparameter: hidewindow and remove  
0.027 | QuickHide enabled by default  
0.026 | A hotkey to hide / show the Aottext-window, Configurationfile -&gt; \[config] -&gt; aottextHotkey, default is \[Alt] + [a] ("!a")  
0.022 | Configurationfile changed! Delete the old one, a corrected new one will be created automatically!  
0.021 | Configurationfile -&gt; \[config] -&gt; saveDir="absolute paths are allowed"  
0.001 | under construction  
  
#### Known issues / bugs  
Issue / Bug | Type | fixed in version  
------------ | ------------- | -------------  
Shorthelp takes time to open) | issue | -
Introduced a positioning bug (NMode positioning check) | bug | 0.010 
Sometimes all text becomes selected and the caret-position moves to the end | issue | -  
Files must at least contain one newline! | Scintilla issue | 0.008 (Aottext auto adds a newline)  
  
#### License: GNU GENERAL PUBLIC LICENSE 
Please take a look at the file "license.txt"!   
  
Copyright (c) 2020 J. v. Roos  
  
#### License for Lexilla, Scintilla, and SciTE  
  
Copyright 1998-2021 by Neil Hodgson <neilh@scintilla.org>  
  
All Rights Reserved  
  
Permission to use, copy, modify, and distribute this software and its  
documentation for any purpose and without fee is hereby granted,  
provided that the above copyright notice appear in all copies and that  
both that copyright notice and this permission notice appear in  
supporting documentation.  
  
NEIL HODGSON DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS  
SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY  
AND FITNESS, IN NO EVENT SHALL NEIL HODGSON BE LIABLE FOR ANY  
SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES  
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,  
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER  
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE  
OR PERFORMANCE OF THIS SOFTWARE.  
  
Other parts License  
"SCI.ahk" from:  
https://github.com/RaptorX/scintilla-wrapper  
Copyright by Isaias Baez  
Has no License information!  
  
<a name="virusscan">  


##### Virusscan at Virustotal 
[Virusscan at Virustotal, aottext.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/c44ffbba37e4b31eb4a11ff3a8235bfb66f64292c3749d6195ba38c8e2b42346/detection/u-c44ffbba37e4b31eb4a11ff3a8235bfb66f64292c3749d6195ba38c8e2b42346-1747509074
)  
