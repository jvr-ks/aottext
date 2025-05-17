; aottextMainMenu.ahk
; Part of aottext.ahk


;----------------------------- generateMainMenu -----------------------------
generateMainMenu(){
  global 
  
  generateGuiEditFontsMenu()
  generateGuiEditFontSizeMenu()
  generateGuiFontsMenu()
  generateGuiFontSizeMenu()
  
  guiEditFontsSubMenu := Menu()
  guiEditFontsSubMenu.Add("Font", GuiEditFontsMenu)
  guiEditFontsSubMenu.Add("Font size", GuiEditFontSizeMenu)
  
  guiFontsSubMenu := Menu()
  guiFontsSubMenu.Add("Font", GuiFontsMenu)
  guiFontsSubMenu.Add("Font size", GuiFontSizeMenu)
  
  ; MainMenuSettings.Disable("Gui font")
  ; MainMenuSettings.Disable("Gui font size")
  
  SubMenuFilemanager := Menu()
  SubMenuFilemanager.Add("Filemanager in _saved", openDir.Bind("_saved"))
  SubMenuFilemanager.Add("Filemanager in app dir`"standard location`"", openDir.Bind("Config"))
  SubMenuFilemanager.Add("Filemanager in _trash", openDir.Bind("_trash"))
  
  SubMenuUpdate := Menu()
  SubMenuUpdate.Add("Check if new version is available", checkUpdate)
  SubMenuUpdate.Add("Start updater", updateApp)
  
  MainMenuHelp := Menu()
  MainMenuHelp.Add("Short-help", htmlViewer.Bind(A_Scriptdir "\shorthelp.html"))
  MainMenuHelp.Add("Help (Readme)", htmlViewer.Bind(A_Scriptdir "\readme.html"))
  MainMenuHelp.Add("Open Github", openGithubPage)
  
  MainMenuActions := Menu()
  MainMenuActions.Add("Edit Config", editConfigAsText)
  MainMenuActions.Add("Edit Config (external editor)", editConfig)
  MainMenuActions.Add()
  MainMenuActions.Add("Show display parameter", displayParamShow)
  MainMenuActions.Add("Filemanager", SubMenuFilemanager)
  MainMenuActions.Add("Save forced", saveForced)
  MainMenuActions.Add("Update", SubMenuUpdate)
  
  MainMenuSettings := Menu()
  MainMenuSettings.Add("Autosmall", toggleAutosmall, "Radio")
  MainMenuSettings.Add("Always on top", toggleAOT, "Radio")
  MainMenuSettings.Add("NoWrapNMode", toggleNoWrapNMode, "Radio")
  MainMenuSettings.Add("NoWrapSMode", toggleNoWrapSMode, "Radio")
  MainMenuSettings.Add("NoWrapVMode", toggleNoWrapVMode, "Radio")
  MainMenuSettings.Add()
  MainMenuSettings.Add("Font of text", guiEditFontsSubMenu)
  MainMenuSettings.Add("Font of gui", guiFontsSubMenu)
}
;------------------------------ readInsertable ------------------------------
readInsertable(){
  global 
  local file, name, value
  
  MainMenuInsert := Menu()
  
  file := insertUnicodeFile
  
  if (FileExist("..\UnicodeTable\" insertUnicodeFile))
    file := "..\UnicodeTable\" insertUnicodeFile
  
  InsertableArray := []
  if (FileExist(file)){
    Loop read, file
    {
      name := ""
      value := ""
      Loop Parse, A_LoopReadLine, "`"|`""
      {
        switch A_Index
        {
          case "1":
            value := A_LoopField
          case "2":
            name := A_LoopField
        }
      }
      MainMenuInsert.Add(value . "`t(" . name . ")", insertValue)
      InsertableArray.push(value)
     }
  }
}
;-------------------------------- insertValue --------------------------------
insertValue(p, p1, *){
  global
  local value
  
  value := InsertableArray[p1]
  A_Clipboard := value
  ToolTip("Clipboard contains: " value)
  SetTimer(tipTopCloseAll,-6000)
}
;----------------------------- displayParamShow -----------------------------
displayParamShow(*){
  global 
  
  saveIfChanged()
  
  s := "Screenwidth: " . A_ScreenWidth . ", Screenheight: " . A_ScreenHeight . "`n"
  s .= "Screen-DPI: " . A_ScreenDPI . ", dpi-Scale: " . dpiScaleDefault . ", dpi-Correct: " . dpiCorrect

  setTextToGuiMainEdit(s)
  guiMainEdit.Focus()
  
  buttonOKfunctionSelection := 3
  MainMenu.Rename("SMode", "Ok, BACK!")
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(*){
  global appnameLower
  
  Run("https://github.com/jvr-ks/" appnameLower "/")
  
}
;------------------------------ toggleAutosmall ------------------------------
toggleAutosmall(*){
  global 
  local v 
  
  autosmall := !autosmall
  setAutosmall()
}
;-------------------------------- setAutosmall --------------------------------
setAutosmall(){
  global 
  
  if (autosmall){
    MainMenuSettings.Check("Autosmall")
    guiMain.Opt("+E0x00000080")
    SetTimer(checkFocus, 0)
    SetTimer(checkFocus, 3000)
  } else {
    MainMenuSettings.Uncheck("Autosmall")
    SetTimer(checkFocus, 0)
    guiMain.Opt("-E0x00000080")
  }
  updateMainSB()
}

;----------------------------- toggleNoWrapNMode -----------------------------
toggleNoWrapNMode(*){
  global 
  
  nowrapNMode := !nowrapNMode
  setNoWrap()
}
;----------------------------- toggleNoWrapSMode -----------------------------
toggleNoWrapSMode(*){
  global 
  
  nowrapSMode := !nowrapSMode
  setNoWrap()
}
;----------------------------- toggleNoWrapVMode -----------------------------
toggleNoWrapVMode(*){
  global 
  
  nowrapVMode := !nowrapVMode
  setNoWrap()
}
;--------------------------------- setNoWrap ---------------------------------
setNoWrap(){
  global

  MainMenuSettings.Uncheck("NowrapNMode")
  MainMenuSettings.Uncheck("NowrapSMode")
  MainMenuSettings.Uncheck("NowrapVMode")
  
  if (nowrapNMode)
    MainMenuSettings.Check("NowrapNMode")
  if (nowrapSMode)
    MainMenuSettings.Check("NowrapSMode")
  if (nowrapVMode)
    MainMenuSettings.Check("NowrapVMode")
        
  switch guiMainMode {
    case 0:
      guiMainEdit.Wrap.Mode := !nowrapNMode
  
    case 2:
      guiMainEdit.Wrap.Mode := !nowrapSMode

    case 1:
      guiMainEdit.Wrap.Mode := !nowrapVMode

  }
}
;--------------------------------- toggleAOT ---------------------------------
toggleAOT(*){
  global 

  alwaysontop := !alwaysontop
  setAOT()
}
;---------------------------------- setAOT ----------------------------------
setAOT(){
  global 
  
  if (alwaysontop)
    MainMenuSettings.Check("Always on top")
  else
    MainMenuSettings.Uncheck("Always on top")
    
  updateMainSB()
  
  guiMain.Opt(alwaysontop ? "+alwaysontop" : "-alwaysontop")
}
;----------------------------- editConfigAsText -----------------------------
editConfigAsText(*){
  global 
  local e
  
  if (FileExist(configFile)){
    saveIfChanged()
    
    actualContent := guiMainEdit.Text
    
    contentIsTemporary := 1
    setTextToGuiMainEdit(Fileread(configFile))
    
    buttonOKfunctionSelection := 2
    MainMenu.Rename("SMode", "SAVE")
    MainMenu.Rename("Exit", "CANCEL")
    
  } else {
    MsgBox("SEVERE ERROR, Configfile `"" configFile "`" not found!")
  }
}
;-------------------------------- updateApp --------------------------------
updateApp(*){
  global appname, extension

  updaterExeVersion := "updater" . extension
  
  if(FileExist(updaterExeVersion)){
    MsgBox("Starting `"Updater`" now, please restart `"" appname "`" afterwards!")
    Run(updaterExeVersion " runMode")
    exit()
  } else {
    MsgBox("Updater not found!")
  }
}
;----------------------------- checkUpdate -----------------------------
checkUpdate(*){
  global appname, appnameLower, localVersionFile, updateServer

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(updateServer . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      msg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showHintColored(msg1)
      
    } else {
      msg2 := "No new version available!"
      showHintColored(msg2)
    }
  } else {
    msg := "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")"
    showHintColored(msg)
  }
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
  local e

  ret := "unknown!"

  whr := ComObject("WinHttp.WinHttpRequest.5.1")
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
      msgArr.push(" URL -> A_Clipboard")
      msgArr.push("Closing Updater due to an error!")
    
      errorExit(msgArr, url)
    }
  }
  catch as e
  {
    ret := "error!"
  }

  return ret
} 
;-------------------------- openFilemanagerInTrash --------------------------
openFilemanagerInTrash(*){
  global wrkpath
  
  p := wrkPath("_trash")
  Run("explore " p)
}
;-------------------------- openFilemanagerInSaved --------------------------
openFilemanagerInSaved(*){
  global saveDir
  
  p := pathToAbsolut(saveDir)
  Run("explore " p)
}
;---------------------------------- openDir ----------------------------------
openDir(d, *){
  global
  
  switch d {
    case "Config":
      run A_ComSpec " /c start " A_ScriptDir
    case "_saved":
      run A_ComSpec " /c start " pathToAbsolut(saveDir)
    case "_trash":
      run A_ComSpec " /c start " wrkPath("_trash")

  }
}
;-------------------------------- moveToTrash --------------------------------
moveToTrash(*){
  global 
  local e
    
  fileToMove := lastUsedFile
  
  if (wheelPosition != allfiles.Length){
    fileToMove := allfiles[wheelPosition]
  }

  if (fileToMove != ""){
    fromPath := pathToAbsolut(saveDir) . fileToMove
    toPath := pathToAbsolut(trashDir) . fileToMove

    try {
      FileMove(fromPath, toPath, 1)
    }
    catch as e
    {
      msgbox("An error occurred!`n`nwhat: " e.what "`nfile: " e.file 
      . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra,, 16)
  
      return
    }
  
    wheelPositionSave := wheelPosition
    refreshAllfiles(1)
    
    if (wheelPositionSave < allfiles.Length){
      newFileToUse :=  allfiles[wheelPositionSave]

      if (FileExist(pathToAbsolut(saveDir) . newFileToUse)){
        updateLastUsedFile(newFileToUse)
        readLastUsed()
      } else {
        readLatest()
      }
    } else {
      refreshAllfiles(0)
      readLatest()
    }
  }
}
;----------------------------------------------------------------------------
















