#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <SendMessage.au3>

; GUI erstellen (Größe veränderbar)
$hGUI = GUICreate("Fensterliste", 500, 400, -1, -1, $WS_SIZEBOX)

; ListView für Fensterliste (mit Fenstertitel & Handle)
$hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 480, 270, BitOR($LVS_REPORT, $LVS_SINGLESEL))
_GUICtrlListView_SetColumnWidth($hListView, 0, 350)
_GUICtrlListView_SetColumnWidth($hListView, 1, 120)

; Buttons
$hBtnUpdate = GUICtrlCreateButton("Aktualisieren", 10, 290, 100, 30)
$hBtnAddCategory = GUICtrlCreateButton("Kategorie hinzufügen", 120, 290, 160, 30)
GUICtrlSetState($hBtnAddCategory, $GUI_DISABLE) ; Deaktiviert, bis ein `TcxVerticalGrid` gefunden wird

; GUI anzeigen
GUISetState(@SW_SHOW, $hGUI)

Global $hFoundGrid = 0

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
            ConsoleWrite("Gefundenes Control: " & $sClass & " - Handle: " & $hChild & @CRLF)
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
    If WinExists($hMainWnd) Then
        ; Suche nach `TcxVerticalGrid` in diesem Fenster
        $hTcxGrid = FindTcxVerticalGrid($hMainWnd)

        If $hTcxGrid <> 0 Then
            MsgBox(64, "TcxVerticalGrid gefunden", "Das Handle des TcxVerticalGrid-Controls ist: " & $hTcxGrid)
            $hFoundGrid = $hTcxGrid
            GUICtrlSetState($hBtnAddCategory, $GUI_ENABLE) ; Button aktivieren

            ; Liste zurücksetzen und nur das gefundene Fenster anzeigen
            GUICtrlDelete($hListView)
            $hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 480, 270, BitOR($LVS_REPORT, $LVS_SINGLESEL))
            _GUICtrlListView_SetColumnWidth($hListView, 0, 350)
            _GUICtrlListView_SetColumnWidth($hListView, 1, 120)
            GUICtrlCreateListViewItem($sTitle & "|" & $hMainWnd, $hListView)
        Else
            MsgBox(48, "Nicht gefunden", "Kein TcxVerticalGrid-Element im Fenster '" & $sTitle & "' gefunden.")
            GUICtrlSetState($hBtnAddCategory, $GUI_DISABLE) ; Button bleibt deaktiviert
        EndIf
    Else
        MsgBox(48, "Fenster nicht gefunden", "Das Fenster '" & $sTitle & "' existiert nicht mehr.")
    EndIf
EndFunc

; Funktion zum Hinzufügen einer Kategorie im Grid
Func AddCategoryToGrid()
    If $hFoundGrid = 0 Then
        MsgBox(48, "Fehler", "Kein TcxVerticalGrid-Handle gefunden!")
        Return
    EndIf

    ; Debug-Ausgabe
    ConsoleWrite("Sende Nachricht an Handle: " & $hFoundGrid & @CRLF)

    ; Sende eine Nachricht, um eine Kategorie hinzuzufügen (muss angepasst werden)
    ; Hier könnte `WM_COMMAND` oder `WM_USER+X` nötig sein, falls HelpNDoc eine spezielle API hat
    Local $WM_COMMAND = 0x111
    Local $CATEGORY_ADD = 1000 ; Hier die richtige ID des "Kategorie hinzufügen"-Befehls eintragen

    _SendMessage($hFoundGrid, $WM_COMMAND, $CATEGORY_ADD, 0)

    MsgBox(64, "Erfolg", "Kategorie wurde zum TcxVerticalGrid hinzugefügt.")
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
            LoadWindowList()
            GUICtrlSetState($hBtnAddCategory, $GUI_DISABLE) ; Button wieder deaktivieren
            $hFoundGrid = 0

        Case $nMsg = $hBtnAddCategory
            AddCategoryToGrid()

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
