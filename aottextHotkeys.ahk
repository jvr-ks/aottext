; aottextHotkeys.ahk
; Part of aottext.ahk

;---------------------------- LShift & RButton:: ----------------------------
LShift & RButton::
{
  global
  
  ; 0 = normal mode, 1 = VMode/vertical mode, 2 = SMode/small, 3 = FsMode/Fullscreen, 4 = invisible
  switch guiMainMode {
    case 0:
      SModeAction()
      
    case 1:
      SModeAction()
    
    case 2:
      NModeAction()
      
    case 3:
      SModeAction()
    
    case 4:
      SModeAction()
      
  }
  
  return
}
;------------------------------ Alt & RButton:: ------------------------------
Alt & RButton::
{
  global
  
  ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = FsMode, 4 = invisible
  switch guiMainMode {
    case 0:
      VModeAction()
      
    case 1:
      NModeAction()
 
    case 2:
      VModeAction()
    
    case 3:
      VModeAction()
    
    case 4:
      VModeAction()
      
  }
}
;------------------------------ LWin & RButton:: ------------------------------
LWin & RButton::
{
  global
  
  ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = FsMode, 4 = invisible
  switch guiMainMode {
    case 0:
      FsModeAction()
      
    case 1:
      FsModeAction()
      
    case 2:
      FsModeAction()
    
    case 3:
      NModeAction()
    
    case 4:
      FsModeAction()
      
  }
}
;----------------------------- hideGuiMainHotkey -----------------------------
hideGuiMainHotkey(*){
  ; hotkey: "Alt + a" is default -> hide gui
  global 
  
  if (guiMainMode = 4){ ; show again
    WinSetAlwaysOnTop(alwaysontop, "ahk_id " guiMainHwnd)
    guiMain.Show()
    NModeAction()
  } else {
    saveIfChanged()
    WinSetAlwaysOnTop(0, "ahk_id " guiMainHwnd)
    guiMain.Hide()
    guiMainMode := 4
  }
}
;---------------------------- WheelUp / WheelDown ----------------------------
; wheel hotkeys -> historyFoward, historyBackward

LShift & WheelDown::
{
  historyFoward()
}

;------------------------------- historyFoward -------------------------------
historyFoward(*) {
  global 
  
  saveIfChanged()
  
  if (allfilesMaxCount > 0){
    wheelPosition += 1
    
   if (wheelPosition >= allfilesMaxCount){
      wheelPosition := allfilesMaxCount
      MouseGetPos &xActuPos, &yActuPos
      ToolTip("most recent file", xActuPos + 40, yActuPos + 20)
      settimer () => tooltip(), 4000
    }
    
    updateMainSB()
    if (allfiles.Has(wheelPosition)){
      readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
      updatecurrentFile()
      wheelPositionSave()
    } else {
      showHintColored("No file number " . wheelPosition . " not found in: " . selectedFolder)
    }
  } else {
    showHintColored("There are no files yet!")
  }
}
;------------------------------ historyFoward10 ------------------------------
historyFoward10(*) {
  global 
  
  saveIfChanged()
  
  if (allfilesMaxCount > 0){
    wheelPosition += 10
    
   if (wheelPosition >= allfilesMaxCount){
      wheelPosition := allfilesMaxCount
      MouseGetPos &xActuPos, &yActuPos
      ToolTip("most recent file", xActuPos + 40, yActuPos + 20)
      settimer () => tooltip(), 4000
    }
    
    updateMainSB()
    if (allfiles.Has(wheelPosition)){
      readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
      updatecurrentFile()
      wheelPositionSave()
    } else {
      showHintColored("No file number " . wheelPosition . " not found in: " . selectedFolder)
    }
  } else {
    showHintColored("There are no files yet!")
  }
}
;---------------------------- historyFowardFirst ----------------------------
historyFowardFirst(*) {
  global 
  
  saveIfChanged()
  
  if (allfilesMaxCount > 0){
    wheelPosition := allfilesMaxCount
    MouseGetPos &xActuPos, &yActuPos
    ToolTip("most recent file", xActuPos + 40, yActuPos + 20)
    settimer () => tooltip(), 4000
    
    updateMainSB()
    if (allfiles.Has(wheelPosition)){
      readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
      updatecurrentFile()
      wheelPositionSave()
    } else {
      showHintColored("No file number " . wheelPosition . " not found in: " . selectedFolder)
    }
  } else {
    showHintColored("There are no files yet!")
  }
}
;---------------------------- LShift & WheelUp:: ----------------------------
LShift & WheelUp::
{
  historyBackward()
}
;------------------------------ historyBackward ------------------------------
historyBackward(*) {
  global 
  
  saveIfChanged()
  
  if (allfilesMaxCount > 0){
    wheelPosition -= 1
    if (wheelPosition < 1)
     wheelPosition := 1
      
    updateMainSB()
    if (allfiles.Has(wheelPosition)){
      readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
      updatecurrentFile()
      wheelPositionSave()
      if (wheelPosition = 1){
        MouseGetPos &xActuPos, &yActuPos
        ToolTip("first file!", xActuPos + 40, yActuPos + 20)
        settimer () => tooltip(), 4000
      }
    } else {
      showHintColored("No file number " . wheelPosition . " not found in: " . selectedFolder)
    }
  } else {
    showHintColored("There are no files yet!")
  }
}
;----------------------------- historyBackward10 -----------------------------
historyBackward10(*) {
  global 
  
  saveIfChanged()
  
  if (allfilesMaxCount > 0){
    wheelPosition -= 10
    if (wheelPosition < 1)
     wheelPosition := 1
      
    updateMainSB()
    if (allfiles.Has(wheelPosition)){
      readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
      updatecurrentFile()
      wheelPositionSave()
      if (wheelPosition = 1){
        MouseGetPos &xActuPos, &yActuPos
        ToolTip("first file!", xActuPos + 40, yActuPos + 20)
        settimer () => tooltip(), 4000
      }
    } else {
      showHintColored("No file number " . wheelPosition . " not found in: " . selectedFolder)
    }
  } else {
    showHintColored("There are no files yet!")
  }
}
;--------------------------- historyBackwardFirst ---------------------------
historyBackwardFirst(*) {
  global 
  
  saveIfChanged()
  
  if (allfilesMaxCount > 0){
    wheelPosition := 1
    updatecurrentFile()
    updateMainSB()
    if (allfiles.Has(wheelPosition)){
      readFile(pathToAbsolut(selectedFolder) . getFromAllfiles(), getFromAllfiles())
      updatecurrentFile()
      wheelPositionSave()
      if (wheelPosition = 1){
        MouseGetPos &xActuPos, &yActuPos
        ToolTip("first file!", xActuPos + 40, yActuPos + 20)
        settimer () => tooltip(), 4000
      }
    } else {
      showHintColored("No file number " . wheelPosition . " not found in: " . selectedFolder)
    }
  } else {
    showHintColored("There are no files yet!")
  }
}
;----------------------------------------------------------------------------

