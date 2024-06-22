; aottextTODO.ahk
; Part of aottext.ahk

;-------------------------------- findTextGui --------------------------------
; search is TODO!
findTextGui(){
  global 
  local buttonOK, fgColor, bgColor
  
  fgColor := "cffffff", bgColor := "a900ff"

  if (!IsSet(enterFindText)){
    enterFindText := Gui("+0x80000000 +Owner -Caption +ToolWindow +AlwaysOnTop")
    
    enterFindText.BackColor := bgColor
    enterFindText.SetFont(fgColor)
    ;Gui, enterFindText:Add, Text,, Please enter the search-text:
    enterFindText.Add("Text", , "Sorry, text-search is under construction!")
    enterFindTextEdit := enterFindText.Add("Edit", "w200")
    buttonOK := enterFindText.Add("Button",, "OK")
    buttonOK.OnEvent("Click", enterFindTextOK)

    enterFindText.Show()
    hEnterFindText := enterFindText.HWND

    WinCenter(guiMainHwnd, hEnterFindText, 1)
  }
  
  return
}
;------------------------------ enterFindTextOk ------------------------------
enterFindTextOk(*){
  global 
  local textToFind
  
  Saved  := enterFindText.Submit(0)
  
  textToFind := enterFindTextEdit.Text
  
  enterFindText.Hide()

  ; VarSetStrCapacity(&characterRange, 0)
  
  ; NumPut("Int64", 0, characterRange, 0)
  ; l := StrLen(actualContent) * 2
  ; NumPut("Int64", l, characterRange, 64)
  
  ; VarSetStrCapacity(&findStruct, 0)
  
  ; NumPut(Type, Number, findStruct, Offset)
  
  ; TargetVar := VarSetStrCapacity(&TargetVar, RequestedCapacity)
  ; NumPut(Type, Number, textToFind, Offset)
  ; Number := NumGet(textToFind, Offset, Type)
  
  ;pos := 0
  ; pos := guiMainEdit.FINDTEXTFULL(findStruct)
  
  ;guiMainEdit.GoToPos(pos)
}
;--------------------------------- findText ---------------------------------
findText(*){

  findTextGui.Show()
}































;----------------------------------------------------------------------------

