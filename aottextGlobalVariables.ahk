; aottextGlobalVariables.ahk
; Part of aottext.ahk


;---------------------------- initGlobalVariables ----------------------------
initGlobalVariables(){
  global 
  
  ; dpi
  dpiCorrect := 1
  dpiScaleDefault := 96
  dpiScale := dpiScaleDefault
  inhibit := 0
  guiMainMode := 0 ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = hidden

  if ((0 + A_ScreenDPI == 0) || (A_ScreenDPI == 96))
    dpiCorrect := 1
  else
    dpiCorrect := A_ScreenDPI / dpiScale
    
    
  ; create a default layout
  ; NMode:
  guiMainWidthDefault := coordsScreenToApp(A_ScreenWidth * 0.4)
  guiMainHeightDefault := coordsScreenToApp(A_ScreenHeight * 0.2)

  guiMainClientWidthDefault := round(guiMainWidthDefault * 0.9)
  guiMainClientHeightDefault := round(guiMainHeightDefault * 0.9)
  
  guiMainPosXDefault := round(A_ScreenWidth / 2) - coordsAppToScreen(guiMainWidthDefault / 2)
  guiMainPosYDefault := round(A_ScreenHeight * 0.95) - coordsAppToScreen(guiMainHeightDefault)

  ; VMode:
  guiMainVModeWidthDefault := coordsScreenToApp(A_ScreenHeight * 0.25)
  guiMainVModeHeightDefault := coordsScreenToApp(A_ScreenWidth * 0.5)
  
  guiMainClientVModeWidthDefault := round(guiMainVModeWidthDefault * 0.9)
  guiMainClientVModeHeightDefault := round(guiMainVModeHeightDefault * 0.9)
  
  guiMainVModePosXDefault := A_ScreenWidth - coordsAppToScreen(guiMainVModeWidthDefault)
  guiMainVModePosYDefault :=  coordsAppToScreen(30)
  
  
  ; SMode:
  guiMainSModeWidthDefault := coordsScreenToApp(A_ScreenWidth * 0.3)
  guiMainSModeHeightDefault := coordsScreenToApp(A_ScreenHeight * 0.1)
  
  guiMainClientSModeWidthDefault := round(guiMainSModeWidthDefault * 0.9)
  guiMainClientSModeHeightDefault := round(guiMainSModeHeightDefault * 0.9)
  
  guiMainSModePosXDefault := 0
  guiMainSModePosYDefault := round(A_ScreenHeight * 0.95) - coordsAppToScreen(guiMainClientSModeHeightDefault)
  
  smodeTransparency := 111

  preferredFont1Default := "Consolas"
  preferredFont2Default := "Noto colored emoji"
  preferredFont3Default := "Segoe UI"
  preferredFont4Default := "OCR-A BT"
  
  ; config variables default value:
  saveDirDefault := "_saved\"
  trashDirDefault := "_trash\"
  guiMainfontNameDefault := "Segoe UI"
  guiMainFontSizeDefault := 9
  guiMainEditFontNameDefault := "Consolas"
  guiMainEditFontSizeDefault := 10
  insertUnicodeFileDefault := "insertUnicode.txt"

  alwaysontopDefault := 1
  autosmallDefault := 1
  nowrapNModeDefault := 0
  nowrapVModeDefault := 0
  nowrapSModeDefault := 0
  
  aottextHotkeyDefault := "!a"
  buttonOKfunctionSelection := 1

  localVersionFileDefault := "version.txt"
  serverURLDefault := "https://github.com/jvr-ks/"
  serverURLExtensionDefault := "/raw/main/"

  ; config variables:

  ; [config]
  guiMainFontName := guiMainfontNameDefault
  guiMainFontSize := guiMainFontSizeDefault
  guiMainEditFontName := guiMainEditFontNameDefault
  guiMainEditFontSize := guiMainEditFontSizeDefault
  aottextHotkey := aottextHotkeyDefault
  insertUnicodeFile := insertUnicodeFileDefault

  ; [user]
  saveDir := saveDirDefault
  trashDir := trashDirDefault
  alwaysontop := alwaysontopDefault
  autosmall := autosmallDefault
  nowrapNMode := nowrapNModeDefault
  nowrapVMode := nowrapVModeDefault
  nowrapSMode := nowrapSModeDefault
  
  ; [gui]
  guiMainPosX := guiMainPosXDefault
  guiMainPosY := guiMainPosYDefault
  guiMainWidth := guiMainWidthDefault
  guiMainHeight := guiMainHeightDefault
  guiMainClientWidth := guiMainClientWidthDefault
  guiMainClientHeight := guiMainClientHeightDefault

  guiMainVModePosX := guiMainVModePosXDefault
  guiMainVModePosY := guiMainVModePosYDefault
  guiMainVModeWidth := guiMainVModeWidthDefault
  guiMainVModeHeight := guiMainVModeHeightDefault
  guiMainClientVModeWidth := guiMainClientVModeWidthDefault
  guiMainClientVModeHeight := guiMainClientVModeHeightDefault

  guiMainSModePosX := guiMainSModePosXDefault
  guiMainSModePosY := guiMainSModePosYDefault
  guiMainSModeWidth := guiMainSModeWidthDefault
  guiMainSModeHeight := guiMainSModeHeightDefault
  guiMainClientSModeWidth := guiMainClientSModeWidthDefault
  guiMainClientSModeHeight := guiMainClientSModeHeightDefault
  
  preferredFont1 := preferredFont1Default
  preferredFont2 := preferredFont2Default
  preferredFont3 := preferredFont3Default
  preferredFont4 := preferredFont4Default
  
  ; fixed:
  localVersionFile := localVersionFileDefault
  serverURL := serverURLDefault
  serverURLExtension := serverURLExtensionDefault

  updateServer := serverURL . appnameLower . serverURLExtension

  ; runtime variables:
  actuText := ""
  contentIsTemporary := 0
  allfiles := []
  allfilesMaxCount := 0
  currentlyDisplayed := "None"
  lastUsedFile := "None"

  ; gui variables

  ; limits
  minPosTop := -100
  minPosLeft := -100 
  maxPosTop := (A_ScreenHeight - 100)
  maxPosLeft := (A_ScreenWidth - 200)
  
  ; editarea
  paddingLeft := 2
  paddingRight := 8
  paddingTop := 5
  paddingBottom := 27
  
  getFontsList()
}


;----------------------------------------------------------------------------

