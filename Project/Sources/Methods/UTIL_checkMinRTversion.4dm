//%attributes = {}
/* Purpose: looks at the compatibilityVersion property in 
.4DProject file and compares to the current version. 
Result: { success: bool; message: ""}
 ------------------
UTIL_checkMinRTversion ()
 Created by: Kirk Brooks as Designer, Created: 09/05/24, 16:53:03
Char  Description
1-2   Version number
3     "R" number
4     Revision number

*/
#DECLARE->$result : Object
var $file : 4D.File
var $files : Collection
var $minVersion; $thisVersion : Text

$files:=Folder(fk database folder).folder("Project").files().query("extension = :1"; ".4DProject")

If ($files.length=0)
	return {success: False; message: "Could not find the .4DProject file."}
End if 

$file:=$files[0]

$minVersion:=String(JSON Parse($file.getText()).compatibilityVersion)
$thisVersion:=Application version

Case of 
	: ($thisVersion>=$minVersion)
		return {success: True}
	: ($minVersion[[3]]="0")
		return {success: False; message: "This app requires at least 4D "+Substring($minVersion; 1; 2)+"."+$minVersion[[4]]+"."}
	Else 
		return {success: False; message: "This app requires at least 4D "+Substring($minVersion; 1; 2)+"R"+$minVersion[[3]]+"."}
End case 
