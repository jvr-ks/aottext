/*
 *********************************************************************************
 * 
 * aottext.ahk
 * 
 * Fileencoding: UTF-8 
 * Autohotkey internal: UTF-16
 * 
 * Version: look at appVersion := below
 * 
 * Copyright (c) 2024 jvr.de. All rights reserved.
 *
 *
 *********************************************************************************
*/
/*
 *********************************************************************************
 * 
 * GNU GENERAL PUBLIC LICENSE
 * 
 * A copy is included in the file "license.txt"
 *
  *********************************************************************************
*/


;------------------------------  ------------------------------
#Requires AutoHotkey v1.0

#NoEnv
#SingleInstance Force
#InstallKeybdHook

#Include, Lib\sci.ahk

license := ""


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
appVersion := "0.056"

bit := (A_PtrSize==8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit=="64" ? "" : bit)


app := appName . " " . appVersion   


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
autohideDefault := 1
mwheelModifierDefault := "!"
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


; user
saveDir := saveDirDefault
trashDir := trashDirDefault
alwaysontop := alwaysontopDefault
autohide := autohideDefault
lastUsedFile := ""
xPercentHidden := xPercentHiddenDefault
quickHideModifier1 := quickHideModifier1Default
quickHideModifier2 := quickHideModifier2Default

; gui
windowPosX := windowPosXDefault
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

; editarea
paddingTop := 20
paddingBottom := 25
paddingLeft := 5
paddingRight := 5

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

windowPosXHidden := 0 
windowPosYHidden := 0

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

;wDown := mwheelModifier . "WheelDown"
;wUp := mwheelModifier . "WheelUp"

;hotkey, %wDown%, historyFoward
;hotkey, %wUp%, historyBackward

LShift & RButton::
{
  quickHide()
  return
}

~*enter::
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
  global alwaysontop, autohide, isHidden, aottextHotkey
  global messageText, buttonOK, buttonCANCEL, buttonOKFunction, buttonCANCELFunction, buttonDone, buttontoDo
  global buttonVMode
  global windowPosXHidden, windowPosYHidden, xPercentHidden
  
  Menu, MainMenuUpdate, Add,Check if new version is available, checkUpdate
  Menu, MainMenuUpdate, Add,Start updater, updateApp
  
  if (autohide)
    Menu, MainMenuSetup, Add,Disable AUTOHIDE, autohideOff
  else
    Menu, MainMenuSetup, Add,Enable AUTOHIDE, autohideOn
    
  if (alwaysontop)
    Menu, MainMenuSetup, Add,Disable AOT, alwaysontopOff
  else
    Menu, MainMenuSetup, Add,Enable AOT (Always on top), alwaysontopOn
  
  Menu, MainMenuSetup, Add,Edit Config,editConfigAsText
  Menu, MainMenuSetup, Add,Edit Config (external editor),editConfig
  Menu, MainMenuSetup, Add,Show display parameter,displayParamShow
  
  Menu, MainMenuFilemanager, Add,Filemanager in _saved,openFilemanagerInSaved
  Menu, MainMenuFilemanager, Add,Filemanager in _trash,openFilemanagerInTrash
  
  Menu, MainMenuHideTime, Add,Hide for 30 seconds,ht30
  Menu, MainMenuHideTime, Add,Hide for 1 minute,ht60
  Menu, MainMenuHideTime, Add,Hide for 2 minutes,ht120
  Menu, MainMenuHideTime, Add,Hide for 5 minutes,ht300
  
  Menu, MainMenuHelp, Add,Short-help offline,htmlViewerOffline
  Menu, MainMenuHelp, Add,Short-help online,htmlViewerOnline
  Menu, MainMenuHelp, Add,README online, htmlViewerOnlineReadme
  Menu, MainMenuHelp, Add,Open Github,openGithubPage

  Menu, MainMenu, Add,Save,saveForced
  Menu, MainMenu, Add,To trash,moveToTrash
  
  Menu, MainMenu, Add,Ht,:MainMenuHideTime
  Menu, MainMenu, Add,FM,:MainMenuFilemanager
  Menu, MainMenu, Add,Setup,:MainMenuSetup
  Menu, MainMenu, Add,Update,:MainMenuUpdate
  Menu, MainMenu, Add,Help,:MainMenuHelp
  

  Gui, guiMain:Destroy
  ; -0x30000 -> not minimizable, +E0x08000000 -> not in tasklist
  if (alwaysontop)
    Gui, guiMain:New, HwndhMain -0x30000 +E0x08000000 +Lastfound +OwnDialogs +Resize , %app%
  else
    Gui, guiMain:New, HwndhMain +Lastfound +OwnDialogs +Resize , %app%
  
  Gui, guiMain:Font, s%fontsize%, %font%
  Gui, guiMain:Menu, MainMenu
  
  Gui, guiMain:Add, StatusBar,

  Gui, guiMain:Add, button, x5 VbuttonOK GbuttonOKfunc, ____________
  Gui, guiMain:Add, button, x+m yp+0 VbuttonCANCEL GbuttonCANCELfunc, ____________
  
  Gui, guiMain:Add, button, x+m yp+0 VbuttonVMode GVModeAction, VMode 
  
  ; "↧" Downwards arrow from bar(0x21A7)
  ; "✔" Heavy Check Mark Chr(0x2714)
  ; "◯" Large Circle Chr(0x25EF)
  
  arrow := Chr(0x21A7)
  checkmark := Chr(0x2714)
  Gui, guiMain:Add, button, x+m yp+0 VbuttonDone GinsertDone, %checkmark% %arrow%
  
  toDo := Chr(0x25EF)
  Gui, guiMain:Add, button, x+m yp+0 VbuttontoDo GinsertOpen, %toDo% %arrow%
  
  space70 := StrReplace(Format("{:070}",0),0," ")
  Gui, guiMain:Add, text, x+m yp+0 VmessageText r1,%space70%
  
  ; gui show 
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  
  buttonOKFunction := "quickHide"
  buttonCANCELFunction := "exit"
  
  guicontrol,guiMain:, buttonOK, HIDE
  guicontrol,guiMain:, buttonCANCEL, EXIT
  ; guicontrol,guiMain:, messageText, 
  
  partSize1 := round(clientWidth * 0.5)
  partSize2 := round(clientWidth * 0.3)
  SB_SetParts(partSize1, partSize2)
  SB_SetText(" " . configFile, 1, 1)
  ; SB_SetText(" " . aotStatus, 2, 1)
  setAotStatus()
  
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
  
  Hotkey, IfWinActive, %appname%
  Hotkey, ^f, findText
  
  if (autohide){
    setTimer,checkFocus,delete
    setTimer,checkFocus,3000
  }
  
  return
}
;--------------------------------- findText ---------------------------------
findText(){
  global hMain, hEnterFindText, enterFindText
  
  fgColor := "cffffff", bgColor := "a900ff"

  Gui, enterFindText:new, HWNDhEnterFindText +parentGuiMain +ownerGuiMain +0x80000000
  Gui, enterFindText:Color, %bgColor%
  Gui, enterFindText:Font, %fgColor%
  ;Gui, enterFindText:Add, Text,, Please enter the search-text:
  Gui, enterFindText:Add, Text,, Sorry`, text-search is under construction!
  Gui, enterFindText:Font, "c000000"
  Gui, enterFindText:Add, Edit, w200 VenterFindText
  Gui, enterFindText:Add, Button, GenterFindTextOk, OK
  Gui, enterFindText:-Caption
  Gui, enterFindText:+ToolWindow
  Gui, enterFindText:+AlwaysOnTop
  Gui, enterFindText:Show
  WinCenter(hMain, hEnterFindText, 1)

  return
}
;------------------------------ enterFindTextOk ------------------------------
enterFindTextOk(){
  global enterFindText

  Gui, enterFindText:submit
  Gui, enterFindText:Destroy

  VarSetCapacity(characterRange, 0)
  
  NumPut(0, characterRange , 0, Int64)
  l := StrLen(actualContent) * 2
  NumPut(l, characterRange , 64, Int64)
  
  VarSetCapacity(findStruct, 0)
  
  NumPut(Number, findStruct , Offset, Type)
  
  GrantedCapacity := VarSetCapacity(TargetVar , RequestedCapacity, FillByte)
  NumPut(Number, VarOrAddress , Offset, Type)
  Number := NumGet(VarOrAddress , Offset, Type)
  
  ; pos := SCI_FINDTEXTFULL(0x0, findStruct)
  
  sci.GOTOPOS(pos)

  return
}
;----------------------------- SCI_FINDTEXTFULL -----------------------------
; SCI_FINDTEXTFULL(int searchFlags, Sci_TextToFindFull *ft){ ; → position
; searchFlags -> SCFIND_NONE -> 0x0, This structure extends Sci_TextToFind to support huge documents on Win32.

  ; struct Sci_TextToFindFull {
      ; struct Sci_CharacterRangeFull chrg;     ; range to search
      ; const char *lpstrText;                ; the search pattern (zero terminated)
      ; struct Sci_CharacterRangeFull chrgText; ; returned as position of matching text
  ; }

  ; struct Sci_CharacterRange {
      ; long cpMin;
      ; long cpMax;
  ; }

;  return
;}
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
  global windowPosXHidden, windowPosYHidden, xPercentHidden

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
      windowPosXHidden := 0 - coordsAppToScreen(round(A_GuiWidth * xPercentHidden))
      windowPosYHidden := round(A_ScreenHeight - dpiCorrect * 100)
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
;--------------------------------- insertOpen ---------------------------------
insertOpen(){
  global sci
  
  checkmark := Chr(0x25EF)
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
  global hMain, autohide
  
  WinActivate, ahk_id %hMain%
  
  if (autohide){
    setTimer,checkFocus,delete
    setTimer,checkFocus,3000
  }

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
  global winIsShifted, dpiCorrect
  global isVMode, windowPosVModeX, windowPosVModeY
  global windowWidthVMode, windowHeightVMode
  global windowPosXHidden, windowPosYHidden

  if (!winIsShifted){
    saveIfChanged()
    winIsShifted := 1
    
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
  global paddingTop, paddingBottom, paddingLeft, paddingRight
  
  sciX := coordsAppToScreen(paddingLeft)
  sciY := coordsAppToScreen(paddingTop) + fonSizeToPixel(fontsize)
  
  widthSCI := coordsAppToScreen(clientWidth - paddingLeft - paddingRight)
  heightSCI := coordsAppToScreen(clientHeight - paddingBottom - paddingTop) -fonSizeToPixel(fontsize)
  
  return
}
;-------------------------------- calcSciPosSize --------------------------------
calcSciPosSizeVMode(){
  global sciX, sciY, widthSCIVMode, heightSCIVMode, clientWidthVMode, clientHeightVMode, dpiCorrect, font, fontsize
  global paddingTop, paddingBottom, paddingLeft, paddingRight
  
  sciX := coordsAppToScreen(paddingLeft)
  sciY := coordsAppToScreen(paddingTop) + fonSizeToPixel(fontsize)
  
  widthSCIVMode := coordsAppToScreen(clientWidthVMode - paddingLeft - paddingRight )

  heightSCIVMode := coordsAppToScreen(clientHeightVMode - paddingBottom - paddingTop) - fonSizeToPixel(fontsize)
  
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
  global saveDir, alwaysontop, autohide, lastUsedFile, xPercentHidden, quickHideModifier1, quickHideModifier2
 
  global saveDirDefault, alwaysontopDefault, autohideDefault, xPercentHiddenDefault
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
  alwaysontop := iniReadSave("alwaysontop", "user", alwaysontopDefault)
  autohide := iniReadSave("autohide", "user", autohideDefault)
  
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
  global saveDir, alwaysontop, autohide, lastUsedFile
  global xPercentHidden, quickHideModifier1, quickHideModifier2
  global saveDir, aottextHotkey, quickHideHotkey
  
  ; force to UTF-8-RAW if new file
  FileAppend,,%configFile%, UTF-8-RAW
  
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
  IniWrite, %autohide%, %configFile%, user, autohide
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
  
  WinGet, MinMaxState, MinMax, A
  if (MinMaxState == 0){
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
    
    IniWrite, %windowWidthVMode%, %configFile%, gui, windowWidthVMode
    IniWrite, %windowHeightVMode%, %configFile%, gui, windowHeightVMode
  }
 
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
    
    sleep, 2000
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
;historyFoward() 
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
    showMessage("No files found in: " . savedir)
  }
  
  return
}
;------------------------------- Alt & WheelUp -------------------------------
Alt & WheelUp::
;historyBackward() 
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
;-------------------------------- autohideOn --------------------------------
autohideOn(){
  global autohide, alwaysontop
  
  autohide := 1
  
  exitAndReload()
  
  return
}
;-------------------------------- autohideOff --------------------------------
autohideOff(){
  global autohide
  
  autohide := 0
  setTimer,checkFocus,delete
  
  exitAndReload()

  return
}
;------------------------------- setAotStatus -------------------------------
setAotStatus(){
  global alwaysontop, autohide
  
  part1 := alwaysontop ? "AOT":""
  part2 := autohide ? "AUTOHIDE":""
  aotStatus := trim(part1 . " " . part2)
  
  SB_SetText(" " . aotStatus, 2, 1)

  return
}
;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global hMain, winIsShifted, autohide

  if (autohide){
    h := WinActive("A")
    if (hMain != h)
      if (!winIsShifted)
        quickHide()
  }
  
  return
}
;------------------------------- alwaysontopOn -------------------------------
alwaysontopOn(){
  global hMain, alwaysontop

  alwaysontop := 1
  
  exitAndReload()

  return
}
;------------------------------ alwaysontopOff ------------------------------
alwaysontopOff(){
  global hMain, alwaysontop

  alwaysontop := 0
    
  exitAndReload()

  return
}
;----------------------------------- ht30 -----------------------------------
ht30(){
  hideForT(30000)
  return
}
;----------------------------------- ht60 -----------------------------------
ht60(){
  hideForT(60000)
  return
}
;----------------------------------- ht120 -----------------------------------
ht120(){
  hideForT(120000)
  return
}
;----------------------------------- ht300 -----------------------------------
ht300(){
  hideForT(300000)
  return
}
;--------------------------------- hideFor30 ---------------------------------
hideForT(t){
  global hMain, alwaysontop, isHidden
  
  WinSet, AlwaysOnTop, Off, ahk_id %hMain%
  gui,guiMain:hide
  isHidden := 1
  alwaysontop := 0
  tout := -1 * t
  settimer, hideForTend, delete
  settimer, hideForTend, %tout%

  return
}
;------------------------------- hideFor30End -------------------------------
hideForTend(){
  global hMain, alwaysontop, isHidden

  isHidden := 0
  alwaysontop := 1
  WinSet, AlwaysOnTop, On, ahk_id %hMain%
  gui,guiMain:show
  
  return
}
;------------------------------- hotkeyPressed -------------------------------
hotkeyPressed(){
  ; hotkey: "Alt + a" is default
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
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
          ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
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
      widthSCIShifted := windowWidthVMode - coordsAppToScreen(30)
      heightSCIShifted := windowHeightVMode - coordsAppToScreen(120)
      
      guicontrol,guiMain:, buttonVMode, NMode
      WinMove, ahk_id %hMain%,, windowPosVModeX, windowPosVModeY, windowWidthVMode, windowHeightVMode
      WinMove, ahk_id %hSCI%,, sciX, sciY, widthSCIShifted, heightSCIShifted
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
  FileAppend, %data%, %configFile%, UTF-8-RAW
  
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

  Gui, htmlViewer:destroy
  Gui, htmlViewer:New,-0x100000 -0x200000 +alwaysOnTop +resize +E0x08000000 hwndhHtmlViewer,Short Help
  
  ; Shell.Explorer:
  Gui, htmlViewer:Add, ActiveX, x0 y0 w%clientWidthHtmlViewer% h%clientHeightHtmlViewer% +VSCROLL +HSCROLL vWB, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge">

  Gui, htmlViewer:Add, StatusBar
  SB_SetParts(400,300)
  SB_SetText("Use CTRL + mousewheel to zoom in/out!", 1, 1)

  htmlFile := "shorthelp.html"
  
  if(url == "")
    url := "https://xit.jvr.de/" . appnameLower . "_shorthelp.html"

  failed := 0
  if (!forceOnline){
    if (FileExist(htmlFile)){
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

  Gui, htmlViewer:Show, center
  
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
buttonOKfunc(){
  global buttonOKFunction

  %buttonOKFunction%()

  return
}
;------------------------------- buttonCANCEL -------------------------------
buttonCANCELfunc(){
  global buttonCANCELFunction

  %buttonCANCELFunction%()

  return
}
;--------------------------------- WinCenter ---------------------------------
; from: https://www.autohotkey.com/board/topic/92757-win-center/
WinCenter(hMain, hChild, Visible := 1) {
    DetectHiddenWindows On
    WinGetPos, X, Y, W, H, ahk_ID %hMain%
    WinGetPos, _X, _Y, _W, _H, ahk_ID %hChild%
    If Visible {
        SysGet, MWA, MonitorWorkArea, % WinMonitor(hMain)
        X := X+(W-_W)//2, X := X < MWALeft ? MWALeft+5 : X, X := (X + _W) > MWARight ? MWARight-_W-5 : X
        Y := Y+(H-_H)//2, Y := Y < MWATop ? MWATop+5 : Y, Y := (Y + _H) > MWABottom ? MWABottom-_H-5 : Y
    } Else X := X+(W-_W)//2, Y := Y+(H-_H)//2
    WinMove, ahk_ID %hChild%,, %X%, %Y%
    WinShow, ahk_ID %hChild%
    }
;-------------------------------- WinMonitor --------------------------------
WinMonitor(hwnd, Center := 1) {
    SysGet, MonitorCount, 80
    WinGetPos, X, Y, W, H, ahk_ID %hwnd%
    Center ? (X := X+(W//2), Y := Y+(H//2))
    loop %MonitorCount% {
      SysGet, Mon, Monitor, %A_Index%
      if (X >= MonLeft && X <= MonRight && Y >= MonTop && Y <= MonBottom)
          Return A_Index
    }
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

