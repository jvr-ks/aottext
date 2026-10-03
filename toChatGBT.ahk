moveEventSwitch(p1, p2, p3, p4, *){
  global
  local h1, h2, h3
  
  if (inhibit)
    return
  
  h1 := 0, h2 := 0, h3 := 0
  
  if (IsSet(guiMain)){
    h1 := guiMainHwnd
  }
    
  ; if (IsSet(guiPreview)){
    ; h2 := guiPreview.hwnd
  ; }
  
  ; if (IsSet(guiImagePreview)){
    ; h3 := guiImagePreview.hwnd
  ; }
  
  Switch  p4
  {
    Case h1:
      guiMain_Move()
...
;----------------------------------------------------------------------------

guiMain_Move(){
  global
  local debugMsg1
  
  if (inhibit)
    return
    
  guiMain.GetPos(&posX, &posY)
  
  if (posX != 0 && posY != 0){ 
    ; 0 = normal mode, 1 = vertical mode, 2 = SMode mode, 3 = invisible
    switch guiMainMode {
      case 0:
        minPosTop := 0 
        minPosLeft := 150 - (guiMainClientWidth)
      
        guiMainPosX := posX
        guiMainPosY := posY
        
        checkGuiMainposition()
        
        IniWrite guiMainPosX, configFile, "gui", "guiMainPosX"
        IniWrite guiMainPosY, configFile, "gui", "guiMainPosY"
        
tooltip("WRITTEN! " . guiMainPosX . " " . guiMainPosY . " cfg: " . configFile)

...
;----------------------------------------------------------------------------


    
dpiScale := IniRead(configFile, "gui", "dpiScale", dpiScaleDefault)

guiMainPosX := IniRead(configFile, "gui", "guiMainPosX", guiMainPosXDefault)
  
dpiCorrect := A_ScreenDPI / dpiScale
      
guiMain.Show("Hide x" . guiMainPosX . " y" . guiMainPosY . " w" . guiMainClientWidth . " h" . guiMainClientHeight)

  
guiMainPosX :=