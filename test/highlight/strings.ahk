; Double-quoted strings
"hello"
; <- string

x := "world"
;    ^^^^^^^ string

; Single-quoted strings
'hello'
; <- string

x := 'world'
;    ^^^^^^^ string

; Empty strings
""
; <- string

''
; <- string

; Strings with spaces
"hello world"
; <- string

; Escape sequences in strings
x := "line1`nline2"
;    ^^^^^^^^^^^^^^ string
;          ^^ string.escape

x := "tab`there"
;        ^^ string.escape

x := "carriage`rreturn"
;             ^^ string.escape

; Multiple escapes
x := "`n`t`r"
;     ^^ string.escape
;       ^^ string.escape
;         ^^ string.escape

; Backtick escape (literal backtick)
x := "back``tick"
;        ^^ string.escape

; Quote escape (using backtick)
x := "say `"hello`""
;         ^^ string.escape
;               ^^ string.escape

; Strings in function calls
MsgBox("Hello World")
;      ^^^^^^^^^^^^^ string

result := Format("Value: {1}", x)
;                ^^^^^^^^^^^^ string

if !(A_IsAdmin || InStr(DllCall("GetCommandLine", "str"), ".exe"" /r"))
    Run % "*RunAs " (s:=A_IsCompiled ? "" : A_AhkPath " /r ") Chr(34) A_ScriptFullPath Chr(34) (s ? "" : " /r")
;         ^^^^^^^^^                                   ^^^^^^                                             ^^^^^ string

FileAppend,
(
xxxxxxxx
), %cfg%
; <- string

MsgBox,
(
done
position: %cfg%
)
; <- string
