
global android_sdk_fp

EnvGet,A_AppDataPath,LOCALAPPDATA ; C:\Users\xx\AppData\Local

OpenReleaseFolder(){
	projectPath:=""

	Loop, Files, %projectPath%/*, D
	{
        testfun();
;       ^^^^^^^ function
	}
}

/* xxxx */
; <- comment

testfun(){

}
