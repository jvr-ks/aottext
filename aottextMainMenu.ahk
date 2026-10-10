; aottextMainMenu.ahk
; Part of aottext.ahk


;----------------------------- generateMainMenu -----------------------------
generateMainMenu(){
  global 
  
  generateGuiEditFontsMenu()
  generateGuiEditFontSizeMenu()
  
  guiEditFontsSubMenu := Menu()
  guiFontsSubMenu := Menu()
  
  SubMenuFilemanager := Menu()
  SubMenuFilemanager.Add("Filemanager in _saved", openDir.Bind("_saved"))
  SubMenuFilemanager.Add("Filemanager in app dir `"standard location`"", openDir.Bind("Config"))
  SubMenuFilemanager.Add("Filemanager in _trash", openDir.Bind("_trash"))
  
  SubMenuUpdate := Menu()
  SubMenuUpdate.Add("Check if new version is available", checkUpdate)
  SubMenuUpdate.Add("Start updater", updateApp)
  
  MainMenuHelp := Menu()
  MainMenuHelp.Add("Short-help", openShorthelp)
  MainMenuHelp.Add("Help (Readme)", openReadme)
  MainMenuHelp.Add("Open Github", openGithubPage)
  
  MainMenuActions := Menu()
  MainMenuActions.Add("Winmerge1", winmerge.Bind("1"))
  MainMenuActions.Add("Winmerge2", winmerge.Bind("2"))
  MainMenuActions.Add("Winmerge3", winmerge.Bind("3"))
  MainMenuActions.Add()
  MainMenuActions.Add("Show display parameter", displayParamShow)
  MainMenuActions.Add("Filemanager", SubMenuFilemanager)
  MainMenuActions.Add("Update", SubMenuUpdate)
  
  MainMenuSettings := Menu()
  MainMenuSettings.Add("Autosmall", toggleAutosmall, "Radio")
  MainMenuSettings.Add("Always on top", toggleAOT, "Radio")
  MainMenuSettings.Add("Smode Autoleave", toggleSmodeAutoleave, "Radio")
  MainMenuSettings.Add("Content Font size", GuiEditFontSizeMenu)  
  MainMenuSettings.Add("Content Font select", GuiEditFontsMenu)
  MainMenuSettings.Add()
  MainMenuSettings.Add("Edit Config file (Notepad)", editConfig)
  MainMenuSettings.Add()
  MainMenuSettings.Add("NoWrapNMode", toggleNoWrapNMode, "Radio")
  MainMenuSettings.Add("NoWrapSMode", toggleNoWrapSMode, "Radio")
  MainMenuSettings.Add("NoWrapVMode", toggleNoWrapVMode, "Radio")
  MainMenuSettings.Add()

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
  local clSave
  
  saveIfChanged()
  
  s := "Screenwidth: " . A_ScreenWidth . ", Screenheight: " . A_ScreenHeight
  
  clSave := ClipboardAll()
  msgBox("Clipboard:`n`n" . s)
  A_Clipboard := clSave
  ToolTip("Clipboard restored, now contains: `n`n" . A_Clipboard)
  settimer () => ToolTip(), 4000
  guiMainEdit.Focus()
}

;------------------------------- openShorthelp -------------------------------
openShorthelp(*){
  Run("shorthelp.html")
}

;-------------------------------- openReadme --------------------------------
openReadme(*){
  Run("readme.html")
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
;--------------------------- toggleSmodeAutoleave ---------------------------
toggleSmodeAutoleave(*){
  global 

  smodeAutoleave := !smodeAutoleave
  setSmodeAutoleave()
}
;----------------------------- setSmodeAutoleave -----------------------------
setSmodeAutoleave(){
  global 
  
  if (smodeAutoleave)
    MainMenuSettings.Check("Smode Autoleave")
  else
    MainMenuSettings.Uncheck("Smode Autoleave")
    
  updateMainSB()
}
;-------------------------------- updateApp --------------------------------
updateApp(*){
  global appname, extension

  updaterExeVersion := "updater" . extension
  
  guiMain.Opt("-alwaysontop")
  guiMain.Hide()
  
  if(FileExist(updaterExeVersion)){
    MsgBox("Starting `"Updater`" now, please restart `"" appname "`" afterwards!")
    Run(updaterExeVersion " runMode")
    exitFunction()
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
  global selectedFolder
  
  p := pathToAbsolut(selectedFolder)
  Run("explore " p)
}
;---------------------------------- openDir ----------------------------------
openDir(d, *){
  global
  
  switch d {
    case "Config":
      run A_ComSpec " /c start " A_ScriptDir
    case "_saved":
      run A_ComSpec " /c start " pathToAbsolut(selectedFolder)
    case "_trash":
      run A_ComSpec " /c start " wrkPath("_trash")

  }
}
;-------------------------------- moveToTrash --------------------------------
moveToTrash(*){
  global 
  local e
    
  if(allfiles.Length < 1)
    return
  
  if (wheelPosition <= allfiles.Length){
    fileToMove := getFromAllfiles()
  }

  if (fileToMove != ""){
    fromPath := pathToAbsolut(selectedFolder) . fileToMove
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
    wheelPosition := wheelPosition
    wheelPosition -= 1
    if (wheelPosition < 1){
      wheelPosition := 1
    }
    wheelPositionSave()
    refreshAllfiles()
    updatecurrentFile()
    readFile(pathToAbsolut(selectedFolder) . currentFile, currentFile)
    showHintColored("Moved to trash: " . fileToMove . " [" . wheelPosition . "] previous file: " . currentFile . " [" . wheelPosition . "] loaded!")
  }
}
;----------------------------------------------------------------------------
















