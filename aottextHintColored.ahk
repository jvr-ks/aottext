; aottextHintColored.ahk
; Part of aottext.ahk

;------------------------------ showHintColored ------------------------------
showHintColored(s := "", n := 3000, fg := "cFFFFFF", bg := "a900ff", newfont := "", newFontSize := "", position := "center"){
  ; guiMainFontName and guiMainFontSize must be globally defined
  
  global
  local t
  
  if (newfont == "")
    newfont := guiMainFontName
    
  if (newFontSize == "")
    newFontSize := guiMainFontSize
    
  if (IsSet(hintColored))
    hintColored.Destroy()
    
  hintColored := Gui("+0x80000000 -Caption +ToolWindow +AlwaysOnTop")
  hintColored.SetFont("c" fg " s" newFontSize, newfont)
  hintColored.BackColor := bg
  hintColored.add("Text", , s)
  hintColored.Show("center")
  
  if (n > 0){
    ; delay the subsequent operations
    SetTimer destroyHintColored, -n
    sleep n
  } else {
    if (n != 0) ; don't destroy if n = 0
      ; don't delay the subsequent operations if n < 0
      SetTimer destroyHintColored, n
  }
}
;---------------------------- destroyHintColored ----------------------------
destroyHintColored(){
  global 
  
  hintColored.Destroy()
}
;----------------------------------------------------------------------------


