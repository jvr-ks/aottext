; aottextMainWindow.ahk
; Part of aottext.ahk

;--------------------------------- mainWindow ---------------------------------
mainWindow(hide := 0) {
  global 
  
  local arrow, checkmark, buttonCheckmarkarrow, toDo, buttontoDoarrow, memory

  MainMenu := MenuBar()
  
  MainMenu.Add("SMode", buttonOKfunction) ; Hide / Save / Reset
  MainMenu.Add("NMode", NModeAction)
  MainMenu.Add("VMode", VModeAction)
  MainMenu.Add("Actions", MainMenuActions)
  MainMenu.Add("Settings", MainMenuSettings)
  MainMenu.Add("Help", MainMenuHelp)
  MainMenu.Add("Insert", MainMenuInsert)
  MainMenu.Add("To trash", moveToTrash)
  MainMenu.Add("Exit", buttonCANCELfunction) ; Exit / Cancel
  
  MainMenu.Add("None", lastUsedFileOperation, "Right")

  ; -0x30000 -> not minimizable, +E0x08000000 -> not in tasklist
  guiMain := Gui("+Lastfound +OwnDialogs +Resize +AlwaysOnTop -0x30000", app)
  ; guiMain.Opt()
  
  if (!alwaysontop)
    WinSetAlwaysOnTop 0

  guiMain.MenuBar := mainMenu
  guiMain.SetFont("s" . guiMainFontSize, guiMainFontName)
  
  SB := guiMain.Add("StatusBar")
  
  ; gui show / hide
  guiMain.Show("Hide x" . guiMainPosX . " y" . guiMainPosY . " w" . guiMainClientWidth . " h" . guiMainClientHeight)
  
  buttonOKfunctionSelection := 1
  
  SB.SetParts(round(guiMainClientWidth * 0.26), round(guiMainClientWidth * 0.18), round(guiMainClientWidth * 0.16), round(guiMainClientWidth * 0.30))
  updateMainSB()
   
;------------------------------- AddScintilla -------------------------------
  ; overwritten by size event
  guiMainEdit := guiMain.AddScintilla("x" paddingLeft " y" paddingTop " w800 h600 DefaultOpt LightTheme")
  
  setLexer(guiMainEdit) ;TODO
  
  ;guiMainEdit.callback := guiMainEditUpdateParameter()
  
  guiMainEdit.Doc.ptr := guiMainEdit.Doc.Create(500000+100)

  guiMainEdit.Tab.Use := false
  guiMainEdit.Tab.Width := 2
  guiMainEdit.Margin.Width := 10
  guiMainEdit.Margin.Type := 0
  
  guiMainEdit.AutoSizeNumberMargin := true
  
  guiMainHwnd := guiMain.Hwnd
  guiMainEditHwnd := guiMainEdit.Hwnd
  
 if (alwaysontop)
    WinSetAlwaysOnTop(1, "ahk_id " guiMainHwnd)
  
  if (hide){
    guiMain.Hide()
    guiMode := 3
    tipTop("Started " . app . "`nHotkey is: " . aottextHotkey, 9, 5000)
    ; setimer () => tooltip(), -6000
  }
  
  GuiFontsMenu.Check(guiMainFontName)
  GuiFontSizeMenu.Check(guiMainFontSize)
  GuiEditFontsMenu.Check(guiMainEditFontName)
  GuiEditFontSizeMenu.Check(guiMainEditFontSize) 
  
  HotIfWinActive("appname")
  Hotkey("^f", findText)
  
  if (autosmall){
    SetTimer(checkFocus, 0)
    SetTimer(checkFocus, 3000)
  }
  
  guiMain.OnEvent("Size", guiMain_Size, 1)
  guiMain.OnEvent("Close", exit)
  OnMessage(0x03, moveEventSwitch)
  
  ; trigger a size event
  WinMaximize "ahk_id " guiMainHwnd
  WinRestore "ahk_id " guiMainHwnd
  
  guiMain.Show("Autosize")
  
}
;------------------------------- updateMainSB -------------------------------
updateMainSB(){
  global
  local mem
  
  SB.SetText(" " . configFile, 1, 1)
  SB.SetText(" " . alwaysontop ? "[Always on top]":"", 2, 1)
  SB.SetText(" " . autosmall ? "[Autosmall]":"", 3, 1)
  SB.SetText(" [" guiMainEditFontName "]", 4, 1)
    
  mem := "?"
  try {
    mem := getProcessMemoryUsage()
    SB.SetText("`t`t[" mem " MB]   ", 5, 2)
  }
}
;------------------------ guiMainEditUpdateParameter ------------------------
guiMainEditUpdateParameter(*){
  global 
  local guiCtrlObj, CurrentCol, CurrentLine, oSaved

  guiCtrlObj := guiMain.FocusedCtrl
  if (IsObject(guiCtrlObj)){
    CurrentCol := EditGetCurrentCol(guiCtrlObj)
    CurrentLine := EditGetCurrentLine(guiCtrlObj)
    ;oSaved := guiMain.Submit(0)
    ;currentLineContent := guiMain.Text
    ;tooltip currentLineContent
    ;SB.SetText("Line: " CurrentLine " Column: " CurrentCol , 2, 1)
  }
}
;------------------------- lastUsedFileOperation -------------------------
lastUsedFileOperation(*){
  global 
  ; noop
}
;---------------------------- updateLastUsedFile ----------------------------
updateLastUsedFile(s){
  global 

  if (s != ""){
    MainMenu.rename(currentlyDisplayed, s)
    currentlyDisplayed := s
    IniWrite "`"" lastUsedFile "`"", configFile, "user", "lastUsedFile"
    IniWrite "`"" lastUsedFile "`"", configFile, "user", "lastUsedFile"
    lastUsedFile := s
  }
}
;----------------------------- buttonOKFunction -----------------------------
buttonOKFunction(*){
  global

  switch buttonOKfunctionSelection {
    case 1:
      SModeAction()
      
    case 2:
      saveNewConfig()
      ; makes a reload
      
    case 3:
      resetToActualContent()
      MainMenu.Rename("Ok, BACK!", "SMode")
      buttonOKfunctionSelection := 1
    
    default:
      msgbox("Error, unknown buttonOKfunctionSelection!")
  }
}
;--------------------------- buttonCANCELFunction ---------------------------
buttonCANCELFunction(*){
  global

  switch buttonOKfunctionSelection {
    case 0:
      msgbox("Error, unknown function definition")
      
    case 1:
      exit()
      
    case 2:
      MainMenu.Rename("SAVE", "SMode")
      MainMenu.Rename("CANCEL", "Exit")
      setTextToGuiMainEdit(actualContent)
      contentIsTemporary := 0
      
    case 3:
      exit()
      
    default:
      msgbox("Error, unknown buttonCANCELfunctionSelection!")
    
  }    
}
;-------------------------------- NModeAction --------------------------------
NModeAction(*){
  global 

  guiMainMode := 0
  inhibit := 1
  ; move to normal position
  guiMain.move(coordsScreenToApp(guiMainPosX), coordsScreenToApp(guiMainPosY), guiMainWidth, guiMainHeight)
  
  mainEditWidth := (guiMainClientWidth - paddingLeft - paddingRight)
  mainEditHeight := (guiMainClientHeight - paddingBottom - paddingTop)
  guiMainEdit.Move(,, mainEditWidth, mainEditHeight)
  WinSetTransparent "off", "Aottext"

  sleep 100
  inhibit := 0
  WinActivate("Aottext")
  setNoWrap()
}
;-------------------------------- VModeAction --------------------------------
VModeAction(*){
  global 
  
  guiMainMode := 1
  inhibit := 1
  ; move to VMode position
  guiMain.move(coordsScreenToApp(guiMainVModePosX), coordsScreenToApp(guiMainVModePosY), guiMainVModeWidth, guiMainVModeHeight)
  mainEditVModeWidth := (guiMainClientVModeWidth - paddingLeft - paddingRight)
  mainEditVModeHeight := (guiMainClientVModeHeight - paddingBottom - paddingTop)
  guiMainEdit.Move(,, mainEditVModeWidth, mainEditVModeHeight)
  WinSetTransparent "off", "Aottext"

  sleep 100
  inhibit := 0
  setNoWrap()
}
;------------------------------- SModeAction -------------------------------
SModeAction(*){
  global 

  saveIfChanged()
  guiMainMode := 2
  inhibit := 1
  ; move to normal position
  guiMain.move(coordsScreenToApp(guiMainSModePosX), coordsScreenToApp(guiMainSModePosY), guiMainSModeWidth, guiMainSModeHeight)
  
  mainEditWidth := (guiMainClientSModeWidth - paddingLeft - paddingRight)
  mainEditHeight := (guiMainClientSModeHeight - paddingBottom - paddingTop)
  guiMainEdit.Move(,, mainEditWidth, mainEditHeight)
  WinSetTransparent smodeTransparency, "Aottext"

  inhibit := 0
  setNoWrap()
}
;-------------------------------- saveConfig --------------------------------
saveNewConfig(*){
  global 
  
  FileDelete(configFile)
  FileAppend(guiMainEdit.Text, configFile, "UTF-8-RAW `n")
  
  FileDelete(configFile)
  FileAppend(guiMainEdit.Text, configFile, "UTF-8-RAW `n")
  
  setTextToGuiMainEdit(actualContent)
  contentIsTemporary := 0
  
  exitAndReload()
  
  return
}
;--------------------------- resetToActualContent ---------------------------
resetToActualContent(){
  global 

  guiMainEdit.clearAll()
  setTextToGuiMainEdit(actualContent)
  guiMainEdit.Focus()
  contentIsTemporary := 0
}
;------------------------------ moveEventSwitch ------------------------------
moveEventSwitch(p1, p2, p3, p4, *){
  global 
  local h1, h2, h3
  
  if (inhibit)
    return
  
  h1 := 0, h2 := 0, h3 := 0
  
  if (IsSet(guiMain)){
    h1 := guiMainHwnd
  }
    
  ; if (IsSet(guiPreview)){
    ; h2 := guiPreview.hwnd
  ; }
  
  ; if (IsSet(guiImagePreview)){
    ; h3 := guiImagePreview.hwnd
  ; }
  
  Switch  p4
  {
    Case h1:
      guiMain_Move()
    
/*     Case h2:
      guiPreviewMove()
      
    Case h3:
      guiImagePreviewMove() */
  
  }
}
;------------------------------- guiMain_Size -------------------------------
guiMain_Size(thisGui, MinMax, clientWidth, clientHeight) {
  global 
  local Width, Height
  
  if (MinMax = -1)
      return
  
  if (inhibit)
    return
    
  guiMain.GetPos(&posX, &posY, &Width, &Height)
    
  switch guiMainMode {
    case 0:
      ; nmode
      guiMainWidth := Width
      guiMainHeight := Height
      
      IniWrite guiMainWidth, configFile, "gui", "guiMainWidth"
      IniWrite guiMainHeight, configFile, "gui", "guiMainHeight"
      
      guiMainClientWidth := clientWidth
      guiMainClientHeight := clientHeight
      
      IniWrite guiMainClientWidth, configFile, "gui", "guiMainClientWidth"
      
      IniWrite guiMainClientHeight, configFile, "gui", "guiMainClientHeight"
      
      mainEditWidth := guiMainClientWidth - paddingLeft - paddingRight
      mainEditHeight := guiMainClientHeight - paddingBottom - paddingTop
      
      guiMainEdit.Move(,, mainEditWidth, mainEditHeight)
      
    case 1:
      ; vmode
      guiMainVModeWidth := Width
      guiMainVModeHeight := Height
      
      IniWrite guiMainVModeWidth, configFile, "gui", "guiMainVModeWidth"
      IniWrite guiMainVModeHeight, configFile, "gui", "guiMainVModeHeight"
      
      
      guiMainClientVModeWidth := clientWidth
      guiMainClientVModeHeight := clientHeight

      IniWrite guiMainClientVModeWidth, configFile, "gui", "guiMainClientVModeWidth"
      IniWrite guiMainClientVModeHeight, configFile, "gui", "guiMainClientVModeHeight"

      mainEditVModeWidth := guiMainClientVModeWidth - paddingLeft - paddingRight
      mainEditVModeHeight := guiMainClientVModeHeight - paddingBottom - paddingTop

      guiMainEdit.Move(,, mainEditVModeWidth, mainEditVModeHeight)

    case 2:
      ; SMode
      guiMainSModeWidth := Width
      guiMainSModeHeight := Height
      
      IniWrite guiMainSModeWidth, configFile, "gui", "guiMainSModeWidth"
      IniWrite guiMainSModeHeight, configFile, "gui", "guiMainSModeHeight"
      
      guiMainClientSModeWidth := clientWidth
      guiMainClientSModeHeight := clientHeight
      
      IniWrite guiMainClientSModeWidth, configFile, "gui", "guiMainClientSModeWidth"
      IniWrite guiMainClientSModeHeight, configFile, "gui", "guiMainClientSModeHeight"
      
      mainEditSModeWidth := guiMainClientSModeWidth - paddingLeft - paddingRight
      mainEditSModeHeight := guiMainClientSModeHeight - paddingBottom - paddingTop

      guiMainEdit.Move(,, mainEditSModeWidth, mainEditSModeHeight)
      
    case 3:
    ; hidden
  }
}
;-------------------------------- guiMain_Move --------------------------------
guiMain_Move(){
  global
  local debugMsg1
  
  if (inhibit)
    return
    
  guiMain.GetPos(&posX, &posY)
  
  if (posX != 0 && posY != 0){ 
    ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = invisible
    switch guiMainMode {
      case 0:
        minPosTop := 0 
        minPosLeft := 150 - coordsAppToScreen(guiMainClientWidth)
      
        guiMainPosX := posX
        guiMainPosY := posY
        
        checkGuiMainposition()
        
        IniWrite guiMainPosX, configFile, "gui", "guiMainPosX"
        IniWrite guiMainPosY, configFile, "gui", "guiMainPosY"
      
      case 1:
        minPosTop := 0
        minPosLeft := 150 - coordsAppToScreen(guiMainClientVModeWidth)
        
        guiMainVModePosX := posX
        guiMainVModePosY := posY
        
        IniWrite guiMainVModePosX, configFile, "gui", "guiMainVModePosX"
        IniWrite guiMainVModePosY, configFile, "gui", "guiMainVModePosY"
      
      case 2:
        minPosTop := 0
        minPosLeft := 150 - coordsAppToScreen(guiMainClientSModeWidth)
        
        guiMainSModePosX := posX
        guiMainSModePosY := posY
        
        IniWrite guiMainSModePosX, configFile, "gui", "guiMainSModePosX"
        IniWrite guiMainSModePosY, configFile, "gui", "guiMainSModePosY"
        
      case 3:
        ; invisible, no changes
    }
  }
}
;-------------------------------- insertDone --------------------------------
insertDone(*){
  global 
  
  guiMainEdit.InsertText(-1," " . Chr(0x2714))
}
;--------------------------------- insertOpen ---------------------------------
insertOpen(*){
  global 
  
  guiMainEdit.InsertText(-1," " . Chr(0x25EF))
}
;-------------------------------- reActivate --------------------------------
reActivate(){
  global 
  
  WinActivate("ahk_id " guiMainHwnd)
  
  if (autosmall){
    SetTimer(checkFocus, 0)
    SetTimer(checkFocus, 3000)
  }
}
;------------------------------ GetSelectedText ------------------------------
; GetSelectedText() {
  ; global guiMainEdit
  
  ; selLength := guiMainEdit.GetSelText()
  ; VarSetCapacity(SelText, selLength, 0)
  ; guiMainEdit.GetSelText(0, &SelText)
  ; content := StrGet(&SelText, selLength, "utf-8")
  ; Return StrGet(&SelText, selLength, "utf-8")
; }
;-------------------------------- setTextToGuiMainEdit --------------------------------
setTextToGuiMainEdit(t := "ERROR"){
  global guiMainEdit
  
  ;guiMainEdit.SETUNDOCOLLECTION(0)
  guiMainEdit.Text := t
  ;guiMainEdit.SETUNDOCOLLECTION(1)
  ;guiMainEdit.BEGINUNDOACTION(1)
}
;------------------------------- readLastUsed -------------------------------
readLastUsed(){
  global 
  local file, newContent
  
  if (lastUsedFile != ""){
    filename := pathToAbsolut(saveDir) . lastUsedFile
    if (FileExist(filename)){
      file := FileOpen(filename,"r")
      newContent := file.Read()
      file.Close()
      actualContent := newContent
      guiMainEdit.clearAll()
      setTextToGuiMainEdit(newContent)
    } else {
      readLatest()
    }
  } else {
    readLatest()
  }
}
;-------------------------------- readLatest --------------------------------
readLatest(){
  global 
  local file, newContent
    
  if (allfilesMaxCount < 1){
    lastUsedFile := "None"
  } else {
    lastUsedFile := allfiles[allfilesMaxCount]
  }
  
  if (lastUsedFile != "None"){
    filename := pathToAbsolut(saveDir) . lastUsedFile
    
    if (FileExist(filename)){
      file := FileOpen(filename,"r")
      newContent := file.Read()
      file.Close()
      actualContent := newContent
      guiMainEdit.clearAll()
      setTextToGuiMainEdit(newContent)
      guiMainEdit.Focus()
      updateLastUsedFile(lastUsedFile)
    } else {
      MsgBox("SEVERE ERROR, file not found: " filename)
    }
  } else {
    showHintColored("Welcome to Aottext, please enter your text!")
  }
}
;------------------------------- saveIfChanged -------------------------------
saveIfChanged(){
  global 
  local file, newContent, filename
    
  newContent := ""
  if (contentIsTemporary)
    newContent := actualContent
  else
    newContent := guiMainEdit.Text
  
  if (StrLen(newContent) > 2){
    if (newContent != actualContent){
    
      filename := formatFilename()
      
      lastUsedFile := filename . ".txt"
      savePath := pathToAbsolut(saveDir) . lastUsedFile
      
      if (FileExist(savePath)){
        MsgBox("SEVERE ERROR occurred: your realtimeclock has set the wrong time and/or the wrong date, exiting " appname "!")
        ExitApp()
      }
      
      file := FileOpen(savePath, "w`n")
      
      if (!IsObject(file)){
        MsgBox("ERROR, can't open `"" savePath "`" for writing!")
      } else {
        file.Write(newContent)
        file.Close()
        actualContent := newContent
        updateLastUsedFile(filename)
      }
      refreshAllfiles()
    }
  }
}
;------------------------------ formatFilename ------------------------------
formatFilename(){
  return FormatTime(A_Now " T8", "'aot'_yyyyMMddhhmmss")
}
;-------------------------------- saveForced --------------------------------
saveForced(*){
  global 
  local file, newContent, filename, savePath
  
  newContent := ""
  if (contentIsTemporary)
    newContent := actualContent
  else
    newContent := guiMainEdit.Text

  filename := formatFilename()
  
  previousFile := lastUsedFile
  lastUsedFile := filename . ".txt"
  savePath := pathToAbsolut(saveDir) . lastUsedFile
  
  if (FileExist(savePath)){
    MsgBox("SEVERE ERROR occurred: your realtimeclock has set the wrong time and/or the wrong date, exiting " appname "!")
    ExitApp()
  }

  file := FileOpen(savePath, "w`n" , "UTF-8")
  
  if (!IsObject(file)){
    MsgBox("ERROR, can't open `"" savePath "`" for writing!")
  } else {
    file.Write(newContent)
    file.Close()
    actualContent := newContent
    
    IniWrite lastUsedFile, configFile, "user", "lastUsedFile"
    try {
      MainMenu.Rename(previousFile, lastUsedFile)
    }
    
    refreshAllfiles()
    
    Sleep(2000)
  }
}
;------------------------------ guiMainGuiClose ------------------------------
guiMainGuiClose(){
  exit()
}
;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global 
  local h
  
  if (autosmall){
    h := WinActive("A")
    if (guiMainHwnd != h)
      if (guiMainMode != 2)
        SModeAction()
  }
}
;----------------------------------------------------------------------------





























