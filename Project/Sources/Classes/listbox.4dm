/*  listbox ()
 Created by: Kirk as Designer, Created: 10/7/21,
 ------------------
Default Names
eg. display data, current item, etc. These are stored in the Form and accessed with

TO USE
/*
add the listbox to the form and set the names
initialize
    Form["listbox name"]:=cs.listbox.new("listbox name")
*/

*/

Class constructor($name : Text; $refs : Object)
	ASSERT(Count parameters>=1; "The name of the listbox object is required.")
	
	This.name:=$name  //      the name of the listbox
	
	This.source:=Null  //  collection/entity selection form[name].data is drawn from
	This.data:=Null
	This.kind:=Null
	
	//  use these for the listbox datasource elements
	This._clearDatasources()
	
	//mark:  --- computed attributes
Function get dataLength : Integer
	If (This.data=Null)
		return 0
	Else 
		return This.data.length
	End if 
	
Function get isSelected : Boolean
	return Num(This.position)>0
	
	//todo:  add isScalar  \\  True when source is a scalar collection
	
Function get index->$index : Integer
	$index:=This.position-1
	
Function get isCollection : Boolean
	return This.kind=Is collection
	
Function get isEntitySelection : Boolean
	return This.kind=Is object
	
Function get index->$index : Integer
	$index:=Num(This.position-1)
	
Function get_shortDesc() : Text
	//  return a text description of the listbox contents
	Case of 
		: (This.data=Null)
			return "The listbox is empty."
		: (This.isSelected)
			return String(This.selectedItems.length)+" selected out of "+String(This.dataLength)
		Else 
			return "0 selected out of "+String(This.dataLength)
	End case 
	
	//MARK:-  setters
Function setSource($source : Variant)
/*   Set the source data and determine it's kind   */
	var $type : Integer
	$type:=Value type($source)
	
	Case of 
		: ($type=Is collection)
			This.source:=$source
			This.kind:=$type
			This.setData()
			
		: ($type=Is object) && (OB Instance of($source; 4D.EntitySelection))  //   entity selection
			This.source:=$source
			This.kind:=$type
			This.setData()
			
		Else 
			This.source:=Null
			This.data:=Null
			This.kind:=Null
	End case 
	
	This._clearDatasources()
	
Function setData
	ASSERT(Count parameters=0)  //  set the data to the source
	This.data:=This.source
	
Function insert($index : Integer; $element : Variant) : Object
	// attempts to add the element into data
	// only supports collections
	
	If (Not(This.isCollection))
		return This._result(False; "Can only insert into collections. ")
	End if 
	
	This.data.insert($index; $element)
	This.redraw()
	return This._result(True)
	
	//MARK:-
Function get_item()->$value : Variant
	//  gets the current item using the position index
	return (This.isSelected) ? This.data[This.index] : Null
	
Function redraw()
	This.data:=This.data
	
Function reset()
	This.setData()
	
Function updateEntitySelection()
	//  if this is an entity selection reloads the entities
	If (This.isEntitySelection)
		var $entity : Object
		
		For each ($entity; This.source)
			$entity.reload()
		End for each 
	End if 
	
Function findRow($criteria : Variant; $value : Variant) : Integer
/*  attempts to select the row 
criteria is an entity when data is entity selection 
criteria is a property for collections or entity selections
and value is the comparator. 
*/
	var $o : Object
	
	If (Not(This.isEntitySelection)) && (Not(This.isCollection))
		return -1
	End if 
	
	If (Value type($criteria)=Is object) && (This.isEntitySelection)
		return $criteria.indexOf(This.data)+1  //  add 1 for the row number
	End if 
	
	If (This.isCollection) && (Value type($criteria)=Is text) && (Count parameters=2)
		return This.data.findIndex(Formula($1.value[$2]=$3); $criteria; $value)+1
	End if 
	
	return -1  // 
	
	//mark:  --- require the form object
Function deselect
	//  clear the current selection
	LISTBOX SELECT ROW(*; This.name; 0; lk remove from selection)
	This._clearDatasources()
	
Function selectRow($criteria : Variant; $value : Variant)
	var $row : Integer
	
	Case of 
		: (Value type($criteria)=Is real)
			$row:=$criteria
		Else 
			$row:=This.findRow($criteria; $value)
	End case 
	
	LISTBOX SELECT ROW(*; This.name; $row; lk replace selection)
	
	//MARK:-  data functions
	//  these are really just wrappers for native functions
	// but are convenient to have
Function indexOf($what : Variant) : Integer
/* attempts to find the index of $what in .data
if this is an entity selection $what must be an entity of that dataclass
if this is a collection $what must be the same type as the collection data
*/
	If ($what=Null) | (This.kind=Null)
		return -1
	End if 
	
	If (This.kind=Is object)  //  entity selection: $what is an entity
		return $what.indexOf(This.data)
	End if 
	
	If (This.kind=Is collection)
		return This.data.indexOf($what)
	End if 
	
Function sum($key : Text) : Real
	//  return the sum of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.sum($key) : 0
	
Function min($key : Text) : Real
	//  return the min of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.min($key) : 0
	
Function max($key : Text) : Real
	//  return the max of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.max($key) : 0
	
Function average($key : Text)->$value : Real
	//  return the average of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.average($key) : 0
	
Function extract($key : Text)->$collection : Collection
	//  return the extracted values of a specific 'column' as a collection
	return (This._keyExists($key)) ? This.data.extract($key) : New collection
	
Function distinct($key : Text)->$collection : Collection
	//  return the distinct values of a specific 'column' as a collection
return (This._keyExists($key)) ? This.data.distinct($key) : New collection
	
Function lastIndexOf($key : Text; $findValue : Variant) : Integer
	return (This._keyExists($key)) ? This.extract($key).lastIndexOf($findValue) : -1
	
	//MARK:-  ---- utilities
Function _clearDatasources
	//  clear the objects that are set by the listbox object
	This.currentItem:=Null
	This.position:=0
	This.selectedItems:=Null
	
Function _result($result : Boolean; $error : Variant) : Object
	Case of 
		: (Count parameters=0) || (Bool($result))
			return New object("success"; True)
			
		: (Count parameters=2)  // $result=false and an error text
			return New object("success"; False; "error"; String($error))
			
		Else   // $result=false and no error text
			return New object("success"; False; "error"; "Unspecified error.")
	End case 
	
Function _keyExists($key : Text) : Boolean
	return (This.dataLength>0) && (This.data[0][$key]#Null)
	
Function _keyIsNumber($key : Text) : Boolean
	return This._keyExists($key) && (Value type(This.data[0][$key])=Is real) || (Value type(This.data[0][$key])=Is longint)
	