; This ahk file is sourced from some content of AccViewer Source.ahk

#NoEnv
#SingleInstance, force
SetBatchLines, -1
#Requires AutoHotkey v1.1

if !(A_IsAdmin || InStr(DllCall("GetCommandLine", "Str"), ".exe"" /r"))
	RunWait % "*RunAs " (s:=A_IsCompiled ? "" : A_AhkPath " /r ") Chr(34) A_ScriptFullPath Chr(34) (s ? "" : " /r")

Gui Main: New, HWNDhwnd LabelGui AlwaysOnTop, Accessible
Gui Main: Default

TempMenu_CopyCode:
TempMenu_CopyCodeSingle:
TempMenu_CopyCodeParameters:
defaultGui := A_DefaultGui
Gui, % defaultGui ":Default"

codeType := (A_ThisLabel = "TempMenu_CopyCodeSingle")     ? "single"
	: (A_ThisLabel = "TempMenu_CopyCodeParameters") ? "parameters"
	: "full"

ToolTip("Copied",,,, 2000)
Return

; ToolTip("Test",,,, 3000)
ToolTip(Text := "", X := "", Y := "", WhichToolTip := 1, Timeout := "") {
	ToolTip, % Text, X, Y, WhichToolTip

	If (Timeout) {
		RemoveToolTip := Func("ToolTip").Bind(,,, WhichToolTip)
		SetTimer, % RemoveToolTip, % -Timeout
	}
}

; =================================================================
createSearchCode(ByRef outCode, codeType, parentElement, params, childId, inOutPath, inOutRole) {

	code_part1 =
	(LTrim Join`r`n
		#NoEnv
		SetBatchLines, -1

		if !hwnd := WinExist("%title% ahk_exe %exeName% ahk_class %class%")
		%A_Tab%throw "window not found"

		%code_WM_GETOBJECT%

		accRoot := AccObjectFromWindow(hwnd)
		if !accFound := SearchElement(accRoot, %strParams%, %childId%, "%inOutPath%", "%inOutRole%")
		%A_Tab%throw "element not found"

		MsgBox, `% accFound.accName(%childId%)
		%code_DoDefaultAction%
		Return

	)

	code_part2 =
	(% Join`r`n
		AccChildren(Acc) {
				static VT_DISPATCH := 9
				Loop 1  {
					if ComObjType(Acc, "Name") != "IAccessible"  {
						error := "Invalid IAccessible Object"
						break
					}
					try cChildren := Acc.accChildCount
					catch
						Return ""
					Children := []
					VarSetCapacity(varChildren, cChildren*(8 + A_PtrSize*2), 0)
					res := DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0
															, "Int", cChildren, "Ptr", &varChildren, "IntP", cChildren)
					if (res != 0) {
						error := "AccessibleChildren DllCall Failed"
						break
					}
					Loop % cChildren  {
						i := (A_Index - 1)*(A_PtrSize*2 + 8)
						child := NumGet(varChildren, i + 8)
						Children.Push( (b := NumGet(varChildren, i) = VT_DISPATCH) ? AccQuery(child) : child )
						( b && ObjRelease(child) )
					}
				}
				if error
					ErrorLevel := error
				else
					Return Children.MaxIndex() ? Children : ""
		}

		AccQuery(Acc) {
				static IAccessible := "{618736e0-3c3d-11cf-810c-00aa00389b71}", VT_DISPATCH := 9, F_OWNVALUE := 1
				try Return ComObject(VT_DISPATCH, ComObjQuery(Acc, IAccessible), F_OWNVALUE)
		}
	)

	outCode := code_part1 . code_part2
	outCode := StrReplace(outCode, "`r`n`r`n`r`n", "`r`n",, 1)
}
