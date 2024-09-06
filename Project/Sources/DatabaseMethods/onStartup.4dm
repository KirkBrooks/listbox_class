
var $result : Object
$result:=UTIL_checkMinRTversion()
If (Not($result.success))
	ALERT($result.message)
	QUIT 4D
End if 

CONFIRM("Run the demo?"; "Run it")
If (ok=1)
	Run_demo
End if 
