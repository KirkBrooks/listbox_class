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

return ds.ADDRESS.all()