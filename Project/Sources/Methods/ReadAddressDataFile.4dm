//%attributes = {}
/* Purpose: read the address.json file in Resources
 ------------------
ReadAddressDataFile ()
 Created by: Kirk as Designer, Created: 07/11/23, 17:24:05
*/

#DECLARE() : Collection
var $file; $archive : 4D.File
var $files : Collection

$file:=Folder(fk resources folder).folder("sample data").file("addresses.json.zip")
$archive:=ZIP Read archive($file)

If ($archive.root=Null) || ($archive.root.exists=False)
	ALERT("The sample data file is missing.")
	return 
End if 

$files:=$archive.root.files()

If ($files.length=0) && ($files[0].exists=False)
	ALERT("The sample data file is missing.")
	return 
End if 

return JSON Parse($files[0].getText())
