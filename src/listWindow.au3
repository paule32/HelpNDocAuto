;; ---------------------------------------------------------------------------
;; \file   listWindow.au3
;; \author (c) 2025 by Jens Kallup - paule32
;; \copy   all rights reserved.
;;
;; \desc   only for education purposes. commercial use not allowed.
;; ---------------------------------------------------------------------------
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>

;; ---------------------------------------------------------------------------
;; GUI erstellen
;; ---------------------------------------------------------------------------
$hGUI = GUICreate("Fensterliste", 400, 300)

;; ---------------------------------------------------------------------------
;; ListView für Fensterliste
;; ---------------------------------------------------------------------------
$hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 380, 220)
_GUICtrlListView_SetColumnWidth($hListView, 0, 250)
_GUICtrlListView_SetColumnWidth($hListView, 1, 100)

;; ---------------------------------------------------------------------------
;; Button zum Aktualisieren der Liste
;; ---------------------------------------------------------------------------
$hBtnUpdate = GUICtrlCreateButton("Aktualisieren", 10, 240, 100, 30)

;; ---------------------------------------------------------------------------
;; Fenster anzeigen
;; ---------------------------------------------------------------------------
GUISetState(@SW_SHOW, $hGUI)

;; ---------------------------------------------------------------------------
;; Funktion zum Laden der Fensterliste
;; ---------------------------------------------------------------------------
Func LoadWindowList()
    GUICtrlDelete($hListView)
    $hListView = GUICtrlCreateListView("Fenstertitel|Handle", 10, 10, 380, 220)
    _GUICtrlListView_SetColumnWidth($hListView, 0, 250)
    _GUICtrlListView_SetColumnWidth($hListView, 1, 100)

    $aWinList = WinList()
    For $i = 1 To $aWinList[0][0]
        If $aWinList[$i][0] <> "" Then
            GUICtrlCreateListViewItem($aWinList[$i][0] & "|" & $aWinList[$i][1], $hListView)
        EndIf
    Next
EndFunc

;; ---------------------------------------------------------------------------
;; Initiale Laden der Liste
;; ---------------------------------------------------------------------------
LoadWindowList()

;; ---------------------------------------------------------------------------
;; Ereignisschleife
;; ---------------------------------------------------------------------------
While True
    $nMsg = GUIGetMsg()
    Select
        Case $nMsg = $GUI_EVENT_CLOSE
            Exit
        Case $nMsg = $hBtnUpdate
            LoadWindowList()
    EndSelect
WEnd
