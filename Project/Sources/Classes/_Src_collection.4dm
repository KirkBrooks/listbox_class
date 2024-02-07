/*  _Src_collection class
 Created by: Kirk as Designer, Created: 01/16/24, 07:53:40
 ------------------
 Description: 

*/
Class constructor($source : Collection)
	This.data:=$source
	
	
Function query($queryStr : Text; $settings : Object) : Collection
	return This.data.query($queryStr; $settings)
	
	
	
	
	