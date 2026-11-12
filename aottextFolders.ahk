; aottextFolders.ahk
; Part of aottext.ahk


;---------------------------- generateFoldersMenu ----------------------------
generateFoldersMenu(){
  global
  local folderSelection

  MainMenuFolders := Menu()
  
  folderSelection := IniRead(configFile, "folders", "folder1", selectedFolderDefault)
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection))
  
  Loop 9 {
    folderSelection := IniRead(configFile, "folders", "folder" . A_Index, "")
    if (folderSelection != ""){
      MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection))
    }
  }
  MainMenuFolders.Check(selectedFolder)
}
;------------------------------- selectFolder -------------------------------
selectFolder(fld, *){
  global
  
  MainMenuFolders.UnCheck(selectedFolder)
  
  selectedFolder := fld
  MainMenuFolders.Check(selectedFolder)
  IniWrite "`"" fld "`"", configFile, "user", "selectedFolder"
  
  
  wheelPosition := 1
  wheelPositionSave()
  
  reloadScript()
}
;----------------------------------------------------------------------------


