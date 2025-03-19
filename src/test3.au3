#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>

; GUI erstellen (Größe veränderbar)
$hGUI = GUICreate("Fensterliste", 500, 350, -1, -1, $WS_SIZEBOX)

; ListView für Fensterliste (mit Fenstertitel & Handle)
$hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 480, 270, BitOR($LVS_REPORT, $LVS_SINGLESEL))
_GUICtrlListView_SetColumnWidth($hListView, 0, 350)
_GUICtrlListView_SetColumnWidth($hListView, 1, 120)

; Button zum Aktualisieren der Liste
$hBtnUpdate = GUICtrlCreateButton("Aktualisieren", 10, 290, 100, 30)

; GUI anzeigen
GUISetState(@SW_SHOW, $hGUI)

; Funktion zum Laden der Fensterliste, aber nur für "HelpNDoc Professional Edition"
Func LoadWindowList()
    GUICtrlDelete($hListView)
    $hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 480, 270, BitOR($LVS_REPORT, $LVS_SINGLESEL))
    _GUICtrlListView_SetColumnWidth($hListView, 0, 350)
    _GUICtrlListView_SetColumnWidth($hListView, 1, 120)

    $aWinList = WinList()
    For $i = 1 To $aWinList[0][0]
        If $aWinList[$i][0] <> "" And StringInStr($aWinList[$i][0], "- HelpNDoc Professional Edition") Then
            GUICtrlCreateListViewItem($aWinList[$i][0] & "|" & $aWinList[$i][1], $hListView)
        EndIf
    Next
EndFunc

; Funktion zum Durchlaufen aller Controls eines Fensters
Func FindTcxVerticalGrid($hParent)
    Local $hChild = 0
    Do
        $hChild = _WinAPI_FindWindowEx($hParent, $hChild, 0, "")
        If $hChild <> 0 Then
            Local $sClass = _WinAPI_GetClassName($hChild)
            If StringInStr($sClass, "TcxVerticalGrid") Then
                Return $hChild ; Handle des gefundenen Controls zurückgeben
            EndIf
            ; Rekursive Suche in Unterfenstern (falls es verschachtelte Controls gibt)
            Local $hSubControl = FindTcxVerticalGrid($hChild)
            If $hSubControl <> 0 Then Return $hSubControl
        EndIf
    Until $hChild = 0
    Return 0
EndFunc

; Funktion zur Verarbeitung der Auswahl eines Fensters
Func ProcessSelectedWindow($sTitle, $hMainWnd)
    ; Prüfen, ob das Hauptfenster existiert
    If WinExists($hMainWnd) Then
        ; Suche nach "TcxVerticalGrid" in diesem Fenster
        $hTcxGrid = FindTcxVerticalGrid($hMainWnd)

        If $hTcxGrid <> 0 Then
            MsgBox(64, "TcxVerticalGrid gefunden", "Das Handle des TcxVerticalGrid-Controls ist: " & $hTcxGrid)

            ; Liste zurücksetzen und nur das gefundene Fenster anzeigen
            GUICtrlDelete($hListView)
            $hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 480, 270, BitOR($LVS_REPORT, $LVS_SINGLESEL))
            _GUICtrlListView_SetColumnWidth($hListView, 0, 350)
            _GUICtrlListView_SetColumnWidth($hListView, 1, 120)
            GUICtrlCreateListViewItem($sTitle & "|" & $hMainWnd, $hListView)
        Else
            MsgBox(48, "Nicht gefunden", "Kein TcxVerticalGrid-Element im Fenster '" & $sTitle & "' gefunden.")
        EndIf
    Else
        MsgBox(48, "Fenster nicht gefunden", "Das Fenster '" & $sTitle & "' existiert nicht mehr.")
    EndIf
EndFunc

; Initiale Laden der Liste mit nur relevanten Fenstern
LoadWindowList()

; Ereignisschleife
While True
    $nMsg = GUIGetMsg()
    Select
        Case $nMsg = $GUI_EVENT_CLOSE
            Exit

        Case $nMsg = $hBtnUpdate
            LoadWindowList() ; Vollständige Liste wiederherstellen

        Case $nMsg >= 1000 ; Ein Eintrag wurde ausgewählt
            $sSelected = GUICtrlRead($nMsg)
            If $sSelected <> "" Then
                $aParts = StringSplit($sSelected, "|", 2)
                If UBound($aParts) = 2 Then
                    $sTitle = $aParts[0]
                    $hMainWnd = $aParts[1]
                    ProcessSelectedWindow($sTitle, $hMainWnd)
                EndIf
            EndIf
    EndSelect
WEnd
