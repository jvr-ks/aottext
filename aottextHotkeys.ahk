; aottextHotkeys.ahk
; Part of aottext.ahk

;---------------------------- LShift & RButton:: ----------------------------
LShift & RButton::
{
  global
  
  ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = invisible
  switch guiMainMode {
    case 0:
      SModeAction()
      
    case 2:
      NModeAction()
      ; WinActivate("Aottext")
      
    case 3:
      hideGuiMainHotkey()
      
  }
  
  return
}
;------------------------------ Alt & RButton:: ------------------------------
Alt & RButton::
{
  global
  
  ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = invisible
  switch guiMainMode {
    case 0:
      VModeAction()
      
    case 1:
      NModeAction()
      ; WinActivate("Aottext")
      
    case 2:
      VModeAction()
    
    case 3:
      hideGuiMainHotkey()
      
  }
  
  return  
}
;----------------------------- hideGuiMainHotkey -----------------------------
hideGuiMainHotkey(*){
  ; hotkey: "Alt + a" is default -> hide gui
  global 
  
  if (guiMainMode = 3){ ; show again
    WinSetAlwaysOnTop(alwaysontop, "ahk_id " guiMainHwnd)
    guiMain.Show()
    NModeAction()
  } else {
    saveIfChanged()
    WinSetAlwaysOnTop(0, "ahk_id " guiMainHwnd)
    guiMain.Hide()
    guiMainMode := 3
  }
}
;---------------------------- WheelUp / WheelDown ----------------------------
; wheel hotkeys -> historyFoward, historyBackward

LShift & WheelDown::
;historyFoward(*) {
{
  global 
  
  newContent := guiMainEdit.Text
  
  if (StrLen(newContent) < 3 || !InStr(newContent, "`n"))
    newContent .= "`n`n"
  
  if(newContent != actualContent){
    saveIfChanged()
    return
  }
  
  if (allfilesMaxCount > 0 && allfiles.Has(wheelPosition)){
    readFile(pathToAbsolut(savedir) . allfiles[wheelPosition], allfiles[wheelPosition])

    if (wheelPosition == allfilesMaxCount){
      tooltip("most recent file")
      settimer () => tooltip(), 4000
    } else {
      tooltip()
    }
     
    wheelPosition += 1
    if (wheelPosition > allfilesMaxCount){
     wheelPosition := allfilesMaxCount
    }
  } else {
    showHintColored("No files found in: " . savedir)
  }
}
;---------------------------- LShift & WheelUp:: ----------------------------
LShift & WheelUp::
;historyBackward(*) {
{
  global 
  
  newContent := guiMainEdit.Text
  
  if(newContent != actualContent){
    saveIfChanged()
    return
  }
  
  if (allfilesMaxCount > 0 && allfiles.Has(wheelPosition)){
    wheelPosition -= 1
    if (wheelPosition < 1)
     wheelPosition := 1
    
    readFile(pathToAbsolut(savedir) . allfiles[wheelPosition], allfiles[wheelPosition])
    
    if (wheelPosition = 1){
      tooltip(allfiles[wheelPosition] . " (oldest reached!)")
      settimer () => tooltip(), 4000
    } else {
      tooltip()
    }
  }
}
;----------------------------------------------------------------------------

