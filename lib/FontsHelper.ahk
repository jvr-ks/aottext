; FontsHelper.ahk (lib)
; #Include lib\FontsHelper.ahk

;------------------------------- getFontsList -------------------------------
getFontsList(){
  global 
  local hDC, Callback
  
  allFontsList := ""
  
  ; from https://www.autohotkey.com/boards/viewtopic.php?t=12416
  
  hDC := DllCall("GetDC", "Ptr", DllCall("GetDesktopWindow", "Ptr"), "Ptr")
  Callback := CallbackCreate(EnumFontsCallback, "F")
  DllCall("EnumFontFamilies", "Ptr", hDC, "Ptr", 0, "Ptr", Callback, "Ptr", lParam := 0)
  DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
  
  allFontsList := StrReplace(allFontsList, "Consolas" , "")
  allFontsList := StrReplace(allFontsList, "Noto colored emoji" , "")
  allFontsList := StrReplace(allFontsList, "Segoe UI" , "")
  
  allFontsList := Sort(allFontsList, "CL U")
}
;----------------------------- EnumFontsCallback -----------------------------
EnumFontsCallback(lpelf, *) {
  global 
  local fn
  
  fn := StrGet(lpelf + 28, 32)
  If (SubStr(fn, 1, 1) != "@") {
    allFontsList .= fn . "`n"
  }
  
  return 1
}

