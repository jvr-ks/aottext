;------------------------------ aottext.ahk ------------------------------
#Requires AutoHotkey v1.0

#NoEnv
#SingleInstance Force
#InstallKeybdHook

#Include, Lib\sci.ahk

license := "
(
 Copyright (c) 2023 jvr.de. All rights reserved.
 
 *********************************************************************************
 * 
 * MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the ""Software""), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
)"

FileEncoding, UTF-8-RAW

SetTitleMatchMode, 2
DetectHiddenWindows, On
SendMode Input 

wrkDir := A_ScriptDir . "\"

clipboardSave := clipboardAll

actualContent := ""

;-------------------------------- read cmdline param --------------------------------
hasParams := A_Args.Length()
starthidden := 0

if (hasParams != 0){
  Loop % hasParams
  {
    if(eq(A_Args[A_index],"remove")){
      ExitApp,0
    }

    if(eq(A_Args[A_index],"hidewindow")){
      starthidden := 1
    }

  }
}

appName := "Aottext"
appnameLower := "aottext"
extension := ".exe"
appVersion := "0.050"

bit := (A_PtrSize==8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit=="64" ? "" : bit)
app := appName . " " . appVersion . " " . bit . "-bit"


configFileOld := appnameLower . ".ini"
configFile := appnameLower . "_" . A_ComputerName . ".ini"
localConfigDir :=  A_AppData . "\" . appnameLower . "\"
localConfigFile := localConfigDir . configFile

if (FileExist(configFileOld)){
  msgbox, The old Configuration-file "%configFileOld%" was found, but is ignored!`nUsing "%configFile%" as the Configuration-file now!
}

; config variables default value:
saveDirDefault := "_saved\"
trashDirDefault := "_trash\"
fontDefault := "Segoe UI"
fontsizeDefault := 9
fontButtonAreaDefault := "Segoe UI"
fontsizeButtonAreaDefault := 9
fontSCIDefault := "Segoe UI"
fontsizeSCIDefault := 10
alwaysontopDefault := 1
mwheelModifierDefault := "Alt"
aottextHotkeyDefault := "!a"
; Hardcoded (TODO):
quickHideHotkeyDefault := "LShift & RButton"

xPercentHiddenDefault := 0.7
quickHideModifier1Default := "LShift"
quickHideModifier2Default := "Ctrl"

;gui:
dpiScaleDefault := 96
dpiScale := dpiScaleDefault

if ((0 + A_ScreenDPI == 0) || (A_ScreenDPI == 96))
  dpiCorrect := 1
else
  dpiCorrect := A_ScreenDPI / dpiScale

windowPosXDefault := 0
windowPosYDefault := 0

clientWidthDefault := 800
clientHeightDefault := 600

windowPosVModeXDefault := round(A_ScreenWidth * 0.7)
windowPosVModeYDefault := 0
windowWidthVModeDefault := round(A_ScreenWidth * 0.3)
windowHeightVModeDefault := round(A_ScreenHeight * 0.95)

localVersionFileDefault := "version.txt"
serverURLDefault := "https://github.com/jvr-ks/"
serverURLExtensionDefault := "/raw/main/"

; config variables:

; [config]
font := fontDefault
fontsize := fontsizeDefault
fontButtonArea := fontButtonAreaDefault
fontsizeButtonArea := fontsizeButtonAreaDefault
fontSCI := fontSCIDefault
fontsizeSCI := fontsizeSCIDefault
mwheelModifier := mwheelModifierDefault
aottextHotkey := aottextHotkeyDefault
; Hardcoded (TODO):
quickHideHotkey := quickHideHotkeyDefault


; [user]
saveDir := saveDirDefault
trashDir := trashDirDefault
alwaysontop := alwaysontopDefault
lastUsedFile := ""
xPercentHidden := xPercentHiddenDefault
quickHideModifier1 := quickHideModifier1Default
quickHideModifier2 := quickHideModifier2Default


; [gui]
.windowPosX := windowPosXDefault
windowPosY := windowPosYDefault

clientWidth := clientWidthDefault
clientHeight := clientHeightDefault

windowWidth := 0
windowHeight := 0

windowPosVModeX := windowPosVModeXDefault
windowPosVModeY := windowPosVModeYDefault
windowWidthVMode := windowWidthVModeDefault
windowHeightVMode := windowHeightVModeDefault

; fixed:
localVersionFile := localVersionFileDefault
serverURL := serverURLDefault
serverURLExtension := serverURLExtensionDefault

updateServer := serverURL . appnameLower . serverURLExtension

syncAppDataRead()

; runtime variables:
unused := 0
hMain := 0
sci := {}
widthSCI := 0
heightSCI := 0
winIsShifted := 0
actuText := ""
isVMode := 0

allfiles := []
allfilesMaxCount := 0

isHidden := 0
contentIsTemporary := 0

; start global
if (FileExist(configFile)){
  readConfig()
  readGuiData()
}

if (!FileExist("Scintilla.dll")){
  msgbox, SEVERE ERROR file "Scintilla.dll" not found`, exiting %appname%!
  exitApp
}

buttonOKFunction := "quickHide"
buttonCANCELFunction := "exit"

checkDirectories()

refreshAllfiles()

mainWindow(starthidden)

readLastUsed()
 
OnMessage(0x200,"WM_MOUSEMOVE")
OnMessage(0x03,"WM_MOVE")

LShift & RButton::
{
  quickHide()
  return
}

~*RETURN::
{
  ControlGetFocus, hasFocusVar , A
  if (hasFocusVar == "Scintilla1"){
    sci.ENDUNDOACTION(1)
    sci.BEGINUNDOACTION(1)
  }
return
}
  
return

;------------------------------ syncAppDataRead ------------------------------
syncAppDataRead(){
  global configFile, localConfigDir, localConfigFile
  global clipboardSave
  
  if (!(FileExist(configFile))){
    if ((FileExist(localConfigFile))){
      FileCopy, %localConfigFile%, %configFile%, 1
    } else {
      saveConfig()
      saveGuiData()
      clipboard := clipboardSave
      
      reload
    }
  }

  return 
}
;----------------------------- syncAppDataWrite -----------------------------
syncAppDataWrite(){
  global configFile, localConfigDir
  
  if (!(FileExist(localConfigDir))){
    try {
      FileCreateDir, %localConfigDir%
    } catch e {
      msgbox, Could not create directory: %localConfigDir%
    }
  }
  
  if (FileExist(configFile)){
    if ((FileExist(localConfigDir))){
      FileCopy, %configFile%, %localConfigDir%*.*, 1
    }
  }

  return 
}
;----------------------------- checkDirectories -----------------------------
checkDirectories(){
  global saveDir, trashDir
  
  dir := pathToAbsolut(saveDir)
  if (!FileExist(dir))
    FileCreateDir, %dir%
  
  dir := pathToAbsolut(trashDir)
  if (!FileExist(dir))
    FileCreateDir, %dir%

  return 
}
;----------------------------- coordsScreenToApp -----------------------------
coordsScreenToApp(n){
  global dpiCorrect
  
  r := round(n / dpiCorrect)

  return r
}
;----------------------------- coordsAppToScreen -----------------------------
coordsAppToScreen(n){
  global dpiCorrect

  r := round(n * dpiCorrect)

  return r
}
;--------------------------------- mainWindow ---------------------------------
mainWindow(hide := 0) {
  global hMain, hSCI, sci, windowPosX, windowPosY, clientWidth, clientHeight
  global windowWidth, windowHeight
  global widthSCIScale, heightSCIScale, widthDEBUGScale
  global focusDummy, configFile
  global font, fontsize, fontDefault, fontsizeDefault
  global fontSCI, fontsizeSCI, fontSCIDefault, fontsizeSCIDefault
  global app, appname, appVersion
  global dpiCorrect, sciX, sciY, widthSCI, heightSCI, sciMarginLeft, sciMarginRight, sciMarginTop, sciMarginBottom
  global alwaysontop, isHidden, aottextHotkey
  global messageText, buttonOK, buttonCANCEL, buttonOKFunction, buttonCANCELFunction, buttonDone
  global buttonVMode
  
  Menu, MainMenuUpdate, Add,Check if new version is available, checkUpdate
  Menu, MainMenuUpdate, Add,Start updater, updateApp
  
  Menu, MainMenuSetup, Add,Always on top ON, alwaysontopOn
  Menu, MainMenuSetup, Add,Always on top OFF, alwaysontopOff
  Menu, MainMenuSetup, Add,Edit Config,editConfigAsText
  Menu, MainMenuSetup, Add,Edit Config (external editor),editConfig
  Menu, MainMenuSetup, Add,Show display parameter,displayParamShow
  
  Menu, MainMenuFilemanager, Add,Filemanager in _saved,openFilemanagerInSaved
  Menu, MainMenuFilemanager, Add,Filemanager in _trash,openFilemanagerInTrash
  
  Menu, MainMenuHelp, Add,Short-help offline,htmlViewerOffline
  Menu, MainMenuHelp, Add,Short-help online,htmlViewerOnline
  Menu, MainMenuHelp, Add,README online, htmlViewerOnlineReadme
  Menu, MainMenuHelp, Add,Open Github,openGithubPage

  Menu, MainMenu, Add,Save,saveForced
  Menu, MainMenu, Add,To trash,moveToTrash
  
  Menu, MainMenu, Add,H30,hideFor30
  Menu, MainMenu, Add,FM,:MainMenuFilemanager
  Menu, MainMenu, Add,Setup,:MainMenuSetup
  Menu, MainMenu, Add,Update,:MainMenuUpdate
  Menu, MainMenu, Add,Help,:MainMenuHelp
  

  Gui, guiMain:Destroy
  
  if (alwaysontop)
    Gui, guiMain:New, HwndhMain -0x30000 +E0x08000000 +Lastfound +OwnDialogs +Resize, %app%
  else
    Gui, guiMain:New, HwndhMain -0x30000 +Lastfound +OwnDialogs +Resize, Always on top! %app%
  
  Gui, guiMain:Font, s%fontsize%, %font%
  Gui, guiMain:Menu, MainMenu
  
  Gui, guiMain:Add, StatusBar,

  gui, guiMain:Add, button, x5 VbuttonOK GbuttonOK, ____________
  gui, guiMain:Add, button, x+m yp+0 VbuttonCANCEL GbuttonCANCEL, ____________
  
  arrow := Chr(0x21A7)
  checkmark := Chr(0x2714)
  gui, guiMain:Add, button, x+m yp+0 VbuttonDone GinsertDone, %checkmark% %arrow%
  gui, guiMain:Add, button, x+m yp+0 VbuttonVMode GVModeAction, VMode 
  
  
  gui, guiMain:Add, text, x+m yp+0 VmessageText r1, Dynamic button`, has no functionality at the moment!
  
  ; gui show 
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  
  buttonOKFunction := "quickHide"
  buttonCANCELFunction := "exit"
  
  guicontrol,guiMain:, buttonOK, HIDE
  guicontrol,guiMain:, buttonCANCEL, EXIT
  guicontrol,guiMain:, messageText, 
  
  aotStatus := ""
  if (!alwaysontop)
    aotStatus := " ""Allways on top"" is disabled! "
  else
    aotStatus := " ""Allways on top"" is enabled! "
    
  partSize := round(clientWidth / 2) - 50
  SB_SetParts(partSize, partSize)
  SB_SetText(" " . configFile, 1, 1)
  SB_SetText(" " . aotStatus, 2, 1)
  
  memory := "[" . getProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory ,3, 2)
  
;------------------------------------ SCI ------------------------------------ 
  calcSciPosSize()
  
  sci := new scintilla(hMain, sciX, sciY, widthSCI, heightSCI)
  sci.StyleClearAll()
  sci.SetCodePage(65001)

  sci.SetMarginWidthN(0, coordsAppToScreen(30)) ; Line number
  ; sci.SetMarginWidthN(1, 20)
  
  sci.SetMarginTypeN(0x1, 0x2)
  sci.SetWrapMode(TextWrap ? 0x1 : 0x0)
  sci.SetCaretLineBack(0xFFFF80)
  sci.SetCaretLineVisible(true)
  sci.SetCaretLineVisibleAlways(true)
  ; sci.SetLexer(0xC8)
  sci.SetLexer(2)
  sci.SetLexerLanguage("Autohotkey")
  sci.SETINDENTATIONGUIDES(SC_IV_LOOKBOTH)
  
  sci.SETUSETABS(0)
  sci.SETINDENT(2)
  sci.SETTABINDENTS(1)
  sci.SETBACKSPACEUNINDENTS(1)
  sci.SETVIEWWS(3)
  
  setfontSCI := fontSCI
  sci.StyleSetFont(32, setfontSCI)
  sci.StyleSetSize(32, fontsizeSCI) ; Font settings 
  sci.StyleClearAll()
  
  hSCI := sci.hwnd


  if (alwaysontop)
    WinSet, AlwaysOnTop,On, ahk_id %hMain%
  
  if (!hide){
    gui,guiMain:show
  } else {
    gui,guiMain:show
    gui,guiMain:hide
    isHidden := 1
    tipTop("Started " . app . "`nHotkey is: " . aottextHotkey, 9, 5000)
    sleep, 6000
  }
  
  WinGetPos,,, windowWidth, windowHeight
  
  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global hMain, hSCI, sci, windowPosX, windowPosY, clientWidth, clientHeight
  global windowWidth, windowHeight
  global dpiCorrect, sciX, sciY, widthSCI, heightSCI, sciMarginLeft, sciMarginRight, sciMarginTop, sciMarginBottom
  global widthSCIScale, heightSCIScale
  global alwaysontop, winIsShifted
  global isVMode, windowPosVModeX, windowPosVModeY, clientWidthVMode, clientHeightVMode
  global windowWidthVMode, windowHeightVMode
  global widthSCIVMode, heightSCIVMode, clientWidthVMode, clientHeightVMode

  if (A_EventInfo != 1) {
    if (!winIsShifted){
      ; not minimized
      if (!isVMode){
        clientWidth := A_GuiWidth
        clientHeight := A_GuiHeight
        
        calcSciPosSize()

        WinMove, ahk_id %hSCI%,, sciX, sciY, widthSCI, heightSCI
        
        partSize := round(clientWidth / 2) - 50
        SB_SetParts(partSize, partSize)
        
        WinGetPos,,, windowWidth, windowHeight
      } else {
        clientWidthVMode := A_GuiWidth
        clientHeightVMode := A_GuiHeight
        
        calcSciPosSizeVMode()

        WinMove, ahk_id %hSCI%,, sciX, sciY, widthSCIVMode, heightSCIVMode
        
        partSize := round(clientWidth / 2) - 50
        SB_SetParts(partSize, partSize)
        
        WinGetPos,,, windowWidthVMode, windowHeightVMode
      }
    }
  }
  
  return
}
;-------------------------------- insertDone --------------------------------
insertDone(){
  global sci
  
  checkmark := Chr(0x2714)
  sci.INSERTTEXT(-1," " . checkmark)

  return
}
;---------------------------------- WM_MOVE ----------------------------------
WM_MOVE(wParam, lParam){
  global hMain, windowPosX, windowPosY
  global winIsShifted
  global isVMode, windowPosVModeX, windowPosVModeY
  
  if (!winIsShifted ){
    if (!isVMode){
      WinGetPos, windowPosX, windowPosY,,, ahk_id %hMain%
    } else {
      WinGetPos, windowPosVModeX, windowPosVModeY,,, ahk_id %hMain%
    }
  }
  
  return
}
;-------------------------------- reActivate --------------------------------
reActivate(){
  global hMain
  
  WinActivate, ahk_id %hMain%

  return
}
;------------------------------- WM_MOUSEMOVE -------------------------------
WM_MOUSEMOVE(wParam, lParam){
  global hMain, sci, windowPosX, windowPosY, clientWidth, clientHeight
  global quickHideModifier1, quickHideModifier1Default, quickHideModifier2, quickHideModifier2Default
  global winIsShifted
  
  if (A_Gui == "guiMain"){
    if (GetKeyState(quickHideModifier1, "P") && GetKeyState(quickHideModifier2, "P")){
      saveIfChanged()
      quickHide()
    } else {
      if (winIsShifted)
        quickHide() ; move back
    }
    gui,guiMain:show
  }
  
  return
}
;--------------------------------- quickHide ---------------------------------
quickHide(){
  global hMain, windowPosX, windowPosY, clientWidth, clientHeight
  global windowWidth, windowHeight
  global winIsShifted, dpiCorrect, xPercentHidden
  global isVMode, windowPosVModeX, windowPosVModeY
  global windowWidthVMode, windowHeightVMode

  if (!winIsShifted){
    saveIfChanged()
    winIsShifted := 1
    windowPosXHidden := 0 - coordsAppToScreen(round(clientWidth * xPercentHidden))
    windowPosYHidden := round(A_ScreenHeight - dpiCorrect * 100)
    
    WinMove, ahk_id %hMain%,, windowPosXHidden, windowPosYHidden
    WinSet, Style, -0x10000 -0x80000, ahk_id %hMain%
  } else {
    if (!isVMode){
      WinMove, ahk_id %hMain%,, windowPosX, windowPosY
    } else {
      WinMove, ahk_id %hMain%,, windowPosVModeX, windowPosVModeY, windowWidthVMode, windowHeightVMode
    }
    WinSet, Style, +0x10000 +0x80000, ahk_id %hMain% 
    winIsShifted := 0
    reActivate()
  }

  
  return
}
;-------------------------------- calcSciPosSize --------------------------------
calcSciPosSize(){
  global sciX, sciY, widthSCI, heightSCI, clientWidth, clientHeight, dpiCorrect, font, fontsize
  
  sciX := coordsAppToScreen(5)
  sciY := coordsAppToScreen(18) + fonSizeToPixel(fontsize)
  
  paddingBottom := 20
  paddingRight := 10

  widthSCI := coordsAppToScreen(clientWidth  - paddingRight)
  heightSCI := coordsAppToScreen(clientHeight - paddingBottom) - sciY
  
  return
}
;-------------------------------- calcSciPosSize --------------------------------
calcSciPosSizeVMode(){
  global sciX, sciY, widthSCIVMode, heightSCIVMode, clientWidthVMode, clientHeightVMode, dpiCorrect, font, fontsize
  
  sciX := coordsAppToScreen(5)
  sciY := coordsAppToScreen(5) + 2 * fonSizeToPixel(fontsize)
  
  widthSCIVMode := coordsAppToScreen(clientWidthVMode - 10 )

  heightSCIVMode := coordsAppToScreen(clientHeightVMode * 0.92) - 3 * fonSizeToPixel(fontsize)
  
  return
}
;------------------------------ fonSizeToPixel ------------------------------
fonSizeToPixel(n){

    r := round(n * A_ScreenDPI / 72)

  return r
}
; mainwindow ...
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  return r
}
;-------------------------------- readConfig --------------------------------
readConfig() {
  global configFile
  global font, fontsize, fontSCI, fontsizeSCI, fontButtonArea, fontsizeButtonArea
  
  global fontDefault, fontsizeDefault, fontSCIDefault, fontsizeSCIDefault, fontButtonAreaDefault
  
  global mwheelModifier, mwheelModifierDefault
  global saveDir, alwaysontop, lastUsedFile, xPercentHidden, quickHideModifier1, quickHideModifier2
 
  global saveDirDefault, alwaysontopDefault, xPercentHiddenDefault
  global quickHideModifier1Default, quickHideModifier2Default
  global aottextHotkey, aottextHotkeyDefault
  global quickHideHotkey, quickHideHotkeyDefault
  
  ; config section:
  font := iniReadSave("font", "config", fontDefault)
  fontsize := iniReadSave("fontsize", "config", fontsizeDefault)
  fontButtonArea := iniReadSave("fontButtonArea", "config", fontButtonAreaDefault)
  fontsizeButtonArea := iniReadSave("fontsizeButtonArea", "config", fontsizeButtonAreaDefault)

  fontSCI := iniReadSave("fontSCI", "config", fontSCIDefault)

  fontsizeSCI := iniReadSave("fontsizeSCI", "config", fontsizeSCIDefault)
  mwheelModifier := iniReadSave("mwheelModifier", "config", mwheelModifierDefault)
  
  aottextHotkey := iniReadSave("aottextHotkey", "config", aottextHotkeyDefault)
  quickHideHotkey:= iniReadSave("quickHideHotkey", "config", quickHideHotkeyDefault)
  
  xPercentHidden := iniReadSave("xPercentHidden", "config", xPercentHiddenDefault)
  quickHideModifier1:= iniReadSave("quickHideModifier1", "config", quickHideModifier1Default)
  quickHideModifier2:= iniReadSave("quickHideModifier2", "config", quickHideModifier2Default)
  
  ; user section:
  saveDir := iniReadSave("saveDir", "user", saveDirDefault)
  alwaysontop := iniReadSave("alwaysontop", "user", alwaysontop)
  lastUsedFile := iniReadSave("lastUsedFile", "user","")
  
  Hotkey, %aottextHotkey%, hotkeyPressed, UseErrorLevel ON
  
  if ErrorLevel
  {
    msgbox, %ErrorLevel%
  }
  
  return
}
;-------------------------------- saveConfig --------------------------------
saveConfig(){
  global configFile
  global font, fontsize, fontSCI, fontsizeSCI, fontButtonArea, fontsizeButtonArea
  
  global fontDefault, fontsizeDefault, fontSCIDefault, fontsizeSCIDefault, fontButtonArea, fontButtonAreaDefault
  
  global mwheelModifier, mwheelModifierDefault
  global saveDir, alwaysontop, lastUsedFile
  global xPercentHidden, quickHideModifier1, quickHideModifier2
  global saveDir, aottextHotkey, quickHideHotkey
  
  ; config section:
  IniWrite, "%font%", %configFile%, config, font
  IniWrite, %fontsize%, %configFile%, config, fontsize
  IniWrite, "%fontButtonArea%", %configFile%, config, fontButtonArea
  IniWrite, %fontsizeButtonArea%, %configFile%, config, fontsizeButtonArea
  IniWrite, "%fontSCI%", %configFile%, config, fontSCI
  IniWrite, %fontsizeSCI%, %configFile%, config, fontsizeSCI
  IniWrite, "%mwheelModifier%", %configFile%, config, mwheelModifier
  IniWrite, "%aottextHotkey%", %configFile%, config, aottextHotkey
  IniWrite, "%quickHideHotkey%", %configFile%, config, quickHideHotkey
  IniWrite, %xPercentHidden%, %configFile%, config, xPercentHidden
  IniWrite, "%quickHideModifier1%", %configFile%, config, quickHideModifier1
  IniWrite, "%quickHideModifier2%", %configFile%, config, quickHideModifier2
   
  ; user section:
  IniWrite, "%saveDir%", %configFile%, user, saveDir
  IniWrite, %alwaysontop%, %configFile%, user, alwaysontop
  IniWrite, "%lastUsedFile%", %configFile%, user, lastUsedFile
  
  return
}
;-------------------------------- readGuiData --------------------------------
readGuiData(){
  global configFile, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault
  global dpiCorrect, dpiScale, dpiScaleDefault
  global windowPosVModeX, windowPosVModeY, clientWidthVMode, clientHeightVMode
  global windowWidthVMode, windowHeightVMode
  global windowPosVModeXDefault, windowPosVModeYDefault
  global windowWidthVModeDefault, windowHeightVModeDefault

  dpiScale := iniReadSave("dpiScale", "gui", dpiScaleDefault)
  windowPosX := iniReadSave("windowPosX", "gui", windowPosXDefault)
  windowPosY := iniReadSave("windowPosY", "gui", windowPosYDefault)
  clientWidth := iniReadSave("clientWidth", "gui", clientWidthDefault)
  clientHeight := iniReadSave("clientHeight", "gui", clientHeightDefault)
  
  windowPosVModeX := iniReadSave("windowPosVModeX", "gui", windowPosVModeXDefault)
  windowPosVModeY := iniReadSave("windowPosVModeY", "gui", windowPosVModeYDefault)
  windowWidthVMode := iniReadSave("windowWidthVMode", "gui", windowWidthVModeDefault)
  windowHeightVMode := iniReadSave("windowHeightVMode", "gui", windowHeightVModeDefault)

  dpiCorrect := A_ScreenDPI / dpiScale
  
  windowPosX := max(windowPosX,-50)
  windowPosY := max(windowPosY,-50)

  return
}
;-------------------------------- saveGuiData --------------------------------
saveGuiData(){
  global hMain, configFile, windowPosX, windowPosY, clientWidth, clientHeight
  global reserve1, reserve2
  global dpiCorrect, dpiScale
  global winIsShifted
  global windowPosVModeX, windowPosVModeY, clientWidthVMode, clientHeightVMode
  global windowWidthVMode, windowHeightVMode
  
  if (windowPosX < -100)
    windowPosX := 0
    
  if (windowPosY < -100)
    windowPosY := 0
    
  IniWrite, %dpiScale%, %configFile%, gui, dpiScale
  IniWrite, %windowPosX%, %configFile%, gui, windowPosX
  IniWrite, %windowPosY%, %configFile%, gui, windowPosY
  IniWrite, %clientWidth%, %configFile%, gui, clientWidth
  IniWrite, %clientHeight%, %configFile%, gui, clientHeight
  
  IniWrite, %windowPosVModeX%, %configFile%, gui, windowPosVModeX
  IniWrite, %windowPosVModeY%, %configFile%, gui, windowPosVModeY
  ;IniWrite, %clientWidthVMode%, %configFile%, gui, clientWidthVMode
  ;IniWrite, %clientHeightVMode%, %configFile%, gui, clientHeightVMode
  
  IniWrite, %windowWidthVMode%, %configFile%, gui, windowWidthVMode
  IniWrite, %windowHeightVMode%, %configFile%, gui, windowHeightVMode
  
  
 
  return
}
;------------------------------ getTextFromSCI ------------------------------
getTextFromSCI(){
  global configFile, sci 
  
  contentFromSCILen := sci.getLength()
  contentFromSCI := ""
  
  if (contentFromSCILen > 0)
    sci.GetText(contentFromSCILen, contentFromSCI)
  
  ; compensate sporadic read-errors
  if (StrLen(contentFromSCI) == 1)
    contentFromSCI := ""
  
  if (!InStr(contentFromSCI,"`n"))
    contentFromSCI := contentFromSCI . "`n" 

  return contentFromSCI
}
;------------------------------ GetSelectedText ------------------------------
; GetSelectedText() {
  ; global sci
  
  ; selLength := sci.GetSelText()
  ; VarSetCapacity(SelText, selLength, 0)
  ; sci.GetSelText(0, &SelText)
  ; content := StrGet(&SelText, selLength, "utf-8")
  ; Return StrGet(&SelText, selLength, "utf-8")
; }
;-------------------------------- setTextToSCI --------------------------------
setTextToSCI(t := "ERROR"){
  global sci
  
  sci.SETUNDOCOLLECTION(0)
  sci.SetText(unused, t)
  sci.SETUNDOCOLLECTION(1)
  sci.BEGINUNDOACTION(1)

  return
}
;------------------------------- readLastUsed -------------------------------
readLastUsed(){
  global configFile, sci, lastUsedFile, saveDir, actualContent
  global allfiles, allfilesMaxCount, alwaysontop, isHidden
  
  aotStatus := ""
  if (!alwaysontop)
    aotStatus := "[AOT is OFF!]"
  
  if (lastUsedFile != ""){
    filename := pathToAbsolut(saveDir) . lastUsedFile

    if (FileExist(filename)){
        file := FileOpen(filename,"r")
        newContent := file.Read()
        file.Close()
        actualContent := newContent
        sci.clearAll()
        setTextToSCI(newContent)
        sci.GrabFocus()

        if (!isHidden)
          showMessage(lastUsedFile)
      } else {
        readLatest()
      }
    } else {
      readLatest()
    }
    
    return
}
;-------------------------------- readLatest --------------------------------
readLatest(){
  global configFile, sci, lastUsedFile, saveDir, actualContent
  global allfiles, allfilesMaxCount, alwaysontop

  aotStatus := ""
  if (!alwaysontop)
    aotStatus := "[AOT is OFF!]"
    
  lastestFile := allfiles[allfilesMaxCount]
  if (lastestFile != ""){
    filename := pathToAbsolut(saveDir) . lastestFile
    
    if (FileExist(filename)){
      file := FileOpen(filename,"r")
      newContent := file.Read()
      file.Close()
      actualContent := newContent
      sci.clearAll()
      setTextToSCI(newContent)
      sci.GrabFocus()
      showMessage(lastestFile . " (most recent)")
    } else {
      msgbox, SEVERE ERROR, file not found: %filename%
    }
    
    lastUsedFile := lastestFile
    IniWrite, %lastUsedFile%, %configFile%, user, lastUsedFile
  } else {
    showMessage("Welcome to Aottext, please enter your text!")
  }

  return
}
;------------------------------- saveIfChanged -------------------------------
saveIfChanged(){
  global hMain, configFile, sci, lastUsedFile, saveDir, actualContent
  global actualContent, contentIsTemporary
  
  newContent := ""
  if (contentIsTemporary)
    newContent := actualContent
  else
    newContent := getTextFromSCI()
  
  if (StrLen(newContent) > 2){
    if (newContent != actualContent){
    
      filename := formatFilename()
      
      lastUsedFile := filename . ".txt"
      savePath := pathToAbsolut(saveDir) . lastUsedFile
      
      if (FileExist(savePath)){
        msgbox, SEVERE ERROR occurred: your realtimeclock has set the wrong time and/or the wrong date, exiting %appname%!
        exitApp
      }
      
      file := FileOpen(savePath, "w`n")
      
      if (!IsObject(file)){
        MsgBox ERROR, can't open "%savePath%" for writing!
      } else {
        file.Write(newContent)
        file.Close()
        actualContent := newContent
      }
      refreshAllfiles()
      showMessage(lastUsedFile)
    }
  }
  
  return
}
;------------------------------ formatFilename ------------------------------
formatFilename(){
  FormatTime, filename, %A_Now% T8, 'aot'_yyyyMMddhhmmss
  
  return filename
}
;-------------------------------- saveForced --------------------------------
saveForced(){
  global configFile, lastUsedFile, saveDir, actualContent, appname
  global actualContent, contentIsTemporary
  
  newContent := ""
  if (contentIsTemporary)
    newContent := actualContent
  else
    newContent := getTextFromSCI()

  filename := formatFilename()
  
  lastUsedFile := filename . ".txt"
  savePath := pathToAbsolut(saveDir) . lastUsedFile
  
  if (FileExist(savePath)){
    msgbox, SEVERE ERROR occurred: your realtimeclock has set the wrong time and/or the wrong date, exiting %appname%!
    exitApp
  }

  file := FileOpen(savePath, "w`n" , Encoding)
  
  if (!IsObject(file)){
    MsgBox ERROR, can't open "%savePath%" for writing!
  } else {
    file.Write(newContent)
    file.Close()
    actualContent := newContent
    
    IniWrite, %lastUsedFile%, %configFile%, user, lastUsedFile
      
    showMessage(lastUsedFile)
    
    refreshAllfiles()
    
    sleep, 1000
  }

  return
}
;--------------------------------- readFile ---------------------------------
readFile(filename){
  global sci, saveDir, actualContent

  if (FileExist(filename)){
      file := FileOpen(filename,"r")
      actualContent := file.Read()
      filename.Close()
      if (StrLen(actualContent) < 3 || !InStr(actualContent,"`n"))
        actualContent .= "`n`n"
      sci.clearAll()
      setTextToSCI(actualContent)
      sci.GrabFocus()
    } else {
      showMessageVol("File " . filename . " was not found!")
    }
    
    return
}
;-------------------------------- wrkPath --------------------------------
wrkPath(p){
  global wrkdir
  
  r := wrkdir . p
    
  return r
}
;------------------------------- pathToAbsolut -------------------------------
pathToAbsolut(p){
  
  r := p
  if (!InStr(p, ":"))
    r := wrkPath(p)
    
  if (SubStr(r,0,1) != "\")
    r .= "\"
    
  return r
}
;---------------------------- WheelUp / WheelDown ----------------------------
Alt & WheelDown::
{
  global allfiles, savedir, wheelPosition, allfilesMaxCount, newContent, actualContent
  
  newContent := getTextFromSCI()
  
  if (StrLen(newContent) < 3 || !InStr(newContent,"`n"))
    newContent .= "`n`n"
  
  if(newContent != actualContent){
    saveIfChanged()
    return
  }
  
  if (allfilesMaxCount > 0 && allfiles.haskey(wheelPosition)){
    readFile(pathToAbsolut(savedir) . allfiles[wheelPosition])

    if (wheelPosition == allfilesMaxCount)
      showMessage(allfiles[wheelPosition] . " (most recent)")
    else
      showMessage(allfiles[wheelPosition] . " (history)")
    
    wheelPosition += 1
    if (wheelPosition > allfilesMaxCount){
     wheelPosition := allfilesMaxCount
    }
  } else {
    showMessage("No files found in: """ . savedir . "")
  }
  
  return
}
;------------------------------- Alt & WheelUp -------------------------------
Alt & WheelUp::
{
  global allfiles, savedir, wheelPosition, allfilesMaxCount, newContent, actualContent
  
  newContent := getTextFromSCI()
  
  if(newContent != actualContent){
    saveIfChanged()
    return
  }
   
  if (allfilesMaxCount > 0 && allfiles.haskey(wheelPosition)){
    wheelPosition -= 1
    if (wheelPosition < 1)
     wheelPosition := 1
    
    readFile(pathToAbsolut(savedir) . allfiles[wheelPosition])
    
    if (wheelPosition != 1)
      showMessage(allfiles[wheelPosition] . " (history)")
    else
      showMessage(allfiles[wheelPosition] . " (oldest reached!)")
  }
  
  return
}
;--------------------------------- listFiles ---------------------------------
refreshAllfiles(holdWposition := false) {
  global saveDir, allfiles, allfilesMaxCount, lastUsedFile
  
  allfiles := []
  dir := pathToAbsolut(saveDir)
  Loop %dir%*.* {
    allfiles.push(A_LoopFileName)
  }
  allfilesMaxCount := allfiles.count()
  if (allfilesMaxCount > 0 && lastUsedFile == ""){
    showMessage("Last used file not found!")
    lastUsedFile := ""
  }
  
  if (!holdWposition)
    wheelPosition := allfilesMaxCount
  
  return
}
;------------------------------ guiMainGuiClose ------------------------------
guiMainGuiClose(){
  exit()

  return
}
;-------------------------------- editConfig --------------------------------
editConfig(){
  global hMain, configFile, appname
  global clipboardSave

  gui,guiMain:hide
  
  runWait, %configFile%
  
  msgbox, Press the "OK"-button after you saved the config-file (to reload %appname%)!
  
  saveIfChanged()
  saveGuiData()
  syncAppDataWrite()
  clipboard := clipboardSave

  reload

  return
}
;-------------------------------- updateApp --------------------------------
updateApp(){
  global appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension
  
  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found!
  }

  return
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
  global appnameLower
  
  Run, https://github.com/jvr-ks/%appnameLower%
  
  return
}
;-------------------------------- showMessage --------------------------------
showMessage(displayText := ""){
  global messageText, memDisplay
  
  guicontrol,guiMain:, messageText,%displayText%
  
  return
}
;------------------------------ showMessageVol ------------------------------
showMessageVol(displayText := "", timeout := 4){
  global messageText, actuText

  guicontrolGet,actuText,, messageText
  guicontrol,guiMain:, messageText,%displayText%
  
  t := -1000 * timeout
  settimer, showMessageActu, %t%

  return
}
;------------------------------ showMessageActu ------------------------------
showMessageActu(){
  global messageText, actuText
  
  guicontrol,guiMain:, messageText,%actuText%

  return
}
;------------------------------- alwaysontopOn -------------------------------
alwaysontopOn(){
  global hMain, alwaysontop

  alwaysontop := 1
    
  WinSet, AlwaysOnTop, On, ahk_id %hMain%
  exitAndReload()

  return
}
;------------------------------ alwaysontopOff ------------------------------
alwaysontopOff(){
  global hMain, alwaysontop

  alwaysontop := 0
    
  WinSet, AlwaysOnTop, On, ahk_id %hMain%
  exitAndReload()

  return
}
;--------------------------------- hideFor30 ---------------------------------
hideFor30(){
  global hMain, alwaysontop, isHidden
  
  WinSet, AlwaysOnTop, Off, ahk_id %hMain%
  gui,guiMain:hide
  isHidden := 1
  alwaysontop := 0
  settimer, hideFor30End, delete
  settimer, hideFor30End, -30000

  return
}
;------------------------------- hideFor30End -------------------------------
hideFor30End(){
  global hMain, alwaysontop, isHidden

  isHidden := 0
  alwaysontop := 1
  WinSet, AlwaysOnTop, On, ahk_id %hMain%
  gui,guiMain:show
  
  return
}
;------------------------------- hotkeyPressed -------------------------------
hotkeyPressed(){
  ; hotkey
  global hMain, windowPosX, windowPosY
  global winIsShifted, alwaysontop, isHidden
  
  if (isHidden){
    isHidden := 0
    alwaysontop := 1
    WinSet, AlwaysOnTop, On, ahk_id %hMain%
    gui,guiMain:show
    if (winIsShifted){
      WinMove, ahk_id %hMain%,, windowPosX, windowPosY
    }
  } else {
    isHidden := 1
    alwaysontop := 0
    WinSet, AlwaysOnTop, Off, ahk_id %hMain%
    gui,guiMain:hide
    saveIfChanged()
  }
  
  return
}
;----------------------------- checkUpdate -----------------------------
checkUpdate(){
  global appname, appnameLower, localVersionFile, updateServer

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(updateServer . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      msg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showMessageVol(msg1)
      
    } else {
      msg2 := "No new version available!"
      showMessageVol(msg2)
    }
  } else {
    msg := "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")"
    showMessageVol(msg)
  }

  return
}
;------------------------------ getLocalVersion ------------------------------
getLocalVersion(file){
  
  versionLocal := 0.000
  if (FileExist(file)){
    file := FileOpen(file,"r")
    versionLocal := file.Read()
    file.Close()
  }

  return versionLocal
}
;------------------------ getVersionFromGithubServer ------------------------
getVersionFromGithubServer(url){

  ret := "unknown!"

  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  { 
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200){
     ret := whr.ResponseText
    } else {
      msgArr := {}
      msgArr.push("Error while reading actual app version!")
      msgArr.push("Connection to:")
      msgArr.push(url)
      msgArr.push("failed!")
      msgArr.push(" URL -> clipboard")
      msgArr.push("Closing Updater due to an error!")
    
      errorExit(msgArr, url)
    }
  }
  catch e
  {
    ret := "error!"
  }

  return ret
} 
;-------------------------- openFilemanagerInTrash --------------------------
openFilemanagerInTrash(){
  global wrkpath
  
  p := wrkPath("_trash")
  run, explore %p%
  
  return
}
;-------------------------- openFilemanagerInSaved --------------------------
openFilemanagerInSaved(){
  global saveDir
  
  p := pathToAbsolut(saveDir)
  run, explore %p%
  
  return
}
;--------------------------- getProcessMemoryUsage ---------------------------
getProcessMemoryUsage(){

  OwnPID := DllCall("GetCurrentProcessId")
  static PMC_EX := "", size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

  if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", OwnPID)) {
    if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
      if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
        return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
    DllCall("CloseHandle", "ptr", hProcess)
    return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
  }
  return (ErrorLevel := 1) & 0
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1, t := 4000){

  s := StrReplace(msg,"^",",")
  
  toolX := round(A_ScreenWidth / 2)
  toolY := 2

  CoordMode,ToolTip,Screen
  
  toolTip,%s%, toolX, toolY, n
  
  WinGetPos, X,Y,W,H, ahk_class tooltips_class32

  toolX := (A_ScreenWidth / 2) - W / 2
  
  toolTip,%s%, toolX, toolY, n
  
  SetTimer, tipTopCloseAll, delete
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopCloseAll,%tvalue%
  }
  
  return
}
;-------------------------------- tipTopCloseAll --------------------------------
tipTopCloseAll(){
  
  Loop, 20
  {
    ToolTip,,,,%A_Index%
  }
  
  return
}

;-------------------------------- VModeAction --------------------------------
VModeAction(){
  global hMain, hSCI, windowPosX, windowPosY, clientWidth, clientHeight
  global windowWidth, windowHeight
  global fontsize
  global dpiCorrect, sciX, sciY, widthSCI
  global winIsShifted, isVMode
  global windowPosVModeX, windowPosVModeY, windowWidthVMode, windowHeightVMode
  global buttonVMode

  if (!winIsShifted){
    if (!isVMode){
      isVMode := 1
      guicontrol,guiMain:, buttonVMode, NMode
      WinMove, ahk_id %hMain%,, windowPosVModeX, windowPosVModeY, windowWidthVMode, windowHeightVMode
      
      sciXShifted := coordsAppToScreen(5)
      sciYShifted := coordsAppToScreen(5) + 2 * fonSizeToPixel(fontsize)
      
      widthSCIShifted := windowWidthVMode - coordsAppToScreen(30)
      heightSCIShifted := windowHeightVMode - coordsAppToScreen(120)

      WinMove, ahk_id %hSCI%,, sciXShifted, sciYShifted, widthSCIShifted, heightSCIShifted
  
    } else {
      isVMode := 0
      guicontrol,guiMain:, buttonVMode, VMode
      WinMove, ahk_id %hMain%,, windowPosX, windowPosY, windowWidth, windowHeight
      WinMove, ahk_id %hSCI%,, sciX, sciY, widthSCI, heightSCI
    }
  }

  return
}
;--------------------------------- errorExit ---------------------------------
errorExit(theMsgArr, clp := "") {
  
  msgComplete := ""
  for index, element in theMsgArr
  {
    msgComplete .= element . "`n"
  }
  msgbox,48,ERROR,%msgComplete%
  
  exit()
}
;-------------------------------- moveToTrash --------------------------------
moveToTrash(){
  global wrkdir, lastUsedFile, allfiles, wheelPosition
  global saveDir, trashDir
    
  fileToMove := lastUsedFile
  
  if (wheelPosition != allfiles.count()){
    fileToMove := allfiles[wheelPosition]
  }

  if (fileToMove != ""){
    fromPath := pathToAbsolut(saveDir) . fileToMove
    toPath := pathToAbsolut(trashDir) . fileToMove

    try {
      FileMove, %fromPath%, %toPath%, 1
    }
    catch e
    {
      tipTop("An exception was thrown:`n" . e)
      return
    }
  
    wheelPositionSave := wheelPosition
    refreshAllfiles(1)
    
    if (wheelPositionSave < allfiles.count()){
      newFileToUse :=  allfiles[wheelPositionSave]

      if (FileExist(pathToAbsolut(saveDir) . newFileToUse)){
        lastUsedFile := newFileToUse
        readLastUsed()
      } else {
        readLatest()
      }
    } else {
      refreshAllfiles(0)
      readLatest()
    }
  }
  
  return
}
;----------------------------- operationFinished -----------------------------
operationFinished(){

  ControlClick, Button1, aottext,,,, NA

  return
}
;----------------------------- editConfigAsText -----------------------------
editConfigAsText(){
  global configFile, sci, lastUsedFile, saveDir, allfilesMaxCount
  global actualContent, contentIsTemporary
  global buttonOK, buttonCANCEL, buttonOKFunction, buttonCANCELFunction
  
  if (FileExist(configFile)){
    saveIfChanged()
    
    actualContent := getTextFromSCI()
    
    FileCopy, configFile, "_" . configFile, 1
    FileRead, data, % configFile
    
    contentIsTemporary := 1
    setTextToSCI(data)
    
    buttonOKFunction := "saveNewConfig"
    guicontrol,guiMain:, buttonOK, SAVE
    
    buttonCANCELFunction := "resetToActualContent"
    guicontrol,guiMain:, buttonCANCEL, CANCEL
    
  } else {
    msgbox, SEVERE ERROR, Configfile "%configFile%" not found!
  }
  
  return
}

;-------------------------------- saveConfig --------------------------------
saveNewConfig(){
  global configFile, contentIsTemporary

  data:= getTextFromSCI()
  
  FileDelete, %configFile%
  FileAppend, %data%, %configFile%, UTF-16
  
  syncAppDataWrite()
  
  setTextToSCI(actualContent)
  contentIsTemporary := 0
  
  exitAndReload()
  
  return
}
;----------------------------- htmlViewerOffline -----------------------------
htmlViewerOffline(){
  htmlViewer(0)

  return
}
;----------------------------- htmlViewerOnline -----------------------------
htmlViewerOnline(){
  htmlViewer(1)

  return
}
;-------------------------- htmlViewerOnlineReadme --------------------------
htmlViewerOnlineReadme(){
  global appnameLower
  
  htmlViewer(1, "https://xit.jvr.de/" . appnameLower . "_readme.html")

  return
}
;------------------------------- htmlViewer -------------------------------
htmlViewer(forceOnline := 0, url := ""){
  global hMain, winIsShifted
  global hHtmlViewer, clientWidthHtmlViewer, clientHeightHtmlViewer
  global WB
  global appnameLower
  
  clientWidthHtmlViewer := coordsScreenToApp(A_ScreenWidth * 0.6)
  clientHeightHtmlViewer := coordsScreenToApp(A_ScreenHeight * 0.6)

  WinSet, Style, -alwaysOnTop, ahk_id %hMain% 
  winIsShifted := 1
  gui,guiMain:hide

  gui, htmlViewer:destroy
  gui, htmlViewer:New,-0x100000 -0x200000 +alwaysOnTop +resize +E0x08000000 hwndhHtmlViewer,Short Help
  gui, htmlViewer:Add, ActiveX, x0 y0 w%clientWidthHtmlViewer% h%clientHeightHtmlViewer% +VSCROLL +HSCROLL vWB, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge">

  gui, htmlViewer:Add, StatusBar
  SB_SetParts(400,300)
  SB_SetText("Use CTRL + mousewheel to zoom in/out!", 1, 1)

  htmlFile := "shorthelp.html"
  
  if(url == "")
    url := "https://xit.jvr.de/" . appnameLower . "_shorthelp.html"

  failed := 0
  if (!forceOnline){
    if (FileExist(htmlFile)){
      FileEncoding, UTF-8
      FileRead, data, %htmlFile%
      if (!ErrorLevel){
        doc := wb.document
        doc.write(data)
      } else {
        failed := 1
      }
    } else {
      failed := 1
    }
    if (failed){
      WB.Navigate(url)
      SB_SetText("(Local help-file not found, using online version) Use CTRL + mousewheel to zoom in/out!", 1, 1)
    }
  } else {
    WB.Navigate(url)
  }

  gui, htmlViewer:Show, center
  
  return
}
;----------------------------- htmlViewerGuiSize -----------------------------
htmlViewerGuiSize(){
  global hHtmlViewer, clientWidthHtmlViewer, clientHeightHtmlViewer
  global WB

  if (A_EventInfo != 1) {
    statusBarSize := 20
    clientWidthHtmlViewer := A_GuiWidth
    clientHeightHtmlViewer := A_GuiHeight - statusBarSize

    GuiControl, Move, WB, % "w" clientWidthHtmlViewer " h" clientHeightHtmlViewer
  }
  
  return
}
;---------------------------- htmlViewerGuiClose ----------------------------
htmlViewerGuiClose(){
  global hMain, ishidden, winIsShifted

  WinSet, Style, +alwaysOnTop, ahk_id %hMain% 
  winIsShifted := 0
  ishidden := 0
  gui,guiMain:show

  return
}
;------------------------------ showHintColored ------------------------------
showHintColored(handle, s := "", n := 3000, fg := "c00FF00", bg := "c000000", fontNew := "", fontsizeNew := 0){
  global font, fontsize
  
  ft := font
  fs := fontsize
  
  if (fontNew != "")
    ft := fontNew
    
  if (fontsizeNew != 0)
    fs := fontsizeNew
  
  Gui, hintColored:new, HWNDhChild
  Gui, hintColored:Font, s%fs%, %ft%
  Gui, hintColored:Font, c%fg%
  Gui, hintColored:Color, %bg%
  Gui, hintColored:Add, Text,, %s%
  Gui, hintColored:-Caption
  Gui, hintColored:+ToolWindow
  Gui, hintColored:+AlwaysOnTop
  Gui, hintColored:Show
  Sleep, n
  Gui, hintColored:Destroy
  
  return
}
;----------------------------- displayParamShow -----------------------------
displayParamShow(){
  global dpiCorrect, dpiScaleDefault
  global buttonOK, buttonCANCEL, buttonOKFunction, buttonCANCELFunction
  
  saveIfChanged()
  
  s := "Screenwidth: " . A_ScreenWidth . ", Screenheight: " . A_ScreenHeight . "`n"
  s .= "Screen-DPI: " . A_ScreenDPI . ", dpi-Scale: " . dpiScaleDefault . ", dpi-Correct: " . dpiCorrect

  setTextToSCI(s)
  sci.GrabFocus()
  
  buttonOKFunction := "resetToActualContent"
  guicontrol,guiMain:, buttonOK, Ok`, BACK!

  return
}
;--------------------------- resetToActualContent ---------------------------
resetToActualContent(){
  global actualContent, contentIsTemporary
  global buttonOK, buttonCANCEL, buttonOKFunction, buttonCANCELFunction

  sci.clearAll()
  setTextToSCI(actualContent)
  sci.GrabFocus()
  contentIsTemporary := 0
  
  guicontrol,guiMain:, buttonOK, 
  guicontrol,guiMain:, buttonCANCEL, 
  
  buttonOKFunction := "quickHide"
  buttonCANCELFunction := "exit"
  
  guicontrol,guiMain:, buttonOK, HIDE
  guicontrol,guiMain:, buttonCANCEL, EXIT

  return
}
;--------------------------------- buttonOK ---------------------------------
buttonOK(){
  global buttonOKFunction

  %buttonOKFunction%()

  return
}
;------------------------------- buttonCANCEL -------------------------------
buttonCANCEL(){
  global buttonCANCELFunction

  %buttonCANCELFunction%()

  return
}
;------------------------------- exitAndReload -------------------------------
exitAndReload(){
  global clipboardSave
  
  saveIfChanged()
  saveConfig()
  saveGuiData()
  syncAppDataWrite()
  clipboard := clipboardSave

  reload
}
;----------------------------------- Exit -----------------------------------
exit(){
  global clipboardSave
  
  saveIfChanged()
  saveConfig()
  saveGuiData()
  syncAppDataWrite()
  clipboard := clipboardSave
  ExitApp
}
;----------------------------------------------------------------------------

