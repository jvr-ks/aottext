; aottextFolders.ahk
; Part of aottext.ahk


;---------------------------- generateFoldersMenu ----------------------------
generateFoldersMenu(){
  global
  local folderSelection

  MainMenuFolders := Menu()
  
  folderSelection := IniRead(configFile, "folders", "folder1", selectedFolderDefault)
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder2", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
    
  folderSelection := IniRead(configFile, "folders", "folder3", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder4", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder5", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder6", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder7", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder8", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
  
  folderSelection := IniRead(configFile, "folders", "folder9", "")
  if (folderSelection = "")
    folderSelection := selectedFolderDefault
  MainMenuFolders.Add(folderSelection, selectFolder.Bind(folderSelection), "Radio")
 
}
;------------------------------- selectFolder -------------------------------
selectFolder(fld, *){
  global
  
  if (fld != ""){
    selectedFolder := fld
    
    IniWrite "`"" fld "`"", configFile, "user", "selectedFolder"
        
    wheelPosition := 1
    wheelPositionSave()
    
    reloadScript()
  } else {
    msgbox("Selection of folder: " . selectedFolder . " failed!")
  }
}

