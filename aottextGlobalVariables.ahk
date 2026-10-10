; aottextGlobalVariables.ahk
; Part of aottext.ahk


;---------------------------- initGlobalVariables ----------------------------
initGlobalVariables(){
  global
  
  inhibit := 0
  
  guiMainMode := 0 ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = FsMode,  4 = hidden

  ; create a default layout
  ; NMode:
  guiMainWidthDefault := A_ScreenWidth * 0.4
  guiMainHeightDefault := A_ScreenHeight * 0.2

  guiMainClientWidthDefault := round(guiMainWidthDefault * 0.9)
  guiMainClientHeightDefault := round(guiMainHeightDefault * 0.9)
  
  guiMainPosXDefault := round(A_ScreenWidth / 2) - (guiMainWidthDefault / 2)
  guiMainPosYDefault := round(A_ScreenHeight * 0.95) - (guiMainHeightDefault)

  ; VMode:
  guiMainVModeWidthDefault := A_ScreenHeight * 0.25
  guiMainVModeHeightDefault := A_ScreenWidth * 0.5
  
  guiMainClientVModeWidthDefault := round(guiMainVModeWidthDefault * 0.9)
  guiMainClientVModeHeightDefault := round(guiMainVModeHeightDefault * 0.9)
  
  guiMainVModePosXDefault := A_ScreenWidth - (guiMainVModeWidthDefault)
  guiMainVModePosYDefault :=  30
  
  
  ; SMode:
  guiMainSModeWidthDefault := A_ScreenWidth * 0.3
  guiMainSModeHeightDefault := A_ScreenHeight * 0.1
  
  guiMainClientSModeWidthDefault := round(guiMainSModeWidthDefault * 0.9)
  guiMainClientSModeHeightDefault := round(guiMainSModeHeightDefault * 0.9)
  
  guiMainSModePosXDefault := 0
  guiMainSModePosYDefault := round(A_ScreenHeight * 0.95) - guiMainClientSModeHeightDefault
  
  smodeTransparency := 111
  smodeAutoleave := 0
  
  ; FsMode:
  guiMainFsModeWidthDefault := A_ScreenWidth
  guiMainFsModeHeightDefault := A_ScreenHeight

  guiMainClientFsModeWidthDefault := round(guiMainFsModeWidthDefault * 0.9)
  guiMainClientFsModeHeightDefault := round(guiMainFsModeHeightDefault * 0.9)
  
  guiMainFsModePosXDefault := 0
  guiMainFsModePosYDefault := 0

  ; config variables default value:
  selectedFolderDefault := "_saved\"
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
  nowrapFsModeDefault := 0
  
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
  selectedFolder := selectedFolderDefault
  trashDir := trashDirDefault
  alwaysontop := alwaysontopDefault
  autosmall := autosmallDefault
  nowrapNMode := nowrapNModeDefault
  nowrapVMode := nowrapVModeDefault
  nowrapSMode := nowrapSModeDefault
  nowrapFsMode := nowrapFsModeDefault
  
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
  
  guiMainFsModePosX := guiMainFsModePosXDefault
  guiMainFsModePosY := guiMainFsModePosYDefault
  guiMainFsModeWidth := guiMainFsModeWidthDefault
  guiMainFsModeHeight := guiMainFsModeHeightDefault
  guiMainClientFsModeWidth := guiMainClientFsModeWidthDefault
  guiMainClientFsModeHeight := guiMainClientFsModeHeightDefault
  
  preferredFontDefault := "Noto colored emoji" 
  
  preferredFont1 := preferredFontDefault
  preferredFont2 := preferredFontDefault
  preferredFont3 := preferredFontDefault
  preferredFont4 := preferredFontDefault
  preferredFont5 := preferredFontDefault
  preferredFont6 := preferredFontDefault
  preferredFont7 := preferredFontDefault
  preferredFont8 := preferredFontDefault
  preferredFont9 := preferredFontDefault
    
  ; fixed:
  localVersionFile := localVersionFileDefault
  serverURL := serverURLDefault
  serverURLExtension := serverURLExtensionDefault

  updateServer := serverURL . appnameLower . serverURLExtension

  ; runtime variables:
  actuText := ""
  allfiles := []
  allfilesMaxCount := 0
  currentlyDisplayed := "None"
  currentFile := ""
  wheelPosition := 1

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
  delta := 3
  getFontsList()
}


;----------------------------------------------------------------------------

