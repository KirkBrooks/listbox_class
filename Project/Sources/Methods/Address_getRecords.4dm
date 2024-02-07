//%attributes = {}
/* Purpose: return the entity selection of Address records
 ------------------
Address_getRecords ()
 Created by: Kirk as Designer, Created: 07/11/23, 17:38:11
*/
#DECLARE : cs.ADDRESSSelection

If (Records in table([ADDRESS])=0)
	Address_importSampleData
End if 

var $context : Object
ds.setRemoteContextInfo("LB"; ds.ADDRESS; "street, city, state, zip"; "main")

return ds.ADDRESS.all()

