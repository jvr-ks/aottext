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
  MainMenu.Add("FsMode", FsModeAction)
  MainMenu.Add("|<-", historyBackwardFirst)
  MainMenu.Add("⇐", historyBackward10)
  MainMenu.Add("<-", historyBackward)
  MainMenu.Add("->", historyFoward)
  MainMenu.Add("⇒", historyFoward10)
  MainMenu.Add("->|", historyFowardFirst)
  MainMenu.Add("Actions", MainMenuActions)
  MainMenu.Add("Settings", MainMenuSettings)

  MainMenu.Add("Insert", MainMenuInsert)
  MainMenu.Add("To trash", moveToTrash)
  
  MainMenu.Add("Save", saveUncon)
  MainMenu.Add("Save (as new file)", saveAsNew)
  MainMenu.Add("Folders", MainMenuFolders)
  MainMenu.Add("Help", MainMenuHelp)
  MainMenu.Add("Exit", exitFunction) ; Exit / Cancel

  ; -0x30000 -> not minimizable, +E0x08000000 -> not in tasklist
  guiMain := Gui("+Lastfound +OwnDialogs +Resize +AlwaysOnTop -0x30000", app)
  ; guiMain.Opt()
  
  if (!alwaysontop)
    WinSetAlwaysOnTop 0

  guiMain.MenuBar := mainMenu
  guiMain.SetFont("s" . guiMainFontSize, guiMainFontName)
  
  SB := guiMain.Add("StatusBar")
  
  SB.SetParts(round(guiMainClientWidth * 0.2), round(guiMainClientWidth * 0.2), round(guiMainClientWidth * 0.08), round(guiMainClientWidth * 0.12), round(guiMainClientWidth * 0.08), round(guiMainClientWidth * 0.15))
  updateMainSB()
  buttonOKfunctionSelection := 1

  ; gui show / hide
  guiMain.Show("Hide x" . guiMainPosX . " y" . guiMainPosY . " w" . guiMainClientWidth . " h" . guiMainClientHeight)
  
 
;------------------------------- AddScintilla -------------------------------
  ; overwritten by size event
  guiMainEdit := guiMain.AddScintilla("x" paddingLeft " y" paddingTop " w800 h600 DefaultOpt LightTheme")
  
  setLexer(guiMainEdit) ;TODO
  
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
  
  GuiEditFontsMenu.Check(guiMainEditFontName)
  GuiEditFontSizeMenu.Check(guiMainEditFontSize) 
  
  HotIfWinActive("appname")
  Hotkey("^f", findText)
  
  if (autosmall){
    SetTimer(checkFocus, 0)
    SetTimer(checkFocus, 3000)
  }
  
  guiMain.OnEvent("Size", guiMain_Size, 1)
  guiMain.OnEvent("Close", (*) => exitFunction())
  OnMessage(0x03, moveEventSwitch)
  
  ; trigger a size event
  WinMaximize "ahk_id " guiMainHwnd
  WinRestore "ahk_id " guiMainHwnd
  
  ;guiMain.Show("Autosize")
  
}
;------------------------------- updateMainSB -------------------------------
updateMainSB(){
  global
  local mem, showNotEmpty
  
  showNotEmpty := ""
  if (allfiles.Length > 0){
    showNotEmpty := getFromAllfiles()
  }

  SB.SetText(" " . selectedFolder, 1, 2)
  SB.SetText(" " . showNotEmpty . " [" . wheelPosition . "]", 2, 2)
  SB.SetText(" " . configFile, 3, 1)
  SB.SetText(" " . alwaysontop ? "[Always on top]":"", 4, 1)
  SB.SetText(" " . autosmall ? "[Autosmall]":"", 5, 1)
  SB.SetText(" [" guiMainEditFontName "]", 6, 1)
    
    
  mem := "?"
  try {
    mem := getProcessMemoryUsage()
    SB.SetText("`t`t[" mem " MB]   ", 6, 2)
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
  }
}
;---------------------------- updatecurrentFile ----------------------------
updatecurrentFile(){
  global 

  updateDisplayedFilename()
  wheelPositionSave()
}
;----------------------------- wheelPositionSave -----------------------------
wheelPositionSave(){
  IniWrite wheelPosition, configFile, "user", "wheelPosition"
}

;----------------------------- buttonOKFunction -----------------------------
buttonOKFunction(*){
  global

  switch buttonOKfunctionSelection {
    case 1:
      SModeAction()
      
    case 2:
      saveNewConfig()
      ; triggers a reload
      
   
    default:
      msgbox("Error, unknown buttonOKfunctionSelection!")
  }
}
;-------------------------------- NModeAction --------------------------------
NModeAction(*){
  global

  guiMainMode := 0
  inhibit := 1
  ; move to normal position
  guiMain.move(guiMainPosX, guiMainPosY, guiMainWidth, guiMainHeight)
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
  guiMain.move(guiMainVModePosX, guiMainVModePosY, guiMainVModeWidth, guiMainVModeHeight)
  mainEditVModeWidth := (guiMainClientVModeWidth - paddingLeft - paddingRight)
  mainEditVModeHeight := (guiMainClientVModeHeight - paddingBottom - paddingTop)
  guiMainEdit.Move(,, mainEditVModeWidth, mainEditVModeHeight)
  WinSetTransparent "off", "Aottext"
  sleep 100
  inhibit := 0
  WinActivate("Aottext")
  setNoWrap()
}
;------------------------------- SModeAction -------------------------------
SModeAction(*){
  global

  saveIfChanged()
  guiMainMode := 2
  inhibit := 1
  ; move to SMode position
  guiMain.move(guiMainSModePosX, guiMainSModePosY, guiMainSModeWidth, guiMainSModeHeight)
  mainEditWidth := (guiMainClientSModeWidth - paddingLeft - paddingRight)
  mainEditHeight := (guiMainClientSModeHeight - paddingBottom - paddingTop)
  guiMainEdit.Move(,, mainEditWidth, mainEditHeight)
  WinSetTransparent smodeTransparency, "Aottext"

  inhibit := 0
  setNoWrap()
}

;------------------------------- FsModeAction -------------------------------
FsModeAction(*){
  global

  guiMainMode := 3
  inhibit := 1
  ; move to fullscreen position
  guiMain.move(guiMainFsModePosX, guiMainFsModePosY, guiMainFsModeWidth, guiMainFsModeHeight)
  mainEditWidth := (guiMainClientFsModeWidth - paddingLeft - paddingRight)
  mainEditHeight := (guiMainClientFsModeHeight - paddingBottom - paddingTop)
  guiMainEdit.Move(,, mainEditWidth, mainEditHeight)
  WinSetTransparent "off", "Aottext"

  sleep 100
  inhibit := 0
  WinActivate("Aottext")
  setNoWrap()
}
;-------------------------------- saveConfig --------------------------------
saveNewConfig(*){
  global
  
  inhibit := 1
  FileDelete(configFile)
  FileAppend(guiMainEdit.Text, configFile, "UTF-8-RAW `n")
  
  FileDelete(configFile)
  FileAppend(guiMainEdit.Text, configFile, "UTF-8-RAW `n")
  
  setTextToGuiMainEdit(actualContent)
  contentIsTemporary := 0
  
  reloadScript()
  
  return
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
  
  if (MinMax = -1 || MinMax = 1)
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
      
      mainEditWidth := guiMainClientWidth - paddingLeft - paddingRight - delta
      mainEditHeight := guiMainClientHeight - paddingBottom - paddingTop - delta
      
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
    ; FsMode
      guiMainFsModeWidth := Width
      guiMainFsModeHeight := Height
      
      IniWrite guiMainFsModeWidth, configFile, "gui", "guiMainFsModeWidth"
      IniWrite guiMainFsModeHeight, configFile, "gui", "guiMainFsModeHeight"
      
      guiMainClientFsModeWidth := clientWidth
      guiMainClientFsModeHeight := clientHeight

      IniWrite guiMainClientFsModeWidth, configFile, "gui", "guiMainClientFsModeWidth"
      IniWrite guiMainClientFsModeHeight, configFile, "gui", "guiMainClientFsModeHeight"

      mainEditFsModeWidth := guiMainClientFsModeWidth - paddingLeft - paddingRight
      mainEditFsModeHeight := guiMainClientFsModeHeight - paddingBottom - paddingTop

      guiMainEdit.Move(,, mainEditFsModeWidth, mainEditFsModeHeight)
    
    case 4:
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
        minPosLeft := 150 - (guiMainClientWidth)
      
        guiMainPosX := posX
        guiMainPosY := posY
        
        checkGuiMainposition()
        
        IniWrite guiMainPosX, configFile, "gui", "guiMainPosX"
        IniWrite guiMainPosY, configFile, "gui", "guiMainPosY"
         
      case 1:
        minPosTop := 0
        minPosLeft := 150 - (guiMainClientVModeWidth)
        
        guiMainVModePosX := posX
        guiMainVModePosY := posY
        
        IniWrite guiMainVModePosX, configFile, "gui", "guiMainVModePosX"
        IniWrite guiMainVModePosY, configFile, "gui", "guiMainVModePosY"
      
      case 2:
        minPosTop := 0
        minPosLeft := 150 - (guiMainClientSModeWidth)
        
        guiMainSModePosX := posX
        guiMainSModePosY := posY
        
        IniWrite guiMainSModePosX, configFile, "gui", "guiMainSModePosX"
        IniWrite guiMainSModePosY, configFile, "gui", "guiMainSModePosY"
        
      case 3:
        ;FsMode
        minPosTop := 0
        minPosLeft := 150 - (guiMainClientFsModeWidth)
        
        guiMainFsModePosX := posX
        guiMainFsModePosY := posY
        
        IniWrite guiMainFsModePosX, configFile, "gui", "guiMainFsModePosX"
        IniWrite guiMainFsModePosY, configFile, "gui", "guiMainFsModePosY"
        
      case 4:
        ; invisible, no changes
        
      default:
        ;
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
;-------------------------------- setTextToGuiMainEdit --------------------------------
setTextToGuiMainEdit(t := "ERROR"){
  global
  
  guiMainEdit.Text := t
}
;------------------------------- readLastUsed -------------------------------
readLastUsed(){
  global 
  local file, newContent, savePathLocal
  
  currentFile := getFromAllfiles()
  
  if (currentFile != ""){
    savePathLocal := pathToAbsolut(selectedFolder) . currentFile
    if (FileExist(savePathLocal)){
      file := FileOpen(savePathLocal,"r")
      newContent := file.Read()
      file.Close()
      actualContent := newContent
      guiMainEdit.clearAll()
      setTextToGuiMainEdit(newContent)
      updatecurrentFile()
    } else {
      showHintColored("File " . savePathLocal . " was not found! (Using a mew empty folder?)", 6000)
      wheelPosition := 1
    }
  }
}
;-------------------------- updateDisplayedFilename --------------------------
updateDisplayedFilename(){
  global
  
  if (wheelPosition > 0) {
    showNotEmpty := ""
    if (allfiles.Length > 0){
      showNotEmpty := getFromAllfiles()
    }
    SB.SetText(" " . showNotEmpty . " [" . wheelPosition . "]", 2, 2)
  }
}
;--------------------------------- saveUncon ---------------------------------
saveUncon(*){
  global 
  local file, newContent, filename, file, savePathLocal
    
  newContent := guiMainEdit.Text
  
  if (StrLen(newContent) > 2){
    savePathLocal := pathToAbsolut(selectedFolder) . currentFile
    file := FileOpen(savePathLocal, "w`n")
    
    if (!IsObject(file)){
      MsgBox("ERROR, can't open `"" savePathLocal "`" for writing!")
    } else {
      file.Write(newContent)
      file.Close()
    }
    refreshAllfiles()
  }
}
;------------------------------- saveIfChanged -------------------------------
saveIfChanged(*){
  global 
  local file, newContent, filename, savePathLocal
    
  newContent := guiMainEdit.Text
  
  if (StrLen(newContent) > 2){
    if (newContent != actualContent){
    
      filename := FormatTime(A_Now " T8", "'aot'_yyyyMMddhhmmss") . ".txt"
      savePathLocal := pathToAbsolut(selectedFolder) . filename
      
      if (FileExist(savePathLocal)){
        MsgBox("SEVERE ERROR occurred: your realtimeclock has set the wrong time and/or the wrong date, exiting " appname "!")
        ExitApp 1
      }
      
      file := FileOpen(savePathLocal, "w`n")
      
      if (!IsObject(file)){
        MsgBox("ERROR, can't open `"" savePathLocal "`" for writing!")
      } else {
        file.Write(newContent)
        file.Close()
        actualContent := newContent
      }
      refreshAllfiles()
    }
  }
}
;-------------------------------- saveAsNew --------------------------------
saveAsNew(*){
  global 
  local file, newContent, filename, savePathLocal
  
  newContent := guiMainEdit.Text

  currentFile := FormatTime(A_Now " T8", "'aot'_yyyyMMddhhmmss") . ".txt"
  
  savePathLocal := pathToAbsolut(selectedFolder) . currentFile
  
  if (FileExist(savePathLocal)){
    MsgBox("SEVERE ERROR occurred: your realtimeclock has set the wrong time and/or the wrong date, exiting " appname "!")
    ExitApp 1
  }

  file := FileOpen(savePathLocal, "w`n" , "UTF-8")
  
  if (!IsObject(file)){
    MsgBox("SEVERE ERROR, can't open `"" savePathLocal "`" for writing!")
    ExitApp 1
  } else {
    file.Write(newContent)
    file.Close()
    
    refreshAllfiles()
    wheelPosition := allfilesMaxCount
    wheelPositionSave()
    updatecurrentFile()
    readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
    showHintColored("New file saved: " . currentFile)
  }
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
;--------------------------------- winmerge ---------------------------------
winmerge(n, *){
  global
  local UniqueID, winmergeExe, targetcontrol
  
  targetcontrol := "Edit" . n
  SetTitleMatchMode(2)
  UniqueID := WinExist("WinMerge")
  winmergeExe := IniRead(configFile, "config", "winmergePath", "C:\Program Files\WinMerge\WinMergeU.exe")

  if (!UniqueID){
    Run winmergeExe
    sleep 3000
    send "^o"
    sleep 1000
    UniqueID := WinExist("WinMerge")
  }
  if (!UniqueID){
    msgbox(winmergeExe . " not found!")
    return
  }
  WinActivate "ahk_class WinMergeWindowClassW"
  controlsend "^a", targetcontrol, "ahk_class WinMergeWindowClassW"
  controlsend "{del}", targetcontrol, "ahk_class WinMergeWindowClassW"
  controlsend "{text}" . pathToAbsolut(selectedFolder) . currentFile, targetcontrol, "ahk_class WinMergeWindowClassW"
}
;----------------------------------------------------------------------------





























