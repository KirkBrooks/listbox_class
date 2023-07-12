//%attributes = {}
/* Purpose: 
 ------------------
Address_importSampleData ()
 Created by: Kirk as Designer, Created: 07/11/23, 15:07:11
*/
var $data : Collection
var $entity : cs.ADDRESSEntity
var $obj : Object

$data:=ReadAddressDataFile

If ($data=Null)
	return 
End if 

TRUNCATE TABLE([ADDRESS])

For each ($obj; $data)
	$entity:=ds.ADDRESS.new()
	$entity.kind:="house"
	$entity.street:=$obj.StreetAddress
	$entity.city:=$obj.City
	$entity.state:=$obj.State
	$entity.zip:=$obj.ZipCode
	$entity.country:=$obj.Country
	$entity.source:=$obj.GUID
	$entity.latitude:=$obj.Latitude
	$entity.longitude:=$obj.Longitude
	$entity.save()
End for each 