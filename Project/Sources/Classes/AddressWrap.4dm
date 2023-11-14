/*  AddressWrap class
 Created by: Kirk as Designer, Created: 11/14/23, 11:29:55
 ------------------
 Description: 

*/

Class constructor($entity : cs.ADDRESSEntity)
	This._entity:=$entity
	This.userSelect:=False  // true when use selects
	
Function get ID : Text
	return This._entity.ID
	
Function oneLine() : Text
	return This._entity.oneLine()
	
Function get latitude : Real
	return This._entity.latitude