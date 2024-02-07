/*  _Src_selection class
 Created by: Kirk as Designer, Created: 01/16/24, 07:54:49
 ------------------
This will be instantiated as a property of a listbox. 

*/
property data : 4D.EntitySelection
property dataClass : 4D.DataClass

Class constructor($source : 4D.EntitySelection)
	If ($source=Null)
		return 
	End if 
	
	This._id:="src_"+Lowercase(Substring(Generate UUID; 14; 10))
	This.data:=$source
	This.dataClass:=$source ? $source.getDataClass() : Null
	// .setRemoteContextInfo( contextName : Text ; dataClassObject : 4D.DataClass ; attributes : Text {; contextType : Text { ; pageLength : Integer }})
	var $ds : 4D.DataStoreImplementation
	$ds:=ds
	$ds.setRemoteContextInfo(This._id; $ds[This.dataclassName]; "street, city, state, zip"; "main")
	This._context:=ds.getRemoteContextInfo(This._id)
	
Function get dataclassName : Text
	return This.dataClass=Null ? "undefined" : This.dataClass.name
	
	
Function query($queryStr : Text; $settings : Object) : 4D.EntitySelection
	return This.data.query($queryStr; $settings)
	
Function indexOf($entity : 4D.Entity) : Integer
	If ($entity=Null)
		return -1
	End if 
	return $entity.indexOf(This.data)+1  //  add 1 for the row number
	
Function findRow($entity : 4D.Entity) : Integer
	return This.indexOf($entity)+1
	
	