; aottextHtmlViewer.ahk
; Part of aottext.ahk

;------------------------------- htmlViewer -------------------------------
htmlViewer(url, *){
  global 
  local e
  
  SetTimer(checkFocus, 0)
    
  clientWidthHtmlViewer := coordsScreenToApp(A_ScreenWidth * 0.8)
  clientHeightHtmlViewer := coordsScreenToApp(A_ScreenHeight * 0.8)

  guiMainMode := 3
  guiMain.Hide()

  if (IsSet(htmlViewerGui))
    htmlViewerGui.Destroy()
    
  htmlViewerGui := Gui("+resize +alwaysontop", "Short Help / Readme")
  htmlViewerGui.OnEvent("Close", htmlViewer_Close)
  ; htmlViewer.OnEvent("Size", htmlViewer_Size, 1)
  
  ; Shell.Explorer:
  WB := htmlViewerGui.Add("ActiveX", "w" clientWidthHtmlViewer " h" clientHeightHtmlViewer " +VSCROLL +HSCROLL", "Shell.Explorer").Value

  SB := htmlViewerGui.Add("StatusBar")
  SB.SetParts(300, 300)
  SB.SetText("Use CTRL + mousewheel to zoom in/out!", 1, 1)
  
  WinActivate("Short Help / Readme")

  if (FileExist(url)){
    htmlViewerGui.Show("center")
    WB.Navigate(url)
  } else {
    htmlViewerGui.Destroy()
    showHintColored("Error: File not found: " url)
  }
}
;----------------------------- htmlViewer_Close -----------------------------
htmlViewer_Close(*){
  global
  
  SetTimer(checkFocus, 3000)
}
;------------------------------ htmlViewer_Size ------------------------------
; htmlViewer_Size(*){
  ; global 

  ; if (A_EventInfo != 1) {
    ; statusBarSize := 20
    ; clientWidthHtmlViewer := clientWidth
    ; clientHeightHtmlViewer := clientHeight - statusBarSize

    ; WB.Move(, , clientWidthHtmlViewer, clientHeightHtmlViewer)
  ; }
; }
;---------------------------- htmlViewerGuiClose ----------------------------
htmlViewerGuiClose(){
  global 

  ; WinSetStyle("+alwaysOnTop", "ahk_id " guiMainHwnd)
  guiMain.Show()
}