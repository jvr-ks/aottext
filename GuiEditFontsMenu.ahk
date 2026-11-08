; GuiEditFontsMenu.ahk (lib)
; #Include lib\GuiEditFontsMenu.ahk

;----------------------------- generateGuiEditFontsMenu -----------------------------
generateGuiEditFontsMenu(){
  global
  local font

  GuiEditFontsMenu := Menu()
  
  font := preferredFontDefault  ; default
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio") ; 1st is default
  GuiEditFontsMenu.Add() ; Divider
  
  font := IniRead(configFile, "preferredFonts", "preferredFont1", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont2", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont3", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont4", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont5", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont6", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont7", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont8", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  font := IniRead(configFile, "preferredFonts", "preferredFont9", preferredFontDefault)
  GuiEditFontsMenu.Add(font, selectTextFont.Bind(font), "Radio")
  
  GuiEditFontsMenu.Add() ; Divider           
  
  Loop Parse allFontsList, "`n" {
    if (A_LoopField != "") {
      GuiEditFontsMenu.Add(A_LoopField, selectTextFont.Bind(A_LoopField), "Radio")
    }
  }
}
;------------------------------ selectTextFont ------------------------------
selectTextFont(fn, *){
  global
  
  if (IsSet(guiMainEdit)){
    GuiEditFontsMenu.UnCheck(guiMainEditFontName) 
    guiMainEditFontName := fn
    guiMainEdit.Style.Font := guiMainEditFontName
    GuiEditFontsMenu.Check(guiMainEditFontName) 
    
    IniWrite "`"" guiMainEditFontName "`"", configFile, "config", "guiMainEditFontName"
    updateMainSB()
    reloadScript()
  }
}
;----------------------- generateGuiEditFontSizeMenu -----------------------
generateGuiEditFontSizeMenu(){
  global 
  
  GuiEditFontSizeMenu := Menu()
  Loop 16 {
    GuiEditFontSizeMenu.Add(A_Index + 3, selectGuiEditFontSize.Bind(A_Index + 3), "Radio")
  }
}
;----------------------------- selectGuiFontSize -----------------------------
selectGuiEditFontSize(fs, *){
  global
  
    guiMainEditFontSize := fs
    guiMainEdit.SetFont("s" . guiMainEditFontSize, guiMainEditFontName)
    GuiEditFontSizeMenu.Check(guiMainEditFontSize) 
    
    IniWrite guiMainEditFontSize, configFile, "config", "guiMainEditFontSize"
    
    reloadScript()
}
;----------------------------------------------------------------------------

