; This ahk file is sourced from some content of AHKinfo.ahk and Personal script
#Requires AutoHotkey v1.1

if InStr(OutCtrl1,"Internet Explorer_Server") {
    if IsObject(wb) {
        Loop,% LV_GetCount() {
            LV_Modify(A_Index,"Col2",_LV_GetText(A_Index)="outertext"     ? ele)|
            LV_Modify(A_Index,"Col2",_LV_GetText(A_Index)="innertext"     ? ele:)
            LV_Modify(A_Index,"Col2",_LV_GetText(A_Index)="type"             ? ele:)

            ;~ LV_Modify(A_Index,_LV_GetText(A_Index)="checked"        and _LV_GetText(A_Index,2)!="" and ele.checked=-1 ? "Col2 Check":"Col2 -Check",_LV_GetText(A_Index)="checked"     ? (ele.checked=-1 ? "True":"false"):)
        }
        LV_ModifyCol(), Radio1Text:=ele.innerhtml, Radio2Text:=ele.outerhtml
    }
}

if (OutWin3!=AHKID){ ;comment
    a:=""
    ;comment
}


reload01(needSave:=true){
	runAhkFile(A_ScriptFullPath,needSave)
	Return
	; global mBoolToastGuiFirst
	if(needSave)
		send, ^s
	; tooltip ██reload██, A_ScreenWidth*0.49, A_ScreenHeight*0.66
	; if (mBoolToastGuiFirst)
	; toast("█reload█")
	; else
	; tooltip ╔════════╗`n║██reload██║`n╚════════╝, A_ScreenWidth*0.49, A_ScreenHeight*0.66
	tooltip 〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓, A_ScreenWidth*0.49, A_ScreenHeight*0.60
	sleep, 65
	; SoundPlay *64
	Reload
	ToolTip
	return
}

runAhkFile(path,needSave:=true){
	if(needSave)
		send, ^s
	tooltip 〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓`n〓〓, A_ScreenWidth*0.49, A_ScreenHeight*0.60
	sleep, 65
	; SoundPlay *64
	SplitPath, path,, OutDir,OutExtension
	if(OutExtension="ah2"){
		run,"%path%","%OutDir%"
		ToolTip
		Return
	}
	run,"%path%","%OutDir%"
	; run,"%ahk_exe_fp%" "%path%","%OutDir%"
	ToolTip
	return
}

_LV_GetText(Index,Col=1) {
    LV_GetText(sText,Index,Col)
    return sText
}

中文 =
(LTrim
		<html><head><meta charset="UTF-8"><head><meta name="viewport" content="width=device-width">
		<title>NAS html</title>
)
