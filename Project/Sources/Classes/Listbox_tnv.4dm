/*  Listbox_tnv class
 Created by: Kirk as Designer, Created: 10/30/23, 14:03:30
 ------------------
 Description: 

*/
Class extends SelectionData

Class constructor($name : Text)
	Super($name)
	This._currentItem:=Null
	This._position:=0
	This._selectedItems:=Null
	
	//mark:  --- functions
Function setSource($input) : cs.Listbox_tnv
	Super.setSource($input)
	return This.setData()
	
Function setData($input) : cs.Listbox_tnv
	This.data:=Count parameters=0 ? This.source : $input
	return This
	
	//mark:  --- calculated attr 
	
	
	
	
	//mark:  --- calculated attr for listbox object
Function get currentItem : Object
	return This._currentItem
	
Function get position : Integer
	return This._position
	
Function get selectedItems : Variant
	return This._selectedItems
	
Function set currentItem($obj : Object)
	This._currentItem:=$obj
	
Function set position($i : Integer)
	This._position:=$i
	
Function set selectedItems($items : Variant)
	This._selectedItems:=$items
	
	//mark:  --- other calculated
Function get isFormObject : Boolean
	//  true if there is a form object for this listbox
	return OBJECT Get pointer(Object named; This.name)#Null
	
Function get isSelected : Boolean
	return Num(This.position)>0
	
Function get index : Integer
	return This.position-1
	
	