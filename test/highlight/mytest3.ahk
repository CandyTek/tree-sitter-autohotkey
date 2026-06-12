; This ahk file is sourced from some content of FindText.ahk and Gdip_All.ahk
#Requires AutoHotkey v1.1

code()
{
return "
(

//***** C source code of machine code *****
// gcc.exe -m32/-m64 -O2

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , unsigned char * ss, unsigned int * s1, unsigned int * s0
......
NoMatch3:;
}
return ok;
}

)"
}



Sort3(ok, dir:=1)
{
  local
  if !IsObject(ok)
    return ok
  s:="", n:=150000
  For k,v in ok
    x:=v.1, y:=v.2
    , s.=(dir=1 ? y*n+x
    : dir=2 ? y*n-x
    : dir=3 ? -y*n+x
    : dir=4 ? -y*n-x
    : dir=5 ? x*n+y
    : dir=6 ? x*n-y
    : dir=7 ? -x*n+y
    : dir=8 ? -x*n-y : y*n+x) "." k "|"
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

Lang(text:="", getLang:=0)
{
  local
  static init, Lang1, Lang2
  if !VarSetCapacity(init) && (init:="1")
  {
    s:="
    (
Myww       = Width = Adjust the width of the capture range
...
s19 = Are you sure to delete all screenshots ?
    )"
    Lang1:=[], Lang2:=[]
    Loop Parse, s, `n, `r
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v "==","\n","`n"), "=", "`t ")
        , Lang1[r[1]]:=r[2], Lang2[r[1]]:=r[3]
  }
  return getLang=1 ? Lang1 : getLang=2 ? Lang2 : Lang1[text]
}


Gdip_CreateStreamOnFile(sFile, accessMode:="rw") {
    access := (0
      |  ((access ~= "[rR]")  ?  0x80000000  :  0)
      |  ((access ~= "[wW]")  ?  0x40000000  :  0) )

    streamPtr := 0
    gdipLastError := DllCall("gdiplus\GdipCreateStreamOnFile", "WStr", sFile, "UInt", accessMode, "Ptr*", streamPtr)
    Return streamPtr
}

testfun(){
    MCode_PixelateBitmap := "
    (LTrim Join
    ...
    )"
}
