/*  listbox ()
 Created by: Kirk 
 Modified: 2023-07-15
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
	This.kind:=Is undefined
	This._lastError:=""
	
	//  use these for the listbox datasource elements
	This._clearDatasources()
	
	//mark:  --- computed attributes
Function get isReady : Boolean
	//  return true when there is data
	return (This.source#Null)
	
Function get dataLength : Integer
	If (This.data=Null)
		return 0
	Else 
		return This.data.length
	End if 
	
Function get isSelected : Boolean
	return Num(This.position)>0
	
	//todo:  add isScalar  \\  True when source is a scalar collection
	
Function get index : Integer
	return This.position-1
	
Function get isCollection : Boolean
	return This.kind=Is collection
	
Function get isEntitySelection : Boolean
	return (This.kind=Is object) && (OB Instance of(This.source; 4D.EntitySelection))
	
Function get error : Text
	return This._lastError
	
Function get_shortDesc() : Text
	//  return a text description of the listbox contents
	Case of 
		: (This.data=Null)
			return "The listbox is empty"
		: (This.isSelected)
			return String(This.selectedItems.length)+" selected out of "+String(This.dataLength)
		Else 
			return "0 selected out of "+String(This.dataLength)
	End case 
	
	//MARK:-  Setters
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
			This.kind:=Is undefined
			This._lastError:="setSource(): no valid data"
	End case 
	
	This._clearDatasources()
	
Function setData
	This.data:=This.source
	
Function redraw()
	This.data:=This.data
	
Function reset()
	This.setData()
	
Function updateEntitySelection()
	//  if this is an entity selection reloads the entities
	If (Not(This.isEntitySelection))
		This._lastError:="updateEntitySelection(): this is a collecton"
	End if 
	var $entity : Object
	
	For each ($entity; This.source)
		$entity.reload()
	End for each 
	
	
	//mark:  --- require the form object
Function deselect
	//  clear the current selection
	LISTBOX SELECT ROW(*; This.name; 0; lk remove from selection)
	This._clearDatasources()
	
Function selectRow($criteria : Variant; $value : Variant)
	var $row : Integer
	
	If (Not(This.isReady))
		This._lastError:="selectRow() err - no data"
		return 
	End if 
	
	Case of 
		: (Value type($criteria)=Is real)
			$row:=$criteria
		Else 
			$row:=This.findRow($criteria; $value)
	End case 
	
	If ($row<1)
		This._lastError:="selectRow() err - bad row number"
		return 
	End if 
	
	LISTBOX SELECT ROW(*; This.name; $row; lk replace selection)
	
	//MARK:-  Data Functions
	// some are just wrappers for native functions but are convenient to have
Function insert($index : Integer; $element : Variant) : Object
	// attempts to add the element into data
	// only supports collections
	If (Not(This.isReady))
		return This._result(False; "")
	End if 
	
	If (Not(This.isCollection))
		return This._result(False; "Can only insert into collections. ")
	End if 
	
	This.data.insert($index; $element)
	This.redraw()
	return This._result(True)
	
Function get_item()->$value : Variant
/*  gets the current item using the position index
note - if 
*/
	return (This.isSelected) ? This.data[This.index] : Null
	
Function indexOf($what : Variant) : Integer
/* attempts to find the index of $what in .data
if this is an entity selection $what must be an entity of that dataclass
if this is a collection $what must be the same type as the collection data
*/
	If ($what=Null) || (This.kind=Null)
		This._lastError:="indexOf(): no parameters"
		return -1
	End if 
	
	If (This.isEntitySelection)
		return $what.indexOf(This.data)
	End if 
	
	return This.data.indexOf($what)
	
Function findRow($what : Variant) : Integer
/*  attempts to select the row for a particular reference
to an object or entity. 
*/
	
	If (Not(This.isReady))
		This._lastError:="findRow(): no data"
		return -1
	End if 
	
	If (Value type($what)#Is object)
		This._lastError:="findRow(): criteria must be an object"
		return -1
	End if 
	
	return This.indexOf($what)+1
	
Function lastIndexOf($key : Text; $findValue : Variant; $startFrom : Integer) : Integer
/*  extracts $key into a collection then finds the lastIndex of $findValue  */
	If (Not(This._keyExists($key)))
		This._lastError:="lastIndexOf(): key '"+$key+"' does not exist"
		return -1
	End if 
	
	If (Count parameters=3)
		return This.extract($key).lastIndexOf($findValue; $startFrom)
	End if 
	
	return This.extract($key).lastIndexOf($findValue)
	
Function sum($key : Text) : Real
	//  return the sum of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.sum($key) : 0
	
Function min($key : Text) : Real
	//  return the min of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.min($key) : 0
	
Function max($key : Text) : Real
	//  return the max of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.max($key) : 0
	
Function average($key : Text) : Real
	//  return the average of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.average($key) : 0
	
Function extract($key : Text) : Collection
	//  return the extracted values of a specific 'column' as a collection
	return (This._keyExists($key)) ? This.data.extract($key) : New collection
	
Function distinct($key : Text) : Collection
	//  return the distinct values of a specific 'column' as a collection
	return (This._keyExists($key)) ? This.data.distinct($key) : New collection
	
	//MARK:-  ---- utilities
Function _clearDatasources
	//  clear the objects that are set by the listbox object
	This.currentItem:=Null
	This.position:=0
	This.selectedItems:=Null
	
Function _result($result : Boolean; $error : Variant) : Object
	Case of 
		: (Count parameters=0) || (Bool($result))
			This._lastError:=""
			return New object("success"; True)
			
		: (Count parameters=2)  // $result=false and an error text
			This._lastError:=String($error)
			return New object("success"; False; "error"; String($error))
			
		Else   // $result=false and no error text
			This._lastError:="Unspecified error."
			return New object("success"; False; "error"; "Unspecified error.")
	End case 
	
Function _keyExists($key : Text) : Boolean
	
	return (This.isReady) && (This.data[0][$key]#Null)
	
Function _keyIsNumber($key : Text) : Boolean
	return This._keyExists($key) && (Value type(This.data[0][$key])=Is real) || (Value type(This.data[0][$key])=Is longint)
	