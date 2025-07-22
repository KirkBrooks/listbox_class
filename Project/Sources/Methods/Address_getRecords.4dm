//%attributes = {}
/* Purpose: return the entity selection of Address records
 ------------------
Address_getRecords ()
 Created by: Kirk as Designer, Created: 07/11/23, 17:38:11
*/
#DECLARE : cs.ADDRESSSelection

TRUNCATE TABLE([ADDRESS])
Address_importSampleData

return ds.ADDRESS.all()