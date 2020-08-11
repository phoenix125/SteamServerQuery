#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\phoenix_5Vq_icon.ico
#AutoIt3Wrapper_Outfile=Builds\SteamServerQuery_v1.4.exe
#AutoIt3Wrapper_Res_Comment=https://github.com/phoenix125
#AutoIt3Wrapper_Res_Description=Writes a CSV file containing all output data from a Steam Game Server Query Request
#AutoIt3Wrapper_Res_Fileversion=1.4.0.0
#AutoIt3Wrapper_Res_ProductName=SteamServerQuery
#AutoIt3Wrapper_Res_ProductVersion=1.4.0
#AutoIt3Wrapper_Res_CompanyName=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_LegalCopyright=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#AutoIt3Wrapper_Change2CUI=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <String.au3>
Global $aUtil = "SteamServerQuery"
Global $tIPPort = ""
Global $tIP = ""
Global $tPort = ""
Global $cHelp = False
Global $cPRTw = False
Global $cPRTo = False
Global $cTXTw = False
Global $cTXTo = False
Global $cCSVw = False
Global $cCSVo = False
Global $fTXTw = @ScriptDir & "\" & $aUtil & "Label.txt"
Global $fTXTo = @ScriptDir & "\" & $aUtil & "NOLabel.txt"
Global $fCSVw = @ScriptDir & "\" & $aUtil & "Label.csv"
Global $fCSVo = @ScriptDir & "\" & $aUtil & "NOLabel.csv"
Global $fError = @ScriptDir & "\" & $aUtil & "Error.txt"
FileDelete($fTXTw)
FileDelete($fTXTo)
FileDelete($fCSVw)
FileDelete($fCSVo)
FileDelete($fError)

Local $tHelp = 'Use: SteamServerQuery {options} IP:port' & @CRLF & _
		'  or: SteamServerQuery {options} URL:port' & @CRLF & @CRLF & _
		'-h = Displays this help text' & @CRLF & _
		'-pw = Print output to commandline with labels' & @CRLF & _
		'-po = Print output to commandline WITHOUT labels' & @CRLF & _
		'-tw = Write output to txt file with labels to [' & $fTXTw & ']' & @CRLF & _
		'-to = Write output to txt file WITHOUT labels to [' & $fTXTo & ']' & @CRLF & _
		'-cw = Write output to csv file with Labels to [' & $fCSVw & ']' & @CRLF & _
		'-co = Write output to csv file WITHOUT labels to [' & $fCSVo & ']' & @CRLF & @CRLF & _
		'Example 1: SteamServerQuery -pw -co 127.0.0.1:26500' & @CRLF & _
		'Example 2: SteamServerQuery -tw phoenix125.com:26500' & @CRLF & @CRLF & _
		'NOTICE! For many servers, use Query Port +1' & @CRLF & _
		'   Ex: If query port is 30000, use 30001' & @CRLF & @CRLF & _
		'Thank you. Visit https://github.com/phoenix125 for updates and/or more programs.' & @CRLF
If $CmdLine[0] < 1 Then
	ConsoleWrite($tHelp)
	Exit
EndIf
For $t = 1 To $CmdLine[0]
	If $CmdLine[$t] = "-h" Then $cHelp = True
	If $CmdLine[$t] = "-pw" Then $cPRTw = True
	If $CmdLine[$t] = "-po" Then $cPRTo = True
	If $CmdLine[$t] = "-tw" Then $cTXTw = True
	If $CmdLine[$t] = "-to" Then $cTXTo = True
	If $CmdLine[$t] = "-cw" Then $cCSVw = True
	If $CmdLine[$t] = "-co" Then $cCSVo = True
	If StringLen($CmdLine[$t]) > 2 Then $tIPPort = $CmdLine[$t]
Next
If $cHelp Then
	ConsoleWrite($tHelp)
	Exit
EndIf
If $cPRTw = False And $cPRTo = False And $cTXTw = False And $cTXTo = False And $cCSVw = False And $cCSVo = False Then
	$cPRTo = True
EndIf

Local $tSplit = StringSplit($tIPPort, ":")
If $tSplit[0] = 2 Then
	$tIP = $tSplit[1]
	$tPort = $tSplit[2]
Else
	_QuitError("Error: IP:Port are formatted incorrectly or missing." & @CRLF & "[" & $tIPPort & "]" & @CRLF & @CRLF & $tHelp)
EndIf
$tSplit = StringSplit($tIP, ".")
If $tSplit[0] < 4 Then
	TCPStartup()
	$tIP = TCPNameToIP($tIP)
	If @error Then _QuitError($tTxt = "Error: Unable to get IP from URL." & @CRLF & "[" & $tIP & "]" & @CRLF & @CRLF & $tHelp)
	TCPShutdown()
EndIf
Global $xReply = _GetQuery($tIP, $tPort)
If UBound($xReply) < 14 Then
	If UBound($xReply) > 0 Then
		_QuitError($xReply[0] & "," & $xReply[1])
	Else
		_QuitError("Error getting response from server at [" & $tIPPort & "]")
	EndIf
EndIf
_WriteTxt($xReply)
Exit
Func _WriteTxt($tTXTr, $tErrTF = False)
	If $tErrTF Then
		Local $tErrcw = "Error," & "Error getting response from server at [" & $tIPPort & "]" & @CRLF
		Local $tErrco = "Error:" & "Error getting response from server at [" & $tIPPort & "]" & @CRLF
	Else
		Local $tErrcw = ""
		Local $tErrco = ""
	EndIf
	If UBound($tTXTr) = 0 Then
		$tTXTo = $tErrco & StringReplace($tTXTr, "|", @CRLF)
	Else
		$tTXTo = StringReplace(_ArrayToString($tTXTr), "|", @CRLF)
	EndIf
	If $cPRTw Or $cTXTw Or $cCSVw Then
		If UBound($tTXTr) > 0 Then
			Global $xLabels[15] = ["Raw", "Name", "Map", "Folder", "Game", "ID", "Players", "Max Players", "Bots", "Server Type", "Environment", "Visibility", "VAC", "Version", "Extra Data Field"]
			Local $2D_Array[UBound($tTXTr)][2]
			For $i = 0 To (UBound($tTXTr) - 1)
				$2D_Array[$i][0] = $xLabels[$i]
				$2D_Array[$i][1] = $tTXTr[$i]
			Next
			Local $tTXTw = _ArrayToCSV($2D_Array)
		Else
			$tTXTw = $tErrco & $tTXTr
		EndIf
		If $tTXTw = "" Then
			$tTXTw = "ERROR,No response from server at IP:" & $tIP & " Port:" & $tPort
		Else
			$tTXTw &= "Note,In the Extra Data Field only: all hex characters [nul] 0x00 replaced with [~] 0x7E"
		EndIf
	EndIf

	If $cPRTw Then ConsoleWrite($tErrcw & $tTXTw)
	If $cPRTo Or $tErrTF Then ConsoleWrite($tErrco & $tTXTo)
	If $cTXTw Then
		Local $tErr = FileWrite($fTXTw, $tErrcw & $tTXTw)
		If $tErr = 0 Or @error Then _QuitError("Error: Unable to write [" & $fTXTw & "]" & @CRLF & "File may be in use."
	EndIf
	If $cTXTo Then
		Local $tErr = FileWrite($fTXTo, $tErrco & $tTXTo)
		If $tErr = 0 Or @error Then _QuitError("Error: Unable to write [" & $fTXTo & "]" & @CRLF & "File may be in use."
	EndIf
	If $cCSVw Then
		Local $tErr = FileWrite($fCSVw, $tErrcw & $tTXTw)
		If $tErr = 0 Or @error Then _QuitError("Error: Unable to write [" & $fCSVw & "]" & @CRLF & "File may be in use."
	EndIf
	If $cCSVo Then
		Local $tErr = FileWrite($fCSVo, $tErrco & $tTXTo)
		If $tErr = 0 Or @error Then _QuitError("Error: Unable to write [" & $fCSVo & "]" & @CRLF & "File may be in use."
	EndIf
EndFunc   ;==>_WriteTxt
Func _QuitError($tTxt)
	_WriteTxt($tTxt, True)
	If $cTXTo Or $cTXTw Or $cCSVw Or $cCSVo Then FileWrite($fError, $tTxt)
	TCPShutdown()
	Exit
EndFunc   ;==>_QuitError
Func _GetQuery($tIP, $tPort)
	Local $tHeader = "T"
	Local $tCmd = "Source Engine Query"
	Local $tLead = Chr(255) & Chr(255) & Chr(255) & Chr(255)
	Local $tSend = $tLead & $tHeader & $tCmd & Chr(0)
	If UDPStartup() <> 1 Then
		Local $tReturn[2]
		$tReturn[0] = "Error"
		$tReturn[1] = "Could not start the network stack"
		Return $tReturn
	EndIf

	$socket = UDPOpen($tIP, $tPort)
	If @error Then
		Local $iError = @error
		Local $tReturn[2]
		$tReturn[0] = "Error"
		$tReturn[1] = "UDP Open: " & $iError
		UDPShutdown()
		Return $tReturn
	EndIf

	UDPSend($socket, $tSend)
	If @error Then
		Local $iError = @error
		Local $tReturn[2]
		$tReturn[0] = "Error"
		$tReturn[1] = "UDP Send: " & $iError
		UDPShutdown()
		Return $tReturn
	EndIf

	$timer = TimerInit()
	$lastDiff = 0
	While 1
		$data = UDPRecv($socket, 99999, 2)
		If $data = "" And @error < -1 Then
			Local $iError = @error
			If $iError = -1 Then
				$tError = "Invalid Socket"
			ElseIf $iError = -2 Then
				$tError = "Not Connected. Try using query port +1"
			ElseIf $iError = -3 Then
				$tError = "Invalid Socket Array"
			ElseIf $iError = -4 Then
				$tError = "Invalid Socket Array"
			Else
				$tError = "[" & $iError & "] See Windows Sockets Error Codes webpage: https://docs.microsoft.com/en-us/windows/win32/winsock/windows-sockets-error-codes-2"
			EndIf
			Local $tReturn[2]
			$tReturn[0] = "Error"
			$tReturn[1] = $tError
			UDPShutdown()
			Return $tReturn
		EndIf
		If IsArray($data) And BinaryLen($data[0]) > 0 Then
			Local $xReply = _ConvertHextoStringWithReplace($data[0])
			UDPShutdown()
			Return $xReply
		EndIf
		$stamp = TimerDiff($timer) / 1000
		If $stamp > $lastDiff + 1 Then
			UDPSend($socket, String("Stamp:" & $stamp))
			$lastDiff = $stamp
		EndIf
	WEnd
EndFunc   ;==>_GetQuery

Func _ConvertHextoStringWithReplace($tTxt0)
	Local $tArray[1]
	$tArray[0] = $tTxt0
	Local $tPos = 0
	; -------------- Remove Header --------------
	$tTxt0 = StringTrimLeft($tTxt0, 14)
	Local $tLen = StringLen($tTxt0)
	; -------------- 1 Name --------------
	Local $tTxt2 = ""
	For $t = $tPos To $tLen Step 2
		$tPos += 2
		$tHex1 = StringMid($tTxt0, $t + 1, 2)
		If $tHex1 = "00" Then
			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= _HexToString($tHex1)
		EndIf
	Next
	; -------------- 2 Map --------------
	Local $tTxt2 = ""
	For $t = $tPos To $tLen Step 2
		$tPos += 2
		$tHex1 = StringMid($tTxt0, $t + 1, 2)
		If $tHex1 = "00" Then
			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= _HexToString($tHex1)
		EndIf
	Next
	; -------------- 3 Folder --------------
	Local $tTxt2 = ""
	For $t = $tPos To $tLen Step 2
		$tPos += 2
		$tHex1 = StringMid($tTxt0, $t + 1, 2)
		If $tHex1 = "00" Then
			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= _HexToString($tHex1)
		EndIf
	Next
	; -------------- 4 Game --------------
	Local $tTxt2 = ""
	For $t = $tPos To $tLen Step 2
		$tPos += 2
		$tHex1 = StringMid($tTxt0, $t + 1, 2)
		If $tHex1 = "00" Then
			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= _HexToString($tHex1)
		EndIf
	Next
	; -------------- 5 ID --------------
	Local $tTxt2 = ""
	For $t = $tPos To $tLen Step 2
		$tPos += 2
		$tHex1 = StringMid($tTxt0, $t + 1, 2)
		If $tHex1 = "00" Then
			_ArrayAdd($tArray, Dec($tTxt2))
;~ 			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= $tHex1
		EndIf
	Next
	; -------------- 6 Players --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, Dec($tHex1))
	; -------------- 7 Max Players --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, Dec($tHex1))
	; -------------- 8 Bots --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, Dec($tHex1))
	; -------------- 9 Server type --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, _HexToString($tHex1))
	; -------------- 10 Environment --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, _HexToString($tHex1))
	; -------------- 11 Visibility --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, Dec($tHex1))
	; -------------- 12 VAC --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, Dec($tHex1))
	; -------------- 13 Version --------------
	Local $tTxt2 = ""
	$tPos += 2
	For $t = $tPos To $tLen Step 2
		$tPos += 2
		$tHex1 = StringMid($tTxt0, $t + 1, 2)
		If $tHex1 = "00" Then
			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= _HexToString($tHex1)
		EndIf
	Next
	; -------------- 14 EDF --------------
	$tPos += 2
	Local $tTxt2 = StringTrimLeft($tTxt0, $tPos)
	Local $tTxt1 = "0x"
	For $i = 0 To (StringLen($tTxt0) / 2)
		If StringMid($tTxt2, $i * 2 + 1, 2) = "00" Then
			$tTxt1 &= "7E"
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt1 &= StringMid($tTxt2, $i * 2 + 1, 2)
		EndIf
	Next
	_ArrayAdd($tArray, _HexToString($tTxt1))
	; -------------- Done ----------------
	Return $tArray
EndFunc   ;==>_ConvertHextoStringWithReplace
Func _ArrayToCSV($aArray, $sDelim = Default, $sNewLine = Default, $bFinalBreak = True) ; Thanks to czardas https://www.autoitscript.com/forum/topic/155748-csvsplit/
	If Not IsArray($aArray) Or UBound($aArray, 0) > 2 Or UBound($aArray) = 0 Then Return SetError(1, 0, "")
	If $sDelim = Default Then $sDelim = ","
	If $sDelim = "" Then Return SetError(2, 0, "")
	If $sNewLine = Default Then $sNewLine = @LF
	If $sNewLine = "" Then Return SetError(3, 0, "")
	If $sDelim = $sNewLine Then Return SetError(4, 0, "")

	Local $iRows = UBound($aArray), $sString = ""
	If UBound($aArray, 0) = 2 Then
		Local $iCols = UBound($aArray, 2)
		For $i = 0 To $iRows - 1
			For $j = 0 To $iCols - 1
				If StringRegExp($aArray[$i][$j], '["\r\n' & $sDelim & ']') Then
					$aArray[$i][$j] = '"' & StringReplace($aArray[$i][$j], '"', '""') & '"'
				EndIf
				$sString &= $aArray[$i][$j] & $sDelim
			Next
			$sString = StringTrimRight($sString, StringLen($sDelim)) & $sNewLine
		Next
	Else
		For $i = 0 To $iRows - 1
			If StringRegExp($aArray[$i], '["\r\n' & $sDelim & ']') Then
				$aArray[$i] = '"' & StringReplace($aArray[$i], '"', '""') & '"'
			EndIf
			$sString &= $aArray[$i] & $sNewLine
		Next
	EndIf
	If Not $bFinalBreak Then $sString = StringTrimRight($sString, StringLen($sNewLine)) ; Delete any newline characters added to the end of the string
	Return $sString
EndFunc   ;==>_ArrayToCSV
