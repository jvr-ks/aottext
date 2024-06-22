; aottextHelper.ahk
; Part of aottext.ahk

;-------------------------------- wrkPath --------------------------------
wrkPath(p){
  global 
  local r
  
  r := wrkdir . p
    
  return r
}
;------------------------------- pathToAbsolut -------------------------------
pathToAbsolut(p){
  global 
  local r
  
  r := p
  if (!InStr(p, ":"))
    r := wrkPath(p)
    
  if (SubStr(r, -1, 1) != "\")
    r .= "\"
    
  return r
}
;------------------------------ FontSizeToPixel ------------------------------
; FontSizeToPixel(n){
  ; local r

    ; r := round(n * A_ScreenDPI / 72)

  ; return r
; }
;----------------------------- checkDirectories -----------------------------
checkDirectories(){
  global 
  local dir
  
  dir := pathToAbsolut(saveDir)
  if (!FileExist(dir))
    DirCreate(dir)
  
  dir := pathToAbsolut(trashDir)
  if (!FileExist(dir))
    DirCreate(dir)
  
  return 
}
;----------------------------- coordsScreenToApp -----------------------------
coordsScreenToApp(n){
  global 
  local r
  
  r := round(n / dpiCorrect)

  return r
}
;----------------------------- coordsAppToScreen -----------------------------
coordsAppToScreen(n){
  global 
  local r

  r := round(n * dpiCorrect)

  return r
}
;--------------------------------- WinCenter ---------------------------------
; from: https://www.autohotkey.com/board/topic/92757-win-center/
WinCenter(guiMainHwnd, hChild, Visible := 1) {
  DetectHiddenWindows(true)
  WinGetPos(&X, &Y, &W, &H, "ahk_ID " guiMainHwnd)
  WinGetPos(&_X, &_Y, &_W, &_H, "ahk_ID " hChild)
  If Visible {
      MonitorGetWorkArea(WinMonitor(guiMainHwnd), &MWALeft, &MWATop, &MWARight, &MWABottom)
      X := X+(W-_W)//2, X := X < MWALeft ? MWALeft+5 : X, X := (X + _W) > MWARight ? MWARight-_W-5 : X
      Y := Y+(H-_H)//2, Y := Y < MWATop ? MWATop+5 : Y, Y := (Y + _H) > MWABottom ? MWABottom-_H-5 : Y
  } Else X := X+(W-_W)//2, Y := Y+(H-_H)//2
  WinMove(X, Y, , , "ahk_ID " hChild)
  WinShow("ahk_ID " hChild)
}
;-------------------------------- WinMonitor --------------------------------
WinMonitor(hwnd, Center := 1) {
  MonitorCount := SysGet(80)
  WinGetPos(&X, &Y, &W, &H, "ahk_ID " hwnd)
  if (Center){
    X := X+(W//2)
    Y := Y+(H//2)
  }
  Loop MonitorCount {
    MonitorGet(A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom)
    if (X >= MonLeft && X <= MonRight && Y >= MonTop && Y <= MonBottom)
        Return A_Index
  }
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
  local PID, size, pmcex, ret, hProcess
  
  PID := DllCall("GetCurrentProcessId")
  size := 880
  pmcex := Buffer(size, 0)
  ret := ""
  
  hProcess := DllCall("OpenProcess", "UInt", 0x400|0x0010, "Int", 0, "Ptr", PID, "Ptr")
  if (hProcess)
  {
      if (DllCall("psapi.dll\GetProcessMemoryInfo", "Ptr", hProcess, "Ptr", pmcex, "UInt", size))
        ret := Round(NumGet(pmcex, "16", "UInt") / 1024**2, 2)
      DllCall("CloseHandle", "Ptr", hProcess)
  }
  return ret
}
;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1, t := 4000){
  local s 
  
  s := StrReplace(msg, "^", ",")
  
  toolX := round(A_ScreenWidth / 2)
  toolY := 2

  CoordMode("ToolTip", "Screen")
  
  ToolTip(s, toolX, toolY, n)
  
  WinGetPos(&X, &Y, &W, &H, "ahk_class tooltips_class32")

  toolX := (A_ScreenWidth / 2) - W / 2
  
  ToolTip(s, toolX, toolY, n)
  
  SetTimer(tipTopCloseAll, 0)
  if (t > 0){
    tvalue := -1 * t
    SetTimer(tipTopCloseAll, tvalue)
  }
}
;-------------------------------- tipTopCloseAll --------------------------------
tipTopCloseAll(){
  
  Loop 20
  {
    ToolTip(, , , A_Index)
  }
}



;----------------------------------------------------------------------------














