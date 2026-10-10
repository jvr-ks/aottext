; aottextConfig.ahk
; Part of aottext.ahk

;-------------------------------- readConfig --------------------------------
readConfig(){
  global  
  local e
  
  ; config section:
  guiMainFontName := IniRead(configFile, "config", "guiMainFontName", guiMainfontNameDefault)
  guiMainFontSize := IniRead(configFile, "config", "guiMainFontSize", guiMainFontSizeDefault)

  guiMainEditFontName := IniRead(configFile, "config", "guiMainEditFontName", guiMainEditFontNameDefault)
  guiMainEditFontSize := IniRead(configFile, "config", "guiMainEditFontSize", guiMainEditFontSizeDefault)
  aottextHotkey := IniRead(configFile, "config", "aottextHotkey", aottextHotkeyDefault)
  
  insertUnicodeFile:= IniRead(configFile, "config", "insertUnicodeFile", insertUnicodeFileDefault)
  
  ; user section:
  selectedFolder := IniRead(configFile, "user", "selectedFolder", selectedFolderDefault)
  
  alwaysontop := IniRead(configFile, "user", "alwaysontop", alwaysontopDefault)
  autosmall := IniRead(configFile, "user", "autosmall", autosmallDefault)
  nowrapNMode := IniRead(configFile, "user", "nowrnowrapNMode", nowrapNModeDefault)
  nowrapVMode := IniRead(configFile, "user", "nowrnowrapNMode", nowrapVModeDefault)
  nowrapSMode := IniRead(configFile, "user", "nowrnowrapNMode", nowrapSModeDefault)
  nowrapFsMode := IniRead(configFile, "user", "nowrnowrapNMode", nowrapFsModeDefault)

  wheelPosition := IniRead(configFile, "user", "wheelPosition", 1)
  
  smodeTransparency := IniRead(configFile, "config", "smodeTransparency", 255)
  smodeAutoleave := IniRead(configFile, "config", "smodeAutoleave", 0)
  
  try
    Hotkey(aottextHotkey, hideGuiMainHotkey, "ON")
  catch as e {
    msgbox("Error creating Hotkey!`n`nwhat: " e.what "`nfile: " e.file 
    . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra,, 16) 
  }
}
;-------------------------------- saveConfig --------------------------------
saveConfig(){
  global
  
  ; config section:
  IniWrite "`"" guiMainFontName "`"", configFile, "config", "guiMainFontName"
  IniWrite guiMainFontSize, configFile, "config", "guiMainFontSize"
  IniWrite "`"" guiMainEditFontName "`"", configFile, "config", "guiMainEditFontName"
  IniWrite guiMainEditFontSize, configFile, "config", "guiMainEditFontSize"

  IniWrite "`"" aottextHotkey "`"", configFile, "config", "aottextHotkey"
  IniWrite "`"" insertUnicodeFile "`"", configFile, "config", "insertUnicodeFile"
  
  IniWrite smodeTransparency, configFile, "config", "smodeTransparency"
  
  ; user section:
  IniWrite "`"" selectedFolder "`"", configFile, "user", "selectedFolder"
  IniWrite alwaysontop, configFile, "user", "alwaysontop"
  IniWrite autosmall, configFile, "user", "autosmall"
  IniWrite nowrapNMode, configFile, "user", "nowrapNMode"
  IniWrite nowrapSMode, configFile, "user", "nowrapSMode"
  IniWrite nowrapVMode, configFile, "user", "nowrapVMode"
}
;-------------------------------- readGuiData --------------------------------
readGuiData(){
  global 
  
  guiMainPosX := IniRead(configFile, "gui", "guiMainPosX", guiMainPosXDefault)
  guiMainPosY := IniRead(configFile, "gui", "guiMainPosY", guiMainPosYDefault)
  
  ;guiMainWidth := IniRead(configFile, "gui", "guiMainWidth", guiMainWidthDefault)
  ;guiMainHeight := IniRead(configFile, "gui", "guiMainHeight", guiMainHeightDefault)
  guiMainClientWidth := IniRead(configFile, "gui", "guiMainClientWidth", guiMainClientWidthDefault)
  guiMainClientHeight := IniRead(configFile, "gui", "guiMainClientHeight", guiMainClientHeightDefault)
  
  guiMainVModePosX := IniRead(configFile, "gui", "guiMainVModePosX", guiMainVModePosXDefault)
  guiMainVModePosY := IniRead(configFile, "gui", "guiMainVModePosY", guiMainVModePosYDefault)
  guiMainVModeWidth := IniRead(configFile, "gui", "guiMainVModeWidth", guiMainVModeWidthDefault)
  guiMainVModeHeight := IniRead(configFile, "gui", "guiMainVModeHeight", guiMainVModeHeightDefault)
  guiMainClientVModeWidth := IniRead(configFile, "gui", "guiMainClientVModeWidth", guiMainClientVModeWidthDefault)
  guiMainClientVModeHeight := IniRead(configFile, "gui", "guiMainClientVModeHeight", guiMainClientVModeHeightDefault)
  
  guiMainSModePosX := IniRead(configFile, "gui", "guiMainSModePosX", guiMainSModePosXDefault)
  guiMainSModePosY := IniRead(configFile, "gui", "guiMainSModePosY", guiMainSModePosYDefault)
  ;guiMainSModeWidth := IniRead(configFile, "gui", "guiMainSModeWidth", guiMainSModeWidthDefault)
  ;guiMainSModeHeight := IniRead(configFile, "gui", "guiMainSModeHeight", guiMainSModeHeightDefault)
  guiMainClientSModeWidth := IniRead(configFile, "gui", "guiMainClientSModeWidth", guiMainClientSModeWidthDefault)
  guiMainClientSModeHeight := IniRead(configFile, "gui", "guiMainClientSModeHeight", guiMainClientSModeHeightDefault)

  guiMainFsModePosX := IniRead(configFile, "gui", "guiMainFsModePosX", guiMainFsModePosXDefault)
  guiMainFsModePosY := IniRead(configFile, "gui", "guiMainFsModePosY", guiMainFsModePosYDefault)
  guiMainFsModeWidth := IniRead(configFile, "gui", "guiMainFsModeWidth", guiMainFsModeWidthDefault)
  guiMainFsModeHeight := IniRead(configFile, "gui", "guiMainFsModeHeight", guiMainFsModeHeightDefault)
  guiMainClientFsModeWidth := IniRead(configFile, "gui", "guiMainClientFsModeWidth", guiMainClientFsModeWidthDefault)
  guiMainClientFsModeHeight := IniRead(configFile, "gui", "guiMainClientFsModeHeight", guiMainClientFsModeHeightDefault)

  ;dpiCorrect := A_ScreenDPI / dpiScale
  
  checkGuiMainposition()

}
;--------------------------- checkGuiMainposition ---------------------------
checkGuiMainposition(){
  global
  
  minPosLeft := 100 - guiMainClientWidth
  minPosTop := 50 - guiMainClientHeight
  maxPosLeft := (A_ScreenWidth - 200)
  maxPosTop := (A_ScreenHeight - 100)
  
  guiMainPosX := max(guiMainPosX, minPosLeft)
  guiMainPosY := max(guiMainPosY, minPosTop)
  
  guiMainPosX := min(guiMainPosX, maxPosTop)
  guiMainPosY := min(guiMainPosY, maxPosLeft)
}
;-------------------------------- editConfig --------------------------------
editConfig(*){
  global 
  local result

  guiMain.Hide()
  guiMainMode := 4
  
  RunWait(configFile)
  
  A_Clipboard := clipboardSave

  reloadScript()
}
;----------------------------------------------------------------------------


