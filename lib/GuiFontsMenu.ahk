; GuiFontsMenu.ahk (lib)
; #Include lib\GuiFontsMenu.ahk

; The font of menus are defined by Windows (not individually changable)

;----------------------------- generateGuiFontsMenu -----------------------------
generateGuiFontsMenu(){
  global
  local font
  
  font := ""
  GuiFontsMenu := Menu()
  Loop 20 {
    if (IsSet(preferredFont%A_Index%Default))
      font := IniRead(configFile, "preferedFonts", "preferredFont%A_Index%", preferredFont%A_Index%Default)
    else
      font := IniRead(configFile, "preferedFonts", "preferredFont%A_Index%", "")
    
    if (font != "")
      GuiFontsMenu.Add(font, selectGuiFont.Bind(font), "Radio")
  }
  
  GuiFontsMenu.Add()
  
  Loop Parse allFontsList, "`n" {
    if (A_LoopField != "") {
      GuiFontsMenu.Add(A_LoopField, selectGuiFont.Bind(A_LoopField), "Radio")
    }
  }
}
;------------------------------- selectGuiFont -------------------------------
selectGuiFont(fn, *){
  global
  
  if (IsSet(guiMain)){

    GuiFontsMenu.UnCheck(guiMainFontName) 
    guiMainFontName := fn
    guiMain.SetFont("s" . guiMainFontSize, guiMainFontName)
    GuiFontsMenu.Check(guiMainFontName) 
    
    IniWrite "`"" guiMainFontName "`"", configFile, "config", "guiMainFontName"
    
    reload
  }
}
;-------------------------- generateGuiFontSizeMenu --------------------------
generateGuiFontSizeMenu(){
  global 
  
  GuiFontSizeMenu := Menu()
  Loop 16 {
    GuiFontSizeMenu.Add(A_Index + 3, selectGuiFontSize.Bind(A_Index + 3), "Radio")
  }
}
;----------------------------- selectGuiFontSize -----------------------------
selectGuiFontSize(fs, *){
  global
  
    guiMainFontSize := fs
    guiMain.SetFont("s" . guiMainFontSize, guiMainFontName)
    GuiFontSizeMenu.Check(guiMainFontSize) 
    
    IniWrite guiMainFontSize, configFile, "config", "guiMainFontSize"
    
    reload
}
;----------------------------------------------------------------------------

