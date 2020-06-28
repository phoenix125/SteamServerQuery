#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\phoenix_5Vq_icon.ico
#AutoIt3Wrapper_Outfile=Builds\SteamServerQuery_v1.1.exe
#AutoIt3Wrapper_Res_Comment=https://github.com/phoenix125
#AutoIt3Wrapper_Res_Description=Writes a CSV file containing all output data from a Steam Game Server Query Request
#AutoIt3Wrapper_Res_Fileversion=1.1.0.0
#AutoIt3Wrapper_Res_ProductName=SteamServerQuery
#AutoIt3Wrapper_Res_ProductVersion=1.1.0
#AutoIt3Wrapper_Res_CompanyName=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_LegalCopyright=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <String.au3>

Local $tIPPort = $CmdLine[1]
Local $tSplit = StringSplit($tIPPort, ":", 2)
Local $tIP = $tSplit[0]
Local $tPort = $tSplit[1]
Local $tFile = @ScriptDir & "\SteamServerQueryOut.csv"
Local $tErrorFile = @ScriptDir & "\SteamServerQueryError.txt"
Local $tSig = "Comment,Thank you. Visit https://github.com/phoenix125 for updates and/or more programs."
FileDelete($tErrorFile)
FileDelete($tFile)
Global $xLabels[15] = ["Raw", "Name", "Map", "Folder", "Game", "ID", "Players", "Max Players", "Bots", "Server Type", "Environment", "Visibility", "VAC", "Version", "Extra Data Field"]
Global $xReply = _GetQuery($tIP, $tPort)
If UBound($xReply) < 14 Then
	$tWrite = $xReply[0] & "," & $xReply[1]
	FileWrite($tFile, $tWrite)
	FileWrite($tErrorFile, $tWrite)
	Exit
EndIf
Local $2D_Array[UBound($xReply)][2]
For $i = 0 To (UBound($xReply) - 1)
	$2D_Array[$i][0] = $xLabels[$i]
	$2D_Array[$i][1] = $xReply[$i]
Next
Local $tWrite = _ArrayToCSV($2D_Array)
If $tWrite = "" Then
	$tWrite = "ERROR,No response from server at IP:" & $tIP & " Port:" & $tPort & @CRLF & $tSig
Else
	$tWrite &= "Note,In the Extra Data Field only: all hex characters [nul] 0x00 replaced with [~] 0x7E" & @CRLF & $tSig
EndIf
$tErr = FileWrite($tFile, $tWrite)
If $tErr = 0 Then
	$tWrite = "Error: Unable to write " & $tFile & @CRLF & "File may be in use." & @CRLF & $tSig
	FileWrite($tErrorFile, $tWrite)
EndIf

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
			_ArrayAdd($tArray, $tTxt2)
			ExitLoop
		ElseIf $tHex1 = "7C" Then
			$tTxt2 &= _HexToString("2F")
		Else
			$tTxt2 &= _HexToString($tHex1)
		EndIf
	Next
	; -------------- 6 Players --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, _HexToString($tHex1 + 30))
	; -------------- 7 Max Players --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, _HexToString($tHex1 + 30))
	; -------------- 8 Bots --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, _HexToString($tHex1 + 30))
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
	_ArrayAdd($tArray, _HexToString($tHex1 + 30))
	; -------------- 12 VAC --------------
	$tPos += 2
	$tHex1 = StringMid($tTxt0, $tPos + 1, 2)
	_ArrayAdd($tArray, _HexToString($tHex1 + 30))
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
